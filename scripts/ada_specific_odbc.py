#
# copyrigh(c) 2007 Graham Stark (graham.stark@virtual-worlds.biz)
#
# ////////////////////////////////
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
# $Revision: 16199 $
# $Author: graham_s $
# $Date: 2013-06-11 17:45:20 +0100 (Tue, 11 Jun 2013) $
#
"""
 code to generate our ada .ads and .adb files, using Cheetah templating system
 for the most part
"""
from Cheetah.Template import Template
import datetime

from paths import WORKING_PATHS
from table_model import DataSource
from utils import makePlural, adafyName, makePaddedString, INDENT, MAXLENGTH, readLinesBetween
from ada_generator_libs import makeRetrieveSHeader, makeSaveProcHeader, makeUpdateProcHeader, \
     makeDeleteSpecificProcHeader, makeCriterionList, makePrimaryKeySubmitFields, \
     makePrimaryKeyCriterion, makeNextFreeHeader

CONNECTION_STRING = "connection : Database_Connection := Null_Database_Connection"

def templatesPath():
        return WORKING_PATHS.templatesPath+WORKING_PATHS.sep+'odbc'+WORKING_PATHS.sep;

def writeProjectFile( database ):
        outfile = file( WORKING_PATHS.etcDir + database.dataSource.database+'.gpr' , 'w' );
        template = Template( file=templatesPath() + 'project_file.tmpl' )
        template.date = datetime.datetime.now()
        template.projectName = adafyName(database.dataSource.database)
        outfile.write( str(template) )
        outfile.close()


def isIntegerTypeInODBC( variable ):
        return ( variable.schemaType == 'INTEGER' ) or ( variable.schemaType == 'BOOLEAN' ) or ( variable.schemaType == 'ENUM' ) or ( self.schemaType == 'BIGINT' )


def makeBinding( databaseAdapter, var, pos ):
        """
         ODBC binding declarations for each type we support,
        
         The rules here come from much trial end error and digging around on
         the microsoft ODBC site.
        """
        posStr = `pos`
        if( var.isIntegerTypeInODBC()):
                print "integer binding for |" + var.adaName + "| sqlType=|" + var.sqlType + "| "
                if var.sqlType == "BIGINT":
                        binding = INDENT*2 + "dodbc.L_Out_Binding.SQLBindCol(\n";
                else:
                        binding = INDENT*2 + "dodbc.I_Out_Binding.SQLBindCol(\n";
                binding += INDENT*4 + "StatementHandle  => ps,\n"
                binding += INDENT*4 + "ColumnNumber     => "+posStr+",\n"
                binding += INDENT*4 + "TargetValue      => "+ var.adaName+"'access,\n"
                binding += INDENT*4 + "IndPtr           => "+ var.adaName+"_len'access )"   
        elif( var.isStringType() ):
                charType = databaseAdapter.supportedSqlCharType
                binding = INDENT*2 + "SQLBindCol(\n";
                binding += INDENT*4 + "StatementHandle  => ps,\n"
                binding += INDENT*4 + "ColumnNumber     => "+posStr+",\n"
                binding += INDENT*4 + "TargetType       => " + charType + ",\n" 
                binding += INDENT*4 + "TargetValuePtr   => To_SQLPOINTER( "+ var.adaName+"_access.all'address ),\n"
                binding += INDENT*4 + "BufferLength     => "+ var.adaName + "_len,\n"
                binding += INDENT*4 + "StrLen_Or_IndPtr => "+ var.adaName + "_len'access )"   
        elif( var.isNumericType() ):
                binding = INDENT*2 + "SQLBindCol(\n";
                binding += INDENT*4 + "StatementHandle  => ps,\n"
                binding += INDENT*4 + "TargetType       => SQL_C_DOUBLE,\n"
                binding += INDENT*4 + "ColumnNumber     => "+posStr+",\n"
                binding += INDENT*4 + "TargetValuePtr   => To_SQLPOINTER( "+ var.adaName+"_access.all'address ),\n"
                binding += INDENT*4 + "BufferLength     => 0,\n"
                binding += INDENT*4 + "StrLen_Or_IndPtr => "+ var.adaName+"_len'access )"
        elif ( var.isDateType() ):
                binding = INDENT*2 + "SQLBindCol(\n";
                binding += INDENT*4 + "StatementHandle  => ps,\n"
                binding += INDENT*4 + "TargetType       => SQL_C_TYPE_TIMESTAMP,\n"
                binding += INDENT*4 + "ColumnNumber     => "+posStr+",\n"
                binding += INDENT*4 + "TargetValuePtr   => To_SQLPOINTER( "+ var.adaName+"_access.all'address ),\n"
                binding += INDENT*4 + "BufferLength     => 0,\n"
                binding += INDENT*4 + "StrLen_Or_IndPtr => "+ var.adaName+"_len'access )"
        else:
                binding = "FIXME: MISSED BINDING FOR VAR " + var.varname
        return binding;
                    
def makeRetrieveSFunc( table, database ):
        """
         table - Table class from table_model.py
         database - complete enclosuing Database model from  table_model.py
         
         Make a fuction that, for a given table (say 'fred'), takes an sql string as input (just the query part)
         and returns a single  
         list of fred records (fred_list, as declared in the main database declarations ads file). 
         This version has wide_string handling jammed off
         Structure is: 
            - declare local versions of all fred's variables
            - declare aliases (pointers) to these variables, where needed
            - declare length holders for each one
            - make the query by appending the query part to a constant 'select part'
            - prepare the query
            - bind variables/aliase
            - execute 
            - loop round, map the locals to one record
            --    add the variable to the collection
        
         There's a certain amount of trial an error in this..
        """
        template = Template( file=templatesPath()+"retrieve_wstr.func.tmpl" )       
        template.functionHeader = makeRetrieveSHeader( table, CONNECTION_STRING, ' is' )
        template.listType = table.adaQualifiedListName
        template.variableDecl = table.adaInstanceName + " : " + table.adaQualifiedOutputRecord
        template.addToMap = table.adaQualifiedContainerName+".append( l, "+ table.adaInstanceName +" )"
        template.aliasDeclarations = []
        template.pointers = []
        template.lenDeclarations = []
        template.mappingsFromAliasToRecord = []
        template.bindings = []
        pos = 0
        for var in table.variables:
                pos += 1
                alias = var.adaName + ": aliased " + var.odbcType;
                if( var.isStringType() ):
                        isize  = int(var.size);
                        string_padd = '@' * isize
                        alias += " := " + makePaddedString( 4, string_padd, isize ) 
                template.aliasDeclarations.append( alias );
                len_decl = var.adaName + "_len : aliased SQLLEN := " + var.adaName+"'Size";
                template.lenDeclarations.append( len_decl )
                binding = makeBinding( database.databaseAdapter, var, pos ) 
                template.bindings.append( binding )
                if( var.isRealOrDecimalType() or var.isDateType() or var.isStringType() ): ## NOTE: is String type is only because we're trying wide_strings here, otherwise 
                        if( var.isRealOrDecimalType() ):                                   ## there's a simple SQLBind version that doens't need any of this
                                pointer = var.adaName + "_access : Real_Access := "+var.adaName+"'access"
                                mapping = table.adaInstanceName + "." + var.adaName + ":= " + var.adaType + "( "+var.adaName + "_access.all )"                                
                        elif( var.isDateType()):
                                pointer = var.adaName + "_access : Timestamp_Access := "+var.adaName+"'access"
                                mapping = table.adaInstanceName + "." + var.adaName + ":= dodbc.Timestamp_To_Ada_Time( "+var.adaName + "_access.all )"
                        if( var.isStringType() ):    
                                mapping = table.adaInstanceName + "." + var.adaName + " := Slice_To_Unbounded( " + var.adaName + ", 1, Natural( "+var.adaName+"_len ) )"
                                pointer = var.adaName + "_access : String_Access := "+var.adaName+"'access"
                                
                        template.pointers.append( pointer )
                else:  ## integer/enum types
                        if( var.schemaType == 'ENUM' ):
                                mapping = table.adaInstanceName + "." + var.adaName + " := "+ var.adaType+"'Val( " + var.adaName + " )"
                        elif( var.schemaType == 'BOOLEAN' ):
                                mapping = table.adaInstanceName + "." + var.adaName + " := Boolean'Val( " + var.adaName + " )"
                        else:
                                mapping = table.adaInstanceName + "." + var.adaName + " := " + var.adaName 
                template.mappingsFromAliasToRecord.append( mapping )                        
        s = str(template) 
        return s

def getDBAdsWiths():
        return ["DB_Commons.ODBC"] 

def getDBWiths():
        """
        Add any packages that need to be imported into the body of each
        retrieve function.
        """
        return ["GNU.DB.SQLCLI",
                "GNU.DB.SQLCLI.Bind",
                "GNU.DB.SQLCLI.Info",
                "GNU.DB.SQLCLI.Environment_Attribute",
                "GNU.DB.SQLCLI.Connection_Attribute" ]

def getDBRenames():
        """
        Add a dict containing to=>from renames used in the io bodies
        """
        return { "sql": "GNU.DB.SQLCLI",
                 "dodbc": "DB_Commons.ODBC",
                 "sql_info": "GNU.DB.SQLCLI.Info" };

def getDBUses():
        """
        Add any packages that are globally used in the IO bodies
        """
        return [ "Base_Types", "GNU.DB.SQLCLI" ];

def makeNextFreeFunc( table, var ):
        """
        Make a function that finds the next highest value of
        an integer field; used to auto-increment inserts for integer parts of a primary key
        """
        template = Template( file=templatesPath()+"get_next_free.func.tmpl" )
        template.functionHeader = makeNextFreeHeader( var, CONNECTION_STRING, ' is' )
        template.statement = "select max( "+var.varname+" ) from "+table.name
        template.functionName = "Next_Free_"+var.adaName
        template.adaName = var.adaName
        template.adaType = var.getAdaType( True )
        if( var.sqlType == 'BIGINT' ):
                template.whichBinding = 'L'
        else:
                template.whichBinding = 'I'
        s = str(template) 
        return s

def makeDeleteProcBody( table ):
        template = Template( file=templatesPath()+"delete.func.tmpl" )
        return str( template )        


def makeDriverCommons():
        """
        Write versions of support files  db_commons-odbc to src/
        We just add some headers to each; otherwise they're uncustomised.
        """
        targets = [ 'db_commons-odbc' ]
        exts = [ 'adb', 'ads' ]
        for target in targets:
                for ext in exts:
                        outfileName = WORKING_PATHS.srcDir + target+"."+ext
                        template = Template( file=templatesPath()+target+"."+ext+"."+"tmpl" )
                        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
                        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
                        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
                        template.date = datetime.datetime.now()
                        outfile = file( outfileName, 'w' );
                        outfile.write( str(template) )
                        outfile.close()
                        

def writeConnectionPoolADB():
        outfileName = WORKING_PATHS.srcDir + 'connection_pool.adb'
        template = Template( file=templatesPath()+"connection_pool.adb.tmpl" )
        template.date = datetime.datetime.now()
        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )

        outfile = file( outfileName, 'w' );
        outfile.write( str(template) )
        outfile.close() 

def writeConnectionPoolADS():
        outfileName = WORKING_PATHS.srcDir+ 'connection_pool.ads'
        template = Template( file=templatesPath()+"connection_pool.ads.tmpl" )
        template.date = datetime.datetime.now()

        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
        
        outfile = file( outfileName, 'w' );
        outfile.write( str(template) )
        outfile.close()
        
        
        
def makeUpdateProcBody( table ):
        template = Template( file=templatesPath()+"update.func.tmpl" )
        template.procedureHeader = makeUpdateProcHeader( table, CONNECTION_STRING, ' is' )
        template.pkCriteria = makeCriterionList( table, 'pk_c', 'primaryKeyOnly', True )
        template.inputCriteria = makeCriterionList( table, 'values_c', 'allButPrimaryKey', True )
        return str(template) 

def makeSaveProcBody( table ):
        template = Template( file=templatesPath()+"save.func.tmpl" )
        template.procedureHeader = makeSaveProcHeader( table, CONNECTION_STRING, ' is' )
        template.allCriteria = makeCriterionList( table, 'c', 'all', True )
        primaryKey = makePrimaryKeySubmitFields( table )
        template.tmpVariable = table.adaInstanceName + "_tmp"
        template.existsCheck = 'if( not is_Null( '+table.adaInstanceName + '_tmp )) then'
        template.updateCall = 'Update( '+ table.adaInstanceName + ', local_connection )'
        template.tmpVariableWithAssignment = table.adaInstanceName + "_tmp : " + table.adaQualifiedOutputRecord;
        template.has_pk = table.hasPrimaryKey()
        template.retrieveByPK = table.adaInstanceName + '_tmp := retrieve_By_PK( ' + primaryKey + ' )'
        s = str(template) 
        return s        
        
def makeErrorCheckingCode():
        """
        not needed as lots of exception handling in each routine
        """
        return ""
