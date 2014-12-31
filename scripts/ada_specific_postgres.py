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

import paths
from table_model import DataSource, Format, Qualification, ItemType
from utils import makePlural, adafyName, makePaddedString, INDENT, MAXLENGTH, readLinesBetween
from ada_generator_libs import makeRetrieveSHeader, makeSaveProcHeader, makeUpdateProcHeader, \
     makeDeleteSpecificProcHeader, makeCriterionList, makePrimaryKeySubmitFields, \
     makePrimaryKeyCriterion, makeNextFreeHeader

CONNECTION_STRING = "connection : Database_Connection := null"


def templatesPath():
        return paths.getPaths().templatesPath+paths.getPaths().sep+'postgres'+paths.getPaths().sep;

def writeProjectFile( database ):
        outfile = file( paths.getPaths().etcDir + database.databaseName+'.gpr' , 'w' );
        template = Template( file=templatesPath() + 'project_file.tmpl' )
        template.date = datetime.datetime.now()
        template.projectName = adafyName(database.databaseName)
        outfile.write( str(template) )
        outfile.close()

def makeMapFromCursorHeader( adaQualifiedOutputRecord ):
        return INDENT + "function Map_From_Cursor( cursor : GNATCOLL.SQL.Exec.Forward_Cursor ) return " + adaQualifiedOutputRecord +";"  

# FIXME these next 2 are actually the same for all Native DB interfaces, not just postgres
def makePreparedInsertStatementHeader():
        return '   function Get_Prepared_Insert_Statement return GNATCOLL.SQL.Exec.Prepared_Statement;'        

def makePreparedRetrieveStatementHeaders():
        o = []
        o.append( 'function Get_Prepared_Retrieve_Statement return GNATCOLL.SQL.Exec.Prepared_Statement;' )
        o.append( 'function Get_Prepared_Retrieve_Statement( sqlstr : String ) return GNATCOLL.SQL.Exec.Prepared_Statement;' )
        o.append( 'function Get_Prepared_Retrieve_Statement( crit : d.Criteria ) return GNATCOLL.SQL.Exec.Prepared_Statement;' )
        return o        

        
def makePreparedRetrieveStatementBodies( table ):
        statements = []
        template = Template( file=templatesPath() + 'prepared_retrieve_statement.tmpl' )
        template = Template( file=templatesPath() + 'prepared_retrieve_statement.tmpl' )
        pk_queries = []
        p = 0
        for var in table.getPrimaryKeyVariables():
                p += 1
                pk_queries.append( "${0:s} = ${1:d}".format( var.varname, p ))
        template.pkText = " and ".join( pk_queries )
        template.tableName = table.qualifiedName()
        return str( template )
        

def makePreparedInsertStatementBody( table ):
        template = Template( file=templatesPath() + 'prepared_insert_statement.tmpl' )
        queries = []
        p = 0
        for var in table.variables:
                p += 1
                queries.append( "${0:d}".format( p ))
        template.posIndicators = ", ".join( queries )
        return str(template)

def makeConfiguredParamsHeader( templateName, variableList ):
        comments = []
        template = Template( file=templatesPath() + templateName + '.tmpl' )
        p = 0
        for var in variableList:
                p += 1
                if var.arrayInfo != None:
                        typ = 'Parameter_Text'
                        default = 'null' #'"'+var.arrayInfo.sqlArrayDefaultDeclaration( var.getDefaultAdaValue() )+'"'
                elif( isIntegerTypeInPostgres( var )):
                        typ = 'Parameter_Integer'
                        default = '0'
                elif( var.isStringType() ):
                        typ = 'Parameter_Text'
                        default = 'null';
                elif( var.isNumericType() ):
                        typ = 'Parameter_Float'
                        default = '0.0'
                elif ( var.isDateType() ):
                        typ = 'Parameter_Date'
                        default = 'Clock'
                s = '{:>4d} : {:<24} : {:<18} : {:<20} : {:>8} '.format( p, var.adaName, typ, var.adaType, default )
                comments.append( s )
        template.n = p 
        template.comments = comments;
        return str( template );


def makeConfiguredRetrieveParamsHeader( table ):
        variables = table.getPrimaryKeyVariables()
        return makeConfiguredParamsHeader( 'configured_retrieve_params_header', variables );

def makeConfiguredInsertParamsHeader( table ):
        return makeConfiguredParamsHeader( 'configured_insert_params_header', table.variables );
       
def makeConfiguredParamsBody( templateName, variableList ):        
        template = Template( file=templatesPath() + templateName + '.tmpl' )
        p = 0
        n = len( variableList )
        rows = []
        for var in variableList:
                p += 1
                if var.arrayInfo != None:
                        typ = 'Parameter_Text'
                        default = 'null' #'"'+var.arrayInfo.sqlArrayDefaultDeclaration( var.getDefaultAdaValue() )+'"'
                elif isIntegerTypeInPostgres( var ):
                        typ = 'Parameter_Integer'
                        default = '0'
                elif var.isStringType():
                        typ = 'Parameter_Text'
                        default = 'null';
                elif var.isNumericType():
                        typ = 'Parameter_Float'
                        default = '0.0'
                elif var.isDateType():
                        typ = 'Parameter_Date'
                        default = 'Clock'
                s = '        {0:>2d} => ( {1:s}, {2:s} )'.format( p, typ, default )
                if( p < n ):
                        s += ","
                s += "   -- " + " : " + var.adaName + " (" + var.adaType +")" 
                rows.append( s )
        template.n = p
        template.rows = rows
        return str(template)


def makeConfiguredRetrieveParamsBody( table ):
        variables = table.getPrimaryKeyVariables()        
        return makeConfiguredParamsBody( 'configured_retrieve_params', variables );        

def makeConfiguredInsertParamsBody( table ):
        return makeConfiguredParamsBody( 'configured_insert_params', table.variables );        
        

def isIntegerTypeInPostgres( variable ):
        return ( variable.schemaType == 'INTEGER' ) or ( variable.schemaType == 'BOOLEAN' ) or ( variable.schemaType == 'ENUM' ) or ( variable.schemaType == 'BIGINT' )


def makeValueFunction( variable, posStr, default_value=None ):
        """
        single prec real integer or subtype: use native function
        else use Type'Value( getTheString( ))
        """
        defstr = '' 
        if( default_value != None ):
                if not ( variable.hasUserDefinedAdaType() or variable.schemaType == 'BIGINT' or variable.isFloatingPointType() or variable.isStringType()):
                        # posStr = posStr + ", \"" + default_value+'"'
                        # no defaults for pure 'value'
                        # fixme add a clause
                        posStr = posStr + ", " + default_value
        if( variable.hasUserDefinedAdaType()):
                v =  variable.adaTypeName + "'Value( gse.Value( cursor, " + posStr + " ));\n" 
        elif( variable.isDecimalType() ):
                v = variable.adaType+"'Value( gse.Value( cursor, " + posStr + " ));\n" 
        elif( variable.schemaType == 'BIGINT' ):
                v = "Big_Int'Value( gse.Value( cursor, " + posStr + " ));\n"
        elif( variable.schemaType == 'BOOLEAN' ):
                v = "gse.Boolean_Value( cursor, " + posStr + " );\n"
                needsCasting = 0
        elif( variable.schemaType == 'INTEGER' ) or ( variable.schemaType == 'ENUM' ): 
                v = "gse.Integer_Value( cursor, " + posStr + " );\n"
        elif( variable.isFloatingPointType() ): 
                v = variable.adaType+"'Value( gse.Value( cursor, " + posStr + " ));\n"
        elif( variable.isDateType() ):
                v = "gse.Time_Value( cursor, " + posStr + " );\n"
        elif( variable.isStringType() ):
                v = "gse.Value( cursor, " + posStr + " );\n"
        return v;
        
        
def makeBinding( databaseAdapter, instanceName, var, pos ):
        """
         Postgres binding declarations for each type we support,
        
        """
        posStr = `pos`
        if var.arrayInfo != None:
                varname = instanceName+'.'+var.adaName
                binding = INDENT*2 + "if not gse.Is_Null( cursor, " + posStr + " )then\n"
                binding += INDENT*3 + "declare\n"
                binding += INDENT*4 + "s : constant String := gse.Value( cursor, " + posStr + " );\n"
                binding += INDENT*3 + "begin\n"
                binding += INDENT*4 + var.arrayInfo.arrayFromStringDeclaration( varname ) + ";\n";
                binding += INDENT*3 + "end;\n"
                binding += INDENT*2 + "end if;"
        elif isIntegerTypeInPostgres( var ):
                binding = INDENT*2 + "if not gse.Is_Null( cursor, " + posStr + " )then\n"
                if( var.schemaType == 'ENUM' ):
                        binding += INDENT*3 + "declare\n"
                        binding += INDENT*4 + "i : constant Integer := gse.Integer_Value( cursor, " + posStr + " );\n"
                        binding += INDENT*2 + "begin\n"
                        if( var.schemaType == 'ENUM' ):
                                binding += INDENT*4 + instanceName+'.'+var.adaName + " := " + var.adaType+"'Val( i );\n";
                        binding += INDENT*4 + "end;\n"
                else:
                        binding += INDENT*3 + instanceName+'.'+var.adaName + " := " + makeValueFunction( var, posStr ); # var.adaType + "( gse.Integer_Value( cursor, " + posStr + " ));\n"
                binding += INDENT*2 + "end if;"
        elif( var.isStringType() ):
                charType = databaseAdapter.supportedSqlCharType
                binding = INDENT*2 + "if not gse.Is_Null( cursor, " + posStr + " )then\n"
                binding += INDENT*3 + instanceName+'.'+var.adaName + ":= To_Unbounded_String( gse.Value( cursor, " + posStr + " ));\n" 
                binding += INDENT*2 + "end if;"
        elif( var.isNumericType() ):
                binding = INDENT*2 + "if not gse.Is_Null( cursor, " + posStr + " )then\n"
                binding += INDENT*3 + instanceName+'.'+var.adaName + ":= " + makeValueFunction( var, posStr ); # var.adaType + "( gse.Float_Value( cursor, " + posStr + " ));\n"
                binding += INDENT*2 + "end if;"
        elif ( var.isDateType() ):
                binding = INDENT*2 + "if not gse.Is_Null( cursor, " + posStr + " )then\n"
                binding += INDENT*3 + instanceName+'.'+var.adaName + " := gse.Time_Value( cursor, " + posStr + " );\n" 
                binding += INDENT*2 + "end if;"
        else:
                binding = "FIXME: MISSED BINDING FOR VAR " + var.varname
        return binding;

def makeErrorCheckingCode():
        template = Template( file=templatesPath()+"check_result.func.tmpl" )       
        return str( template );

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
        instanceName = table.makeName( Format.ada, Qualification.unqualified, ItemType.instanceName )
        outputRecord = table.makeName( Format.ada, Qualification.full, ItemType.table )
        template = Template( file=templatesPath()+"retrieve_wstr.func.tmpl" )       
        template.functionHeader = makeRetrieveSHeader( table, CONNECTION_STRING, ' is' )
        template.listType = table.makeName( Format.ada, Qualification.full, ItemType.alist )
        template.addToMap = "l.append( "+ instanceName +" )"
        template.bindings = []
        template.adaInstanceName = instanceName
        template.variableDecl = instanceName + " : " + outputRecord
        template.adaQualifiedOutputRecord = outputRecord
        
        pos = 0
        for var in table.variables:
                binding = makeBinding( database.databaseAdapter, instanceName, var, pos ) 
                pos += 1
                template.bindings.append( binding )                                        
        s = str(template) 
        return s

def getDBAdsWiths():
        return ["GNATCOLL.SQL.Exec"] 


def getDBWiths():
        """
        Add any packages that need to be imported into the body of each
        retrieve function.
        """
        return ["GNATCOLL.SQL_Impl",
                "GNATCOLL.SQL.Postgres",
                "DB_Commons.PSQL"]

def getDBRenames():
        """
        Add a dict containing to=>from renames used in the io bodies
        """
        return { "gsi" : "GNATCOLL.SQL_Impl",
                 "gse" : "GNATCOLL.SQL.Exec",
                 "gsp" : "GNATCOLL.SQL.Postgres",
                 "dbp" : "DB_Commons.PSQL"};

def getDBUses():
        """
        Add any packages that are globally used in the IO bodies
        """
        return [ "Base_Types" ];

def makeNextFreeFunc( table, var ):
        """
        Make a function that finds the next highest value of
        an integer field; used to auto-increment inserts for integer parts of a primary key
        """
        template = Template( file=templatesPath()+"get_next_free.func.tmpl" )
        template.functionHeader = makeNextFreeHeader( var, CONNECTION_STRING, ' is' )
        template.statement = "select coalesce( max( "+var.varname+" ) + 1, 1 ) from %{SCHEMA}"+table.qualifiedName()
        template.functionName = "Next_Free_"+var.adaName
        template.adaName = var.adaName
        template.default = var.getDefaultAdaValue()
        template.adaType = var.getAdaType( True )
        template.getFunction = makeValueFunction( var, "0", "0" )
        return str( template );
  
def makeDeleteProcBody( table ):
        template = Template( file=templatesPath()+"delete.func.tmpl" )
        return str( template )        
  
def makeDriverCommons():
        """
        """
        targets = [ 'db_commons-psql' ]
        exts = [ 'adb', 'ads' ]
        for target in targets:
                for ext in exts:
                        outfileName = paths.getPaths().srcDir + target+"."+ext
                        template = Template( file=templatesPath()+target+"."+ext+"."+"tmpl" )
                        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
                        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
                        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
                        template.date = datetime.datetime.now()
                        outfile = file( outfileName, 'w' );
                        outfile.write( str(template) )
                        outfile.close()
        
        return
       
def writeConnectionPoolADB():
        outfileName = paths.getPaths().srcDir + 'connection_pool.adb'
        template = Template( file=templatesPath()+"connection_pool.adb.tmpl" )
        template.date = datetime.datetime.now()
        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )

        outfile = file( outfileName, 'w' );
        outfile.write( str(template) )
        outfile.close() 

def writeConnectionPoolADS():
        outfileName = paths.getPaths().srcDir+ 'connection_pool.ads'
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
        instanceName = table.makeName( Format.ada, Qualification.unqualified, ItemType.instanceName )
        outputRecord = table.makeName( Format.ada, Qualification.full, ItemType.table )
        template = Template( file=templatesPath()+"save.func.tmpl" )
        template.procedureHeader = makeSaveProcHeader( table, CONNECTION_STRING, ' is' )
        template.allCriteria = makeCriterionList( table, 'c', 'all', True )
        primaryKey = makePrimaryKeySubmitFields( table )
        template.tmpVariable = instanceName + "_tmp"
        template.existsCheck = 'if( not is_Null( ' + instanceName + '_tmp )) then'
        template.updateCall = 'Update( '+ instanceName + ', local_connection )'
        template.tmpVariableWithAssignment = instanceName + "_tmp : " + outputRecord;
        template.has_pk = table.hasPrimaryKey()
        template.retrieveByPK = instanceName + '_tmp := retrieve_By_PK( ' + primaryKey + ' )'
        s = str(template) 
        return s        
