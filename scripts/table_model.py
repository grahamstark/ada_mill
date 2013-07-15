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
# $Revision: 16115 $
# $Author: graham_s $
# $Date: 2013-05-23 17:08:53 +0100 (Thu, 23 May 2013) $
#
from string import upper
import re
from string import capwords

# from xml.dom.minidom import parse
# import xml

from XMLUtils import setIntAttribute

from lxml import etree

from utils import adafyName, makePlural, makeUniqueArray

from paths import WORKING_PATHS

#
# this just tries to cover everything that's specific to 
#
class DatabaseAdapter:
        """
        Container for database - specific things like support for unicode, formats for timestamps
        """
        def __init__( self, doesUnicode, timestampDefault, tablePostText ):
                self.doesUnicode = doesUnicode;
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
        
        if( dataSource.databaseType == 'postgres' ):
                adapter = DatabaseAdapter( 0, "TIMESTAMP '1901-01-01 00:00:00.000000'", '' );
                adapter.databasePreamble += 'drop database if exists ' + dataSource.database+";\n"
                adapter.databasePreamble += "create database "+ dataSource.database +" with encoding 'UTF-8';\n\n"
                adapter.databasePreamble += "\c "+dataSource.database+";\n"
        elif( dataSource.databaseType == 'mysql' ):
                adapter = DatabaseAdapter( 0, "TIMESTAMP '0000-00-00 00:00:00.000000'", " type = InnoDB" );
                adapter.longBinaryType = 'LONGTEXT' 
                adapter.longCharType = 'LONGTEXT'
                adapter.databasePreamble += 'drop database if exists ' + dataSource.database+";\n"
                adapter.databasePreamble += "SET NAMES utf8;\n";
                adapter.databasePreamble += "create database "+ dataSource.database +" default charset=utf8;\n\n"
                adapter.databasePreamble += "use "+ dataSource.database + ";\n";
                adapter.databasePreamble += "SET FOREIGN_KEY_CHECKS = 0;"
                adapter.databasePostText += "SET FOREIGN_KEY_CHECKS = 1;\n"
        elif( dataSource.databaseType == 'db2' ):  ## note that DB2 does actually support unicode, but this version jams it off everywhere.
                adapter = DatabaseAdapter( 0, "'1901-01-01 00:00:00.000000'", '' );
                adapter.safeVariableNameLength = 18
                adapter.databasePreamble += "-- Disconnect from any existing database connection\n"
                adapter.databasePreamble += "CONNECT RESET;\n"
                adapter.databasePreamble += "DROP DATABASE " + dataSource.database+";\n"
                adapter.databasePreamble += "CREATE DATABASE " + dataSource.database + " USING CODESET UTF-8 TERRITORY UK;\n" 
                adapter.databasePreamble += "CONNECT TO "  + dataSource.database +";\n"
        elif( dataSource.databaseType == 'firebird' ):
                adapter = DatabaseAdapter( 0, "TIMESTAMP '1901-01-01 00:00:00'", '' );
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



class Variable:
        
        def getODBCType( self, databaseAdapter ):
                odbcType = self.schemaType.lower()
                if self.schemaType == 'DECIMAL' :
                        odbcType = 'Real' ## ocbc can handle extracting decimal cols as reals, which we can then cast into decimals
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
                        odbcType = 'Big_Integer'
                return odbcType

        def getSQLType( self, databaseAdapter ):
                if( self.isFloatingPointType() ):
                        sqlType = 'DOUBLE PRECISION'
                elif( self.schemaType == 'CHAR' or self.schemaType == 'VARCHAR' ):
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
                        adaType = 'Real'
                elif self.schemaType == 'CHAR' or self.schemaType == 'VARCHAR':
                        adaType = 'Unbounded_String';
                elif ( self.isDateType() ):                                
                        adaType = 'Ada.Calendar.Time' 
                elif self.schemaType == 'ENUM':  # FIXME we need to properly find the reference to the corresponding enumerated_type class here
                        adaType = self.tablename + "_" + self.varname + "_Enum"
                elif self.schemaType == 'BIGINT':
                        adaType = 'Big_Integer'
                return adaType

        

        # always as a String
        def getDefaultAdaValue( self ):
                default = 'FIXME';
                if( self.isPrimaryKey ):
                        if( self.schemaType == 'CHAR') or (self.schemaType == 'VARCHAR'):
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
                return ( self.schemaType == 'REAL' ) or (self.schemaType == 'DOUBLE')   
      
        def isNumericType( self ):
                return ( self.schemaType == 'DECIMAL' ) or ( self.schemaType == 'INTEGER' ) or ( self.schemaType == 'REAL' ) or (self.schemaType == 'DOUBLE')   

        def isIntegerType( self ):
                return ( self.schemaType == 'INTEGER' ) or ( self.schemaType == 'BIGINT' )   
        
        def isIntegerTypeInODBC( self ):
                return ( self.schemaType == 'INTEGER' ) or ( self.schemaType == 'BOOLEAN' ) or ( self.schemaType == 'ENUM' ) or ( self.schemaType == 'BIGINT' )
        
        def isStringType( self ):
                return (self.schemaType == 'CHAR') or (self.schemaType == 'VARCHAR'); 
        
        def isDateType( self ):
                return (self.schemaType == 'TIMESTAMP') or (self.schemaType == 'TIME') or (self.schemaType == 'DATE')
        
        def __init__( self, databaseAdapter, tablename, varname, adaTypeName, schemaType, default, size, scale, description, autoIncrement, notNull, isPrimaryKey ):
                self.tablename = tablename
                self.varname = varname;
                self.enum = None
                self.adaTypeName = adaTypeName
                self.adaName = adafyName( varname )
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
                if( self.schemaType == 'ENUM' ):
                        self.values = []
                
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
        def __init__( self, name, description, adaExternalName ):
                self.variables = []
                self.adaTypePackages = []
                self.primaryKey = []
                self.foreignKeys = []
                self.uniqueIndexes = []
                self.indexes = []
                self.name = name
                self.adaExternalName = adaExternalName
                self.adaInstanceName = adafyName( name ).lower()
                if( self.adaExternalName != '' ):
                        self.adaTypeName = adaExternalName
                else:
                        self.adaTypeName = adafyName( name ) + "_Type"
                self.adaNullName = 'Null_' + self.adaTypeName 
                self.adaIOPackageName = self.adaTypeName+"_IO";
                self.adaContainerName = self.adaTypeName+"_List"
                self.adaListName = self.adaTypeName+"_List.Vector"                
                self.decimalTypes = {}
                self.enumeratedTypes = {}
                self.description = description
                self.childRelations = {}
                
        def fixupNames( self, dataPackageName ):
                if( self.adaExternalName == '' ):
                        self.adaQualifiedOutputRecord = dataPackageName + "." + self.adaTypeName
                        self.adaQualifiedListName = dataPackageName + "." + self.adaListName
                        self.adaQualifiedNullName = dataPackageName + "." + self.adaNullName
                        self.adaQualifiedContainerName = dataPackageName + "." + self.adaContainerName
                else:
                        self.adaQualifiedOutputRecord = self.adaTypeName
                        self.adaQualifiedListName = self.adaListName
                        self.adaQualifiedNullName = self.adaNullName
                        self.adaQualifiedContainerName = self.adaContainerName
                        

        def addChildRelation( self, fk, name ):
                self.childRelations[ name ] = fk
                
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
                return set(self.localCols) == set( pk )
                
        def __init__( self, referencingTable, onDelete, onUpdate ):
                self.referencingTable = referencingTable
                self.onDelete = onDelete
                self.onUpdate = onUpdate
                self.localCols = []
                self.foreignCols = []
                self.isOneToOne = False
        
        def addReference( self, localName, foreignName ):
                self.localCols.append(localName)
                self.foreignCols.append(foreignName)
                
        def __repr__( self ):
                s = "foreign key referencing table %(reftable)s onDelete %(onDelete)s " % { 'reftable' : self.referencingTable, 'onDelete' : self.onDelete, 'onUpdate' : self.onUpdate }
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
        
        def isExternallyDefined( self ):
                return ( not self.adaTypeName is None ) and len( self.values ) == 0
        
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
                return "type "+self.name+"_Enum is ( " + valStr + " ) "; 
           
        def addValue( self, value, number = None, string = None ):
                if number == None:
                        number = len( self.values )
                if( string == None ):
                        string = value
                self.values.append( EnumeratedValue( value, number, string ))
                
                
class EnumeratedValue:
        def __init__( self, value, number, string ):
                self.value = value
                self.number = number
                self.string = string
     
class Database:
        def __init__( self, dataSource ):
                self.adaTypePackages = []
                self.adaTypePackagesCompleteSet = []
                
                self.tables = []
                self.dataSource = dataSource;
                self.decimalTypes = {}
                self.enumeratedTypes = {}
                self.tableLocations = {}
                self.adaDataPackageName = adafyName( self.dataSource.database )+"_Data"; 
                self.description = ''
                self.name = ''
                self.databaseAdapter = getDatabaseAdapter( self.dataSource )
                
        def addTable( self, table ):
                self.tables.append( table )
                self.tableLocations[ table.name ] = len( self.tables )-1 
                self.decimalTypes.update( table.decimalTypes );
                self.enumeratedTypes.update( table.enumeratedTypes );

        def getTable( self, name ):
                return self.tables[ self.tableLocations[ name ]]
                
        def fixUpForeignKeys( self ):
                for tab in self.tables:
                        for fk in tab.foreignKeys:
                                targetTable = self.tables[ self.tableLocations[ fk.referencingTable ] ]
                                targetTable.addChildRelation( fk, tab.name )
                
        def __repr__( self ):
                s = "============ DATASOURCE ==============\n";
                s += "%(ds)s " % { 'ds' : self.dataSource }
                s += "============ TABLES ==============\n";
                for t in self.tables:
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

def makeForeignKey( xfk ):
        referencingTable = xfk.get( 'foreignTable' )
        onDelete = xfk.get( 'onDelete' )
        onUpdate = xfk.get( 'onUpdate' )
        if( onDelete == None ):
                onDelete = 'cascade'
        if( onUpdate == None ):
                onUpdate = 'cascade'
        fk = ForeignKey( referencingTable, onDelete, onUpdate )
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
                if( var.scale != None ) and ( var.scale != 0 ) and ( var.scale != '' ):
                        setIntAttribute( varElem, 'scale', var.scale )
                tableElem.append( varElem )
        if( table.hasForeignKeys() ):
                for fk in table.foreignKeys:
                        fkElem = etree.Element( "foreign-key" )
                        fkElem.set( "foreignTable", fk.referencingTable )
                        if( (fk.onDelete != None) and (fk.onDelete != '' )):
                                fkElem.set( "onDelete", fk.onDelete )
                        if( (fk.onUpdate != None) and (fk.onUpdate != '' )):
                                fkElem.set( "onUpdate", fk.onUpdate )
                        for p in range( len( fk.localCols ) ):
                                refElem = etree.Element( "reference" )
                                refElem.set( "local", fk.localCols[p] );
                                refElem.set( "foreign", fk.foreignCols[p] );                                
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
        dbElem = etree.Element( "database", name=database.name )
        for tab in database.tables:
                dbElem.append( tableToXML( tab, dbElem ))
        return dbElem
        
def get( elem, key, default ):
        a = elem.get( key )
        if( a == None ):
                a = default;
        return a
  
def parseTable( xtable, databaseAdapter ):
        """
        Parse a table from Propel XML
        """
        name = xtable.get( 'name' )
        description = xtable.get( 'description' )
        adaExternalName = get( xtable, 'adaExternalName', '' )
        if( description == None ):
                description = ''
        stable = Table( name, description, adaExternalName )
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
                if( stype == 'ENUM' ):
                        valuesStr = column.get( 'values' )
                        if( notNoneOrBlank( valuesStr )):
                                var.values = valuesStr.split()
                
                stable.addVariable( var, isPrimary )
        for fk in xtable.iter( "foreign-key" ):
                stable.addForeignKey( makeForeignKey( fk ) )
        for ui in xtable.iter( "unique" ):
                stable.addUniqueIndex( makeUniqueIndex(ui) )
        for i in xtable.iter( "index" ):
                stable.addIndex( makeIndex(i) )
        for apackage in xtable.iter( "localAdaTypePackage" ):
                stable.adaTypePackages.append( apackage.get( 'name' ))
        stable.adaTypePackages = makeUniqueArray(  stable.adaTypePackages )     
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

def parseXMLFiles():
        runtimeSchema = etree.parse( WORKING_PATHS.xmlDir+'runtime-conf.xml' ).getroot()
        runtime = parseRuntimeSchema( runtimeSchema )
        database = Database( runtime );
        tablesSchema = etree.parse( WORKING_PATHS.xmlDir+'database-schema.xml').getroot()
        for apackage in tablesSchema.iter( "adaTypePackage" ):
                database.adaTypePackages.append( apackage.get( 'name' ))
        
        database.adaTypePackages = makeUniqueArray( database.adaTypePackages )     
        print "database.adaTypePackages"
        print database.adaTypePackages
        database.adaTypePackagesCompleteSet = database.adaTypePackages;
        for db in tablesSchema.iter("database"):
                database.name = db.get( 'name' ) 
        for table in tablesSchema.iter( "table" ):
                stable = parseTable( table, database.databaseAdapter )
                stable.fixupNames( database.adaDataPackageName )
                database.addTable( stable )
                database.adaTypePackagesCompleteSet += stable.adaTypePackages
        database.adaTypePackagesCompleteSet = makeUniqueArray( database.adaTypePackagesCompleteSet );

        database.fixUpForeignKeys()
        return database;
