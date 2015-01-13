# ////////////////////////////////
#
# copyrigh(c) 2007 Graham Stark (graham.stark@virtual-worlds.biz)
#
# This is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
# 
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this software; see the file docs/gpl_v3.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street,
# Boston, MA 02110-1301, USA.
# 
# /////////////////////////////
#
from string import upper
import re
import copy
from string import capwords

## NOTE: this requires the Enum34 backport; see: 
# http://stackoverflow.com/questions/36932/how-can-i-represent-an-enum-in-python
from enum import Enum

# from xml.dom.minidom import parse
# import xml

from XMLUtils import setIntAttribute

from lxml import etree
from lxml.etree import tostring

from utils import adafyName, makePlural, makeUniqueArray, \
     notNullOrBlank, isNullOrBlank, concatenate,concatList, nameToAdaFileName
from paths import WorkingPaths

# paths = WorkingPaths.Instance()

# NOTE: these require the Enum34 backport; see: 
# http://stackoverflow.com/questions/36932/how-can-i-represent-an-enum-in-python
Format = Enum( 'Format', 'unformatted ada ada_filename' )
Qualification = Enum( 'Qualification', 'full schema unqualified' )
ItemType = Enum( 'ItemType', 'table alist list_container, io_package null_constant instanceName schema_name, database_name, data_package_name' )

#
# this just tries to cover everything that's specific to 
#
class DatabaseAdapter:
        """
        Container for database - specific things like support for unicode, formats for timestamps
        """
        def __init__( self, doesUnicode, timestampDefault, tablePostText, supportsTextType ):
                self.doesUnicode = doesUnicode;
                self.supportsTextType = supportsTextType
                self.timestampDefault = timestampDefault
                self.tablePostText = tablePostText
                # next 2 not really needed as we can't handle blobs and clobs in 
                # odbc/ada anyway.
                self.longCharType = 'CLOB'
                self.longBinaryType = 'BLOB'
                self.databasePreamble = ''
                self.databasePostText = ''
                self.safeVariableNameLength = 60
                if( doesUnicode ):
                        self.supportedSqlCharType = 'SQL_C_WCHAR'
                else:
                        self.supportedSqlCharType = 'SQL_C_CHAR'

def getDatabaseAdapter( dataSource ):
        # FIXME we need to distinguish between a schema and database better (e.g. in Postgres)
        if( dataSource.databaseType == 'postgres' ):
                adapter = DatabaseAdapter( 0, "TIMESTAMP '1901-01-01 00:00:00.000000'", '', 1 );
                adapter.databasePreamble += 'drop database if exists ' + dataSource.database+";\n"
                adapter.databasePreamble += "create database "+ dataSource.database +" with encoding 'UTF-8';\n\n"
                # adapter.databasePreamble += "SET search_path="+dataSource.database +";\n"
                adapter.databasePreamble += "\c "+dataSource.database+";\n"
        elif( dataSource.databaseType == 'mysql' ):
                adapter = DatabaseAdapter( 0, "TIMESTAMP '0000-00-00 00:00:00.000000'", " type = InnoDB", 0 );
                adapter.longBinaryType = 'LONGTEXT' 
                adapter.longCharType = 'LONGTEXT'
                adapter.databasePreamble += 'drop database if exists ' + dataSource.database+";\n"
                adapter.databasePreamble += "SET NAMES utf8;\n";
                adapter.databasePreamble += "create database "+ dataSource.database +" default charset=utf8;\n\n"
                adapter.databasePreamble += "use "+ dataSource.database + ";\n";
                adapter.databasePreamble += "SET FOREIGN_KEY_CHECKS = 0;"
                adapter.databasePostText += "SET FOREIGN_KEY_CHECKS = 1;\n"
        elif( dataSource.databaseType == 'db2' ):  ## note that DB2 does actually support unicode, but this version jams it off everywhere.
                adapter = DatabaseAdapter( 0, "'1901-01-01 00:00:00.000000'", '', 0 );
                adapter.safeVariableNameLength = 18
                adapter.databasePreamble += "-- Disconnect from any existing database connection\n"
                adapter.databasePreamble += "CONNECT RESET;\n"
                adapter.databasePreamble += "DROP DATABASE " + dataSource.database+";\n"
                adapter.databasePreamble += "CREATE DATABASE " + dataSource.database + " USING CODESET UTF-8 TERRITORY UK;\n" 
                adapter.databasePreamble += "CONNECT TO "  + dataSource.database +";\n"
        elif( dataSource.databaseType == 'firebird' ):
                adapter = DatabaseAdapter( 0, "TIMESTAMP '1901-01-01 00:00:00'", '', 1 );
                adapter.databasePreamble += "CREATE DATABASE '%(db)s.fdb' page_size 8192 user '%(user)s' password '%(pass)s' DEFAULT CHARACTER SET UTF8;" % { 'db' : dataSource.database, 'pass' : dataSource.password, 'user' : dataSource.username }
                adapter.databasePreamble += "CONNECT '%(db)s.fdb' user %(user)s password %(pass)s;" % { 'db' : dataSource.database, 'pass' : dataSource.password, 'user' : dataSource.username }
        return adapter


## Supported types:
## CHAR VARCHAR (both mapped to varchar) DECIMAL REAL INTEGER DOUBLE BOOLEAN ENUM

def makeAdaDecimalTypeName( length, prec ):
        return 'Decimal_%(len)d_%(prec)d' % { 'len' : int(length), 'prec': int(prec) }                


        
def getDefaultSize( schemaType, size ):
        if( size != None ):
                return size
        return 1

def notNoneOrBlank( s ):
        return not ((s == None) or ( s == '' ))

def valIfNotNoneOrBlank( s, default ):
        if( notNoneOrBlank( s )):
                return s;
        return default;
        
class ArrayInfo:
        def __init__( 
                self,
                isExternallyDefined,
                arrayIndexIsExternallyDefined,
                arrayFirst, 
                arrayLast, 
                arrayIndexType, 
                arrayAdaIndexTypeName,  
                arrayEnumValues, 
                arrayName,
                dataType ):
                self.isExternallyDefined = isExternallyDefined 
                self.first = arrayFirst
                self.last = arrayLast
                self.indexType = arrayIndexType
                self.arrayIndexIsExternallyDefined = arrayIndexIsExternallyDefined
                self.adaIndexTypeName = arrayAdaIndexTypeName
                if self.indexType == 'ENUM':
                        # self.adaIndexTypeName += "_Enum" 
                        self.enumName = arrayAdaIndexTypeName
                self.enumValues = arrayEnumValues
                # print "got %d enums " % ( len(self.enumValues) )
                self.name = arrayName
                self.dataType = dataType
                if self.adaIndexTypeName == None:
                        self.adaIndexTypeName = 'Positive'
                if self.first == None:
                        if self.indexType == 'ENUM':
                                self.first = arrayEnumValues[0]
                        else:
                                self.first = 1
                if self.last == None:
                        if self.indexType == 'ENUM':
                                self.last = arrayEnumValues[-1]
                        else:
                                self.first = 1
                if self.indexType == 'ENUM':
                        p1 = arrayEnumValues.index( self.first )
                        p2 = arrayEnumValues.index( self.last )
                        self.length = 1 + ( p2 - p1 )  
                else:
                        self.last = int( self.last )
                        self.first = int( self.first )
                        self.length = 1 + self.last - self.first
        #      type AA_Type is array( Integer range<> ) of Long_Float;
        #      type AE_Type is array( AEnum range<> ) of Integer;
        #      package fp is new DB_Commons.Float_Mapper( Index => Integer, Data_Type=>Long_Float, Array_Type=>AA_Type );
        #      package dp is new DB_Commons.Discrete_Mapper( Index => AEnum, Data_Type=>Integer, Array_Type=>AE_Type );
        #      a : AA_Type( 1 .. 12 );
        
        def packageName( self ):
                return "%(arrayname)s_Package"%{ 'arrayname':self.name } 
             
        def packageDeclaration( self, isDiscrete ):
                floatOrDiscrete = 'Discrete' if isDiscrete else 'Float';
                return "package %(packagename)s is new %(floatOrDiscrete)s_Mapper( Index=> %(index)s, Data_Type=>%(datatype)s, Array_Type=> Abs_%(arraytype)s );" %\
                       { 'packagename': self.packageName(), 'adaname':self.name, \
                       'floatOrDiscrete':floatOrDiscrete, 'index':self.adaIndexTypeName, \
                       'datatype': self.dataType, 'arraytype':self.name }
                
        def rangeString( self ):
                if self.first == None and self.last == None:
                        s = self.indexType + "'Range"
                elif self.first != None and self.last == None:
                        s = self.first + " .. " + self.indexType + "'Last"
                elif self.first == None and self.last != None:
                        s = self.indexType + "'First .. " + self.last
                else:
                        s = str(self.first) + " .. " + str(self.last)
                return s
                
        def typeDeclaration( self, default ):
                out = {}
                if self.isExternallyDefined:
                        return {'',''}
                rangestr = self.rangeString()
                initstr = " := ( others => " + default + ")" 
                s1 = "type Abs_%s is array( %s range<> ) of %s;"%( self.name, self.adaIndexTypeName, self.dataType )
                s2 = "subtype %s is Abs_%s( %s );"%( self.name, self.name, rangestr )    
                return [s1,s2] 
                
                
        def sqlArrayDefaultDeclaration( self, default ):
                s = "array[ "
                for i in range( 0, self.length ):
                        s += default
                        if i < self.length-1:
                                s += ", "        
                s += " ]"   
                return s
                
        def arrayDeclaration( self, default ):
                return self.name + " := ( others => " + default + " )"
                
        def arrayFromStringDeclaration( self, varname ):
                return self.packageName() + ".SQL_Map_To_Array( s, " + varname+" )" 

        def stringFromArrayDeclaration( self, varname ):
                return self.packageName() + ".Array_To_SQL_String( " + varname + " )"
         
        def toStringDeclaration( self, varname ):
                return self.packageName() + ".To_String( " + varname + " )";
        

class Variable:
        
        def getODBCType( self, databaseAdapter ):
                odbcType = self.schemaType.lower()
                if self.schemaType == 'DECIMAL' :
                        odbcType = 'Long_Float' ## ocbc can handle extracting decimal cols as reals, which we can then cast into decimals
                elif self.schemaType == 'REAL' or self.schemaType == 'DOUBLE' or self.schemaType == 'FLOAT':
                        odbcType = 'Real'
                elif self.schemaType == 'CHAR' or self.schemaType == 'VARCHAR':
                        if databaseAdapter.doesUnicode :
                                odbcType = 'Wide_String';
                        else:
                                odbcType = 'String';
                elif ( self.isDateType() ):                                
                        odbcType = 'SQL_TIMESTAMP_STRUCT' 
                elif self.schemaType == 'ENUM' or self.schemaType == 'BOOLEAN' :
                        odbcType = 'Integer'
                elif self.schemaType == 'BIGINT':
                        odbcType = 'Big_Int'
                return odbcType

        def getSQLType( self, databaseAdapter ):
                if( self.isFloatingPointType() ):
                        sqlType = 'DOUBLE PRECISION'
                elif( self.schemaType == 'CHAR' or self.schemaType == 'VARCHAR' ):
                        if databaseAdapter.supportsTextType:
                                sqlType = 'TEXT'
                        else:
                                sqlType = 'VARCHAR('+str( self.size )+')'
                elif self.schemaType == 'DECIMAL' :
                        sqlType = 'DECIMAL(' + self.size+', '+ self.scale + ')'
                elif self.schemaType == 'BOOLEAN' or self.schemaType == 'ENUM' :
                        sqlType = 'INTEGER'
                elif self.schemaType == 'CLOB':
                        sqlType = databaseAdapter.longCharType
                elif self.schemaType == 'BLOB':
                        sqlType = databaseAdapter.longBinaryType
                elif self.isDateType():
                        sqlType = 'TIMESTAMP'
                else:
                        sqlType = self.schemaType;
                return sqlType
                
        def hasUserDefinedAdaType( self ):
                return not self.adaTypeName is None

        def getAdaType( self, useUserDefinedType ):
                adaType = self.schemaType.capitalize()
                if( self.hasUserDefinedAdaType() and useUserDefinedType ):
                        adaType = self.adaTypeName
                elif self.schemaType == 'DECIMAL' :
                        adaType = makeAdaDecimalTypeName( self.size, self.scale )
                elif self.schemaType == 'REAL' or self.schemaType == 'DOUBLE' or self.schemaType == 'FLOAT':
                        adaType = 'Long_Float'
                elif self.schemaType == 'CHAR' or self.schemaType == 'VARCHAR':
                        adaType = 'Unbounded_String';
                elif ( self.isDateType() ):                                
                        adaType = 'Ada.Calendar.Time' 
                elif self.schemaType == 'ENUM':  # FIXME we need to properly find the reference to the corresponding enumerated_type class here
                        adaType = self.tablename + "_" + self.varname # + "_Enum"
                elif self.schemaType == 'BIGINT':
                        adaType = 'Big_Int'
                return adaType

        
        def isDiscreteTypeInAda( self ):
                return self.schemaType == 'ENUM' or self.schemaType == 'BIGINT' or self.schemaType == 'INTEGER' or self.schemaType=='BOOLEAN'
        
        def isFloatingPointTypeInAda( self ):
                return self.schemaType == 'FLOAT' or self.schemaType == 'REAL' or self.schemaType=='DOUBLE'

        # always as a String
        def getDefaultAdaValue( self ):
                default = 'FIXME';
                if( self.default != None ) and ( self.default != '' ) and ( not self.isDateType()):
                        default = self.default
                        if( self.schemaType == 'CHAR') or (self.schemaType == 'VARCHAR'):
                                default = 'To_Unbounded_String( "'+default+'" )'
                        # print "returning with default value " + default
                        return default
                if( self.isPrimaryKey ):
                        if( not self.default is None ) and ( self.default != '' ):
                                if( self.schemaType == 'CHAR') or (self.schemaType == 'VARCHAR'):
                                        default = 'To_Unbounded_String( "'+self.default+'" )'
                                else:
                                        default = self.default
                        elif self.hasUserDefinedAdaType():
                                default = self.adaTypeName+"'First" 
                        elif( self.schemaType == 'CHAR') or (self.schemaType == 'VARCHAR'):
                                ## fixme maybe string instead?
                                default = 'MISSING_W_KEY'
                        elif self.schemaType == 'INTEGER' or self.schemaType == 'BIGINT':
                                default = 'MISSING_I_KEY'
                        elif self.isRealOrDecimalType() :
                                default = 'MISSING_R_KEY'
                        elif self.isDateType() :
                                default = 'MISSING_T_KEY'
                        elif (self.schemaType == 'ENUM'):
                                if( notNoneOrBlank( self.default )):
                                        default = self.values[ int( self.default ) ]
                                elif( len( self.values ) == 0 ):
                                        default = self.getAdaType( True ) + "'First"
                                else:
                                        default = self.values[0]
                                
                else:
                        if( self.schemaType == 'CHAR') or (self.schemaType == 'VARCHAR'):
                                default = 'Ada.Strings.Unbounded.Null_Unbounded_String'
                        elif (self.schemaType == 'DECIMAL') or (self.schemaType == 'REAL') or (self.schemaType == 'DOUBLE'):
                                default = valIfNotNoneOrBlank( self.default, '0.0' )
                                if( not re.match( '[0-9]+\.[0-9]+', default ) ):
                                        default += ".0"
                        elif (self.schemaType == 'BOOLEAN'): 
                                if( self.default is None ):
                                        default = 'false'
                                elif( self.default.upper() == 'TRUE' ) or ( self.default == "1" ):
                                        default = 'true'
                                else:
                                        default = 'false'
                        elif (self.schemaType == 'ENUM'):
                                if( notNoneOrBlank( self.default ) ):
                                        default = self.values[ int( self.default ) ]
                                elif( len( self.values ) == 0 ):
                                        default = self.adaTypeName + "'First";
                                else:
                                        default = self.values[0]
                                        
                        elif (self.schemaType == 'INTEGER' or self.schemaType == 'BIGINT' ):
                                default = valIfNotNoneOrBlank( self.default, '0' )
                        elif ( self.isDateType() ):                                
                                default = 'FIRST_DATE' 
                        else:
                                default = "'FIXME'";
                return default;      
                
        # FIXME defaults for booleans - handle true as 1 false as 0
        def getDefaultSQLValue( self, databaseAdapter ):
                if( self.default != None ) and ( self.default != '' ) and ( not self.isDateType()):
                        return self.default
                if( self.schemaType == 'CHAR') or (self.schemaType == 'VARCHAR'):
                        default = ''
                elif (self.schemaType == 'DECIMAL') or (self.schemaType == 'REAL') or (self.schemaType == 'DOUBLE'):
                        default = '0.0'
                elif (self.schemaType == 'BOOLEAN') or (self.schemaType == 'ENUM') or (self.schemaType == 'INTEGER') or  (self.schemaType == 'BIGINT'):
                        default = '0'
                elif ( self.isDateType() ):
                        default = databaseAdapter.timestampDefault
                else:
                        default = "''";
                return default
        
        def isRealOrDecimalType( self ):
                return ( self.schemaType == 'DECIMAL' ) or ( self.schemaType == 'REAL' ) or (self.schemaType == 'DOUBLE')
                
        def isDecimalType( self ):
                return ( self.schemaType == 'DECIMAL' ) 
        
        def isFloatingPointType( self ):
                return ( self.schemaType == 'REAL' ) or ( self.schemaType == 'DOUBLE' ) or ( self.schemaType == 'FLOAT' ) or ( self.schemaType == 'LONGFLOAT' )   
      
        def isNumericType( self ):
                return ( self.schemaType == 'DECIMAL' ) or ( self.schemaType == 'INTEGER' ) or ( self.schemaType == 'REAL' ) or (self.schemaType == 'DOUBLE')   

        def isIntegerType( self ):
                return ( self.schemaType == 'INTEGER' ) or ( self.schemaType == 'BIGINT' )   
                
        def isIntegerTypeInODBC( self ):
                return ( self.schemaType == 'INTEGER' ) or ( self.schemaType == 'BOOLEAN' ) or ( self.schemaType == 'ENUM' ) or ( self.schemaType == 'BIGINT' )
        
        def isStringType( self ):
                return (self.schemaType == 'CHAR') or (self.schemaType == 'VARCHAR'); 
        
        def addArray( self, arrayInfo ):
                self.arrayInfo = arrayInfo;
                if self.arrayInfo.name == None:
                        self.arrayInfo.name = self.name +"_Array";
                        
        def isDateType( self ):
                return (self.schemaType == 'TIMESTAMP') or (self.schemaType == 'TIME') or (self.schemaType == 'DATE')
        
        def __init__( self, databaseAdapter, tablename, varname, adaTypeName, schemaType, default, size, scale, description, autoIncrement, notNull, isPrimaryKey ):
                self.tablename = tablename
                self.varname = varname;
                self.adaTypeName = adaTypeName
                self.adaName = adafyName( varname ).lower()
                self.schemaType = upper( schemaType)
                self.default = default
                self.size = getDefaultSize( schemaType, size )                
                self.scale = scale
                self.description = description
                self.autoIncrement = autoIncrement
                self.adaType = self.getAdaType( True );
                self.sqlType = self.getSQLType( databaseAdapter );
                self.odbcType = self.getODBCType( databaseAdapter )
                self.notNull = notNull
                self.isPrimaryKey = isPrimaryKey
                self.enum = None
                if( self.schemaType == 'ENUM' ):
                        self.values = []
                self.arrayInfo = None                        
                
                

        def __repr__( self ):
                return "varname |%(varname)s| schemaType |%(schemaType)s| default |%(def)s| size |%(size)s| " % \
                        { 'varname': self.varname, 'schemaType' : self.sqlType, 'def' : self.default,
                          'size': self.size }

class DataSource:
        def __init__( self, id, databaseType, hostname, database, username, password ):
                self.id = id
                self.databaseType = databaseType
                self.hostname = hostname
                self.database = database
                self.username = username
                self.password = password                

        def __repr__( self ):
                return " id %(id)s databaseType %(databaseType)s hostname %(hostname)s, database %(database)s username %(username)s password %(password)s " % \
                       { 'id' : self.id, 'databaseType' : self.databaseType, 'hostname' : self.hostname, 'database' : self.database, 'username' : self.username, 'password': self.password }

class Table:
 
        # @param lang Format
        # @param qualificationLevel  'full schema unqualified' 
        # @param itemType table alist null_constant instanceName
        def makeName( self, format, qualificationLevel, itemType ):
                if format != Format.unformatted and not isNullOrBlank( self.adaExternalName ):
                        itemName = self.adaExternalName
                else:
                        itemName = self.name
                dotPos = itemName.rfind( '.' )
                if format == Format.ada:
                        itemName = adafyName( itemName )
                if itemType == ItemType.instanceName:
                        # itemName = itemName.replace( '.', '_' )
                        # hack - if we use name for some package stuff
                        if dotPos > 0:
                                itemName = itemName[ dotPos+1: ]
                        return 'a_' + str.lower( itemName )   
                elif itemType == ItemType.null_constant:
                        prefix = ''
                        if dotPos > 0: # handle some schema stuff in the name
                                prefix = itemName[ :dotPos+1 ]
                                itemName = itemName[ dotPos+1: ]
                        itemName = prefix+"Null_"+itemName
                elif itemType == ItemType.alist:
                        itemName += '_List'
                elif itemType == ItemType.list_container:
                        itemName += '_List_Package'
                elif itemType == ItemType.io_package:
                        itemName += '_IO'
                qualification = ''
                if qualificationLevel != Qualification.unqualified:
                        if notNullOrBlank( self.adaDataPackageName ) and format != Format.unformatted:
                                qualification = self.adaDataPackageName
                        else:
                                items = []   
                                if qualificationLevel == Qualification.full:
                                        items.append( self.databaseName )
                                if qualificationLevel == Qualification.schema or qualificationLevel == Qualification.full:
                                        items.append( self.schemaName )
                                if len( items ) > 0:
                                        qualification = concatList( items, '.' )
                        if format != Format.unformatted:
                                qualification = adafyName( qualification, spaceBetweenWords = False )
                if itemType != ItemType.schema_name and itemType != ItemType.database_name:
                        fullName = concatenate( qualification, itemName, '.' )
                else:
                        fullName = qualification
                                
                if format == Format.ada_filename:
                        fullName = nameToAdaFileName( fullName )
                return fullName
        
        def __init__( self, databaseName, schemaName, tableName, description, adaExternalName, adaDataPackageName ):
                print "creating table with name |"+tableName + "| adaExternalName |" +  adaExternalName;

                self.databaseName = databaseName
                self.schemaName = schemaName
                self.name = tableName
                self.description = description
                self.adaExternalName = adaExternalName
                self.adaDataPackageName = adaDataPackageName
                
                self.variables = []
                self.adaTypePackages = []
                self.primaryKey = []
                self.foreignKeys = []
                self.uniqueIndexes = []
                self.indexes = []
                
                self.decimalTypes = {}
                self.enumeratedTypes = {}
                self.description = description
                self.childRelations = {}
                print "at end of creation; self.adaIOPackageName |" + \
                      self.makeName( Format.ada, Qualification.unqualified, ItemType.io_package ) + \
                      "| self.makeName( Format.ada, Qualification.full, ItemType.list_container ) |" + self.makeName( Format.ada, Qualification.full, ItemType.list_container )
        
        def unqualifiedName( self ):
                if notNullOrBlank( self.adaExternalName ):
                        return self.adaExternalName
                return adafyName( self.name )
                
        def adaTypeName( self ):
                if notNullOrBlank( self.adaExternalName ):
                        return self.adaExternalName
                return adafyName( self.qualifiedName( "." ))
              
        def qualifiedName( self, sep='.' ):
                return concatenate( self.schemaName, self.name, sep )
                
        def getPrimaryKeyVariables( self ):
                vs = []
                for v in self.variables:
                        if( v.isPrimaryKey ):
                                vs.append( v )
                return vs
                
        def getNonPrimaryKeyVariables( self ):
                vs = []
                for v in self.variables:
                        if( not v.isPrimaryKey ):
                                vs.append( v )
                return vs
                

        def addChildRelation( self, fk ):
                # fk.parentSchemaName = schemaName
                self.childRelations[ fk.childTableName ] = fk
                
        def __repr__( self ):
                s = "table name %(name)s\n" % { 'name' : self.name }
                s += "variables \n";
                for var in self.variables:
                        s += "   %(var)s\n" % {'var' : var }
                s += "foreign keys \n";
                for k in self.foreignKeys:
                        s += "   %(k)s\n" % {'k' : k }
                s += "child relations \n";
                for k in self.childRelations:
                        s += "   %(k)s\n" % {'k' : k }
                s += "primary key\n";                
                for k in self.primaryKey:
                        s += "   %(k)s\n" % {'k' : k }
                        
                for d in self.decimalTypes:
                        s += "%(d)s\n" % { 'd' : d }
                return s;
                
        def hasPrimaryKey( self ):
                return len( self.primaryKey ) > 0;
                
        def hasForeignKeys( self ):
                return len( self.foreignKeys ) > 0;

        def hasUniqueIndexes( self ):
                return len( self.uniqueIndexes ) > 0;
                
        def hasIndexes( self ):
                return len( self.indexes ) > 0;
                
        def addVariable( self, varClass, isPrimary ):
                if( varClass.schemaType == 'DECIMAL' ):
                        dtype = DecimalType( varClass.size, varClass.scale );
                        self.decimalTypes[ dtype.ada_name ] = dtype
                elif( varClass.schemaType == 'ENUM' ):
                        etype = EnumeratedType( self.name, varClass.varname, varClass.adaTypeName, varClass.values )
                        self.enumeratedTypes[ etype.name ] = etype
                        ## fixme: short version only
                if varClass.arrayInfo != None:
                        if varClass.arrayInfo.indexType == 'ENUM' and not varClass.arrayInfo.arrayIndexIsExternallyDefined:
                                        etype = EnumeratedType(
                                                self.name,
                                                varClass.varname,
                                                varClass.arrayInfo.adaIndexTypeName,
                                                varClass.arrayInfo.enumValues )
                                        # print etype
                                        self.enumeratedTypes[ etype.name ] = etype
                self.variables.append( varClass );
                if( isPrimary ):
                        self.primaryKey.append( varClass.varname )
                        
        def addForeignKey( self, key ):
                self.foreignKeys.append( key )
                key.isOneToOne = ( key.hasSameElementsAs( self.primaryKey ))
                
        def addIndex( self, index ):
                self.indexes.append( index )
                
        def addUniqueIndex( self, index ):                
                self.uniqueIndexes.append( index )
                
                
class ForeignKey:
        
        def hasSameElementsAs( self, pk ):
                if( pk == None ):
                        return False
                return set(self.childCols) == set( pk )
                
        def inDifferentSchemas( self ):
                return self.parentSchemaName != self.childSchemaName
                
        def __init__( self, parentTableKey, childTable, onDelete, onUpdate ):
                self.childSchemaName = childTable.schemaName
                self.childTableName = childTable.name
                # if parentTableKey is xxx.yyy xxx is the schema yyy is tablename, else they are in the same schema
                matches = re.match( '(.*?)\.(.*)', parentTableKey ) 
                if matches != None:       
                        self.parentSchemaName = matches.group(1)
                        self.parentTableName = matches.group(2)
                else: 
                        self.parentTableName = parentTableKey
                        self.parentSchemaName = self.childSchemaName
                self.onDelete = onDelete
                self.onUpdate = onUpdate
                self.childCols = []
                self.parentCols = []
                self.isOneToOne = False
        
        def addReference( self, localName, foreignName ):
                self.childCols.append( localName)
                self.parentCols.append( foreignName )
                
        def __repr__( self ):
                s = "foreign key \nchildSchema: |%(childSchema)s| childTable: |%(childTable)s|\n"\
                    "parentSchema: |%(parentSchema)s| parentTable: |%(parentTable)s|\n"\
                    "onDelete %(onDelete)s " % \
                    { 'childSchema' : self.childSchemaName,
                      'childTable' : self.childTableName,
                      'parentSchema' : self.parentSchemaName,
                      'parentTable' : self.parentTableName,
                      'onDelete' : self.onDelete, 'onUpdate' : self.onUpdate }
                return s;
                
class Index:
        def __init__( self ):
                self.columns = []
                
class Unique:
        def __init__( self ):
                self.columns = []

class DecimalType:
        def __init__( self, length, prec ):
                self.length = int(length)
                self.prec = int(prec)
                self.delta = 1.0/(10**self.prec)
                self.ada_name = makeAdaDecimalTypeName( self.length, self.prec ) 
        
        def toAdaString( self ):
                return "type %(ada_name)s is delta %(delta)f digits %(digits)d" %\
                        { 'ada_name': self.ada_name, 'digits':self.length, 'delta': self.delta }
        
        def __repr__( self ):
                return "ada_name %(ada_name)s prec %(prec)d length %(length)d delta %(delta)f" %\
                        { 'ada_name': self.ada_name, 'prec':self.prec, 'length':self.length, 'delta': self.delta }   


class EnumeratedType:
        
        def __repr__( self ):
                return "name %(name)s adaTypeName %(adaTypeName)s " %\
                        { 'name': self.name, 'adaTypeName':self.adaTypeName }
                        
        def isExternallyDefined( self ):
                extern = ( not self.adaTypeName is None ) and len( self.values ) == 0
                return extern
        
        def __init__( self, table_name, name, adaTypeName, values = None ):
                self.name = table_name +'_' + name
                self.adaTypeName = adaTypeName
                if( not self.adaTypeName is None ):
                        self.name = self.adaTypeName
                self.values = []
                if( values != None ):
                        for value in values:
                                self.addValue( value )
           
        def toAdaString( self ):
                valueNames = []
                for v in self.values:
                        valueNames.append( v.value );
                valStr = ", ".join( valueNames );
                name = self.name
                #if name[-5:] != '_Enum':
                #        name += "_Enum"
                return "type " + name + " is ( " + valStr + " ) "; 
           
        def addValue( self, value, number = None, string = None ):
                if number == None:
                        number = len( self.values )
                if(isNullOrBlank( string ) ):
                        string = value
                self.values.append( EnumeratedValue( value, number, string ))
                
                
class EnumeratedValue:
        def __init__( self, value, number, string ):
                self.value = value
                self.number = number
                self.string = string
     
class TableContainer:
        
        def __init__( self, databaseName, schemaName = None ):
                self.databaseName = databaseName
                self.schemaName = schemaName
                self.tables = []
                self.tableLocations = {}
                
        def makeName( self, format, qualificationLevel, itemType ):
                item = ''
                if itemType == ItemType.schema_name:
                        if qualificationLevel == Qualification.full:
                                item = str.capitalize( concatenate( self.databaseName, self.schemaName ))
                        else:
                                item = str.capitalize( self.schemaName )
                elif itemType == ItemType.database_name:
                        item =  str.capitalize( self.databaseName )
                elif itemType == ItemType.data_package_name:
                        item =  str.capitalize( self.databaseName ) #+"_Data"
                if format == Format.ada:
                        item = str.capitalize( item )
                elif format == Format.ada_filename:
                        item = nameToAdaFileName( item )
                return item
                
        def addTable( self, table ):
                self.tables.append( table )
                self.tableLocations[ table.name ] = len( self.tables )-1 

        def getTable( self, name ):
                return self.tables[ self.tableLocations[ name ]]
                
        def fixUpForeignKeys( self, parentContainer = None ):
                for tab in self.tables:
                        for fk in tab.foreignKeys:
                                if fk.inDifferentSchemas():
                                        parentTable = parentContainer.getOneTable( fk.parentSchemaName, fk.parentTableName )
                                else:
                                        parentTable = self.getTable( fk.parentTableName )
                                parentTable.addChildRelation( fk )
     
class Schema( TableContainer ):
        def __init__( self, name, databaseName ):
                TableContainer.__init__( self, databaseName, name )
                
        def getAllTables( self, ignoreThis = True ):
                return copy.deepcopy( self.tables );
     
class Database( TableContainer ):
        
        def __init__( self, name, dataSource ):
                TableContainer.__init__( self, name, None )
                self.adaTypePackages = []
                self.adaTypePackagesCompleteSet = []
                self.dataSource = dataSource;
                self.decimalTypes = {}
                self.enumeratedTypes = {}
                self.description = ''
                self.schemas = []
                self.databaseAdapter = getDatabaseAdapter( self.dataSource )
                self.name = name,
                # self.databaseName = self.dataSource.database
                
             
        def getOneTable( self, schemaName, name ):
                if isNullOrBlank( schemaName ):
                        return self.getTable( name )
                # fix this: make schemas a hash
                for schema in self.schemas:
                        if schema.schemaName == schemaName:
                                return schema.getTable( name )
             
        def getAllTables( self, includeSchemas = True ):
                tables = copy.deepcopy( self.tables );
                if includeSchemas:
                        for s in self.schemas:
                                tables[ len( tables ):] = copy.deepcopy( s.tables )
                return tables
                
        def getArrayDeclarations( self ):
                arrays = []
                for t in self.getAllTables():
                        for v in t.variables:
                                if v.arrayInfo != None and not v.arrayInfo.isExternallyDefined :
                                        td = v.arrayInfo.typeDeclaration( v.getDefaultAdaValue() )
                                        arrays.append( td[0] );
                                        arrays.append( td[1] );
                return arrays;
                        
        def getArrayPackages( self ):
                pkgs = []
                for t in self.getAllTables():
                        for v in t.variables:
                                if v.arrayInfo != None:
                                        pkgs.append( v.arrayInfo.packageDeclaration( v.isDiscreteTypeInAda() ))                        
                return pkgs        
                
                
        def __repr__( self ):
                s = "name %(name)s \n" % { 'name' : self.name } 
                s += "============ DATASOURCE ==============\n";
                s += "%(ds)s " % { 'ds' : self.dataSource }
                s += "============ TABLES ==============\n";
                for t in self.getAllTables():
                        s += "%(t)s\n" % { 't' : t }
                s += "============ DECIMALS ==============\n";
                for d in self.decimalTypes:
                        s += "%(d)s\n" % { 'd' : d }
                        
                return s
                

def parseRuntimeSchema( xRuntime ):
        for datasource in xRuntime.iter("datasource"):
                databaseType = datasource.find("adapter").text
                connection = datasource.find("connection")
                hostname = connection.find( 'hostspec' ).text
                username = connection.find( 'username' ).text
                password = connection.find( 'password' ).text
                database = connection.find( 'database' ).text
                did = datasource.get( "id" )        
                return DataSource( did, databaseType, hostname, database, username, password )

def makeForeignKey( xfk, childTable ):
        parentTableKey = xfk.get( 'foreignTable' )
        onDelete = xfk.get( 'onDelete' )
        onUpdate = xfk.get( 'onUpdate' )
        if( isNullOrBlank( onDelete )):
                onDelete = 'cascade'
        if( isNullOrBlank( onUpdate )):
                onUpdate = 'cascade'
        fk = ForeignKey( parentTableKey, childTable, onDelete, onUpdate )
        for reference in xfk.iter( "reference" ):
                fk.addReference( reference.get( 'local' ),
                                 reference.get( 'foreign' ) );
        return fk


def tableToXML( table, document ):
        tableElem = etree.Element( "table" );
        tableElem.set( "name", table.name )
        tableElem.set( "description", table.description )
        tableElem.set( "adaExternalName", table.adaExternalName )
        for var in table.variables:
                varElem = etree.Element( "variable" )
                varElem.set( "name", var.varname ); 
                varElem.set( "type", var.schemaType );
                if( var.notNull ):
                        varElem.set( "required", "true" )                                
                if( var.default != None ) and ( var.default != '' ):
                        varElem.set( "default", var.default )
                if( var.size != None ) and ( var.size != 0 ) and ( var.size != '' ):
                        setIntAttribute( varElem, 'size', var.size )
                if( var.isPrimaryKey ):
                        varElem.set( 'primaryKey', 'true' )
                if( var.autoIncrement ):
                        varElem.set( 'autoIncrement', 'true' )
                varElem.set( 'description', var.description )
                # add array elements here
                if( var.scale != None ) and ( var.scale != 0 ) and ( var.scale != '' ):
                        setIntAttribute( varElem, 'scale', var.scale )
                tableElem.append( varElem )
        if( table.hasForeignKeys() ):
                for fk in table.foreignKeys:
                        fkElem = etree.Element( "foreign-key" )
                        fkElem.set( "foreignTable", fk.parentTableName )
                        if( (fk.onDelete != None) and (fk.onDelete != '' )):
                                fkElem.set( "onDelete", fk.onDelete )
                        if( (fk.onUpdate != None) and (fk.onUpdate != '' )):
                                fkElem.set( "onUpdate", fk.onUpdate )
                        for p in range( len( fk.childCols ) ):
                                refElem = etree.Element( "reference" )
                                refElem.set( "local", fk.childCols[p] );
                                refElem.set( "foreign", fk.parentCols[p] );                                
                                fkElem.append( refElem )
                        tableElem.append( fkElem )
        if table.hasIndexes():
                for index in table.indexes:
                        indexElem = etree.Element( "index" )
                        for col in index.columns:
                                colElem = etree.Element( "index-column" )
                                colElem.set( 'name', col )
                                indexElem.append( colElem )
                        tableElem.append( indexElem )
        if table.hasUniqueIndexes():
                for index in table.uniqueIndexes:
                        indexElem = etree.Element( "unique" )
                        for col in index.columns:
                                colElem = etree.Element( "unique-column" )
                                colElem.set( 'name', col )
                                indexElem.append( colElem )
                        tableElem.append( indexElem )
        return tableElem;
  
def databaseToXML( database ):
        dbElem = etree.Element( "database", name=database.databaseName )
        if( tab.adaDataPackage != None ):
                 packageElem = etree.Element( "adaDataPackage" )
                 packageElem.set( 'name', tab.adaDataPackage ) 
                 dbEleme.append( packageElem )
        for tab in database.tables:
                dbElem.append( tableToXML( tab, dbElem ))
        return dbElem
        
def get( elem, key, default ):
        a = elem.get( key )
        if(isNullOrBlank( a ) ):
                a = default;
        return a
  
def parseTable( xtable, databaseAdapter, databaseName, schemaName, adaDataPackageName ):
        """
        Parse a table from Propel XML
        """
        name = xtable.get( 'name' )
        description = xtable.get( 'description' )
        adaExternalName = get( xtable, 'adaExternalName', '' )
        if( isNullOrBlank( description )):
                description = ''
        stable = Table( databaseName       = databaseName, 
                        schemaName         = schemaName, 
                        tableName          = name, 
                        description        = description, 
                        adaExternalName    = adaExternalName,
                        adaDataPackageName = adaDataPackageName )
        defaultInstanceName = get( xtable, 'defaultInstanceName', '' )
        for column in xtable.iter( "column" ):
                varname = column.get( 'name' )
                stype = column.get( 'type' )
                adaTypeName = column.get( 'adaTypeName' )
                size = get( column, 'size', 1 );
                default = column.get( 'default' )
                isPrimary = column.get( 'primaryKey' ) == 'true'
                notNull = column.get( 'required' ) == 'true' or ( isPrimary )
                autoIncrement = get( column, 'autoIncrement', 'false' );
                description = get( column, 'description', '' );
                scale = get( column, 'scale', '' );
                var = Variable( 
                        databaseAdapter,
                        name,
                        varname,
                        adaTypeName,
                        stype,
                        default,
                        size,
                        scale,
                        description,
                        autoIncrement,
                        notNull,
                        isPrimary
                )
                var.isArray = column.get( 'isArray' ) == 'true'
                if( stype == 'ENUM' ):
                        valuesStr = column.get( 'values' )
                        if( notNoneOrBlank( valuesStr )):
                                var.values = valuesStr.split()
                if( var.isArray ):
                        isExternallyDefined = column.get( 'arrayIsExternallyDefined' ) == 'true'
                        arrayIndexIsExternallyDefined = column.get( 'arrayIndexIsExternallyDefined' ) == 'true'
                        arrayFirst = get( column, 'arrayFirst', 1 )
                        arrayLast = get( column, 'arrayLast', 1 )
                        arrayIndexType = column.get( 'arrayIndexType' )
                        arrayAdaIndexTypeName = column.get( 'arrayAdaIndexTypeName' )
                        arrayEnumValuesStr = column.get( 'arrayEnumValues' )
                        arrayEnumValues = []
                        if arrayEnumValuesStr != None:
                                arrayEnumValues = arrayEnumValuesStr.split()
                        arrayName = column.get( 'arrayName' )
                        arrayInfo = ArrayInfo( 
                                isExternallyDefined, 
                                arrayIndexIsExternallyDefined,
                                arrayFirst, 
                                arrayLast, 
                                arrayIndexType, 
                                arrayAdaIndexTypeName, 
                                arrayEnumValues, 
                                arrayName,
                                var.getAdaType( True )); 
                        var.addArray( arrayInfo )  
                        
                stable.addVariable( var, isPrimary )
        for ui in xtable.iter( "unique" ):
                stable.addUniqueIndex( makeUniqueIndex( ui ))
        for i in xtable.iter( "index" ):
                stable.addIndex( makeIndex( i ))
        for apackage in xtable.iter( "localAdaTypePackage" ):
                stable.adaTypePackages.append( apackage.get( 'name' ))
        stable.adaTypePackages = makeUniqueArray( stable.adaTypePackages )     
        for xfk in xtable.iter( "foreign-key" ):
                fk = makeForeignKey( xfk, stable )
                stable.addForeignKey( fk )
        return stable;

def makeUniqueIndex( xindex ):
        ind = Unique()
        for col in xindex.iter( "unique-column" ):
                ind.columns.append( col.get( 'name' ))
        return ind;
        
def makeIndex( xindex ):
        ind = Unique()
        for col in xindex.iter( "index-column" ):
                ind.columns.append( col.get( 'name' ))
        return ind;
        
def parseSchema( xschema, database ):
        name = xschema.get( 'name' )
        schema = Schema( name, database.databaseName )
        adaDataPackageName = ''
        for adp in xschema.xpath( "adaDataPackage" ):      
                adaDataPackageName = adp.get( 'name' )        
        for xtable in xschema.xpath( "table" ):
                table = parseTable( xtable = xtable, 
                                    databaseAdapter    = database.databaseAdapter, 
                                    databaseName       = database.databaseName, 
                                    schemaName         = name,
                                    adaDataPackageName = adaDataPackageName )
                database.adaTypePackagesCompleteSet += table.adaTypePackages
                database.decimalTypes.update( table.decimalTypes );
                database.enumeratedTypes.update( table.enumeratedTypes );
                database.adaTypePackagesCompleteSet = makeUniqueArray( database.adaTypePackagesCompleteSet );
                schema.addTable( table )
        return schema
                
def parseXMLFiles():
        runtimeSchema = etree.parse( WorkingPaths.Instance().xmlDir+'runtime-conf.xml' ).getroot()
        runtime = parseRuntimeSchema( runtimeSchema )
        dataDoc = etree.parse( WorkingPaths.Instance().xmlDir+'database-schema.xml')
        tablesSchema = dataDoc.getroot()
        databaseName = tablesSchema.xpath("/database/@name")[0]
        print "creating database " + databaseName
        database = Database( databaseName, runtime );
        
        for apackage in tablesSchema.iter( "adaTypePackage" ):
                database.adaTypePackages.append( apackage.get( 'name' ))
        adaDataPackageName = ''
        for adp in tablesSchema.xpath( "adaDataPackage" ):      
                adaDataPackageName = adp.get( 'name' )
        database.adaTypePackages = makeUniqueArray( database.adaTypePackages )     
        database.adaTypePackagesCompleteSet = database.adaTypePackages;
        for xtable in tablesSchema.xpath( "table" ):
                table = parseTable( 
                                xtable = xtable, 
                                databaseAdapter = database.databaseAdapter, 
                                databaseName = database.databaseName, 
                                schemaName=None,
                                adaDataPackageName = adaDataPackageName )
                database.addTable( table )
                database.decimalTypes.update( table.decimalTypes );
                database.enumeratedTypes.update( table.enumeratedTypes );
                database.adaTypePackagesCompleteSet += table.adaTypePackages
        for xschema in tablesSchema.xpath( "schema" ):
                schema = parseSchema( xschema, database )
                database.schemas.append( schema )
        database.fixUpForeignKeys()
        for schema in database.schemas:
                schema.fixUpForeignKeys( database )
        return database;
