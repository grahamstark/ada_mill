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

CONNECTION_STRING = "connection : Database_Connection := null"


def templatesPath():
        return WORKING_PATHS.templatesPath+WORKING_PATHS.sep+'postgres'+WORKING_PATHS.sep;

def writeProjectFile( database ):
        outfile = file( WORKING_PATHS.etcDir + database.dataSource.database+'.gpr' , 'w' );
        template = Template( file=templatesPath() + 'project_file.tmpl' )
        template.date = datetime.datetime.now()
        template.projectName = adafyName(database.dataSource.database)
        outfile.write( str(template) )
        outfile.close()

def isIntegerTypeInPostgres( variable ):
        return ( variable.schemaType == 'INTEGER' ) or ( variable.schemaType == 'BOOLEAN' ) or ( variable.schemaType == 'ENUM' ) or ( variable.schemaType == 'BIGINT' )


def makeValueFunction( variable, posStr, default_value=None ):
        """
        single prec real integer or subtype: use native function
        else use Type'Value( getTheString( ))
        """
        defstr = '' 
        if( default_value != None ):
                posStr = posStr + ", " + default_value
        if( variable.hasUserDefinedAdaType()):
                v =  variable.adaTypeName + "'Value( gse.Value( cursor, " + posStr + " ));\n"               
        elif( variable.schemaType == 'BIGINT' ):
                v = "Long_Integer'Value( gse.Value( cursor, " + posStr + " ));\n"
        elif( variable.schemaType == 'BOOLEAN' ):
                v = "gse.Boolean_Value( cursor, " + posStr + " ));\n"
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
        if( isIntegerTypeInPostgres( var )):
                binding = INDENT*4 + "if not gse.Is_Null( cursor, " + posStr + " )then\n"
                if( var.schemaType == 'ENUM' ) or ( var.schemaType == 'BOOLEAN' ):
                        binding += INDENT*5 + "declare\n"
                        binding += INDENT*6 + "i : constant Integer := gse.Integer_Value( cursor, " + posStr + " );\n"
                        binding += INDENT*5 + "begin\n"
                        if( var.schemaType == 'ENUM' ):
                                binding += INDENT*6 + instanceName+'.'+var.adaName + " := " + var.adaType+"'Val( i );\n";
                        else:                                
                                binding += INDENT*6 + instanceName+'.'+var.adaName + " := Boolean'Val( i );\n";
                        binding += INDENT*5 + "end;"
                else:
                        binding += INDENT*5 + instanceName+'.'+var.adaName + " := " + makeValueFunction( var, posStr ); # var.adaType + "( gse.Integer_Value( cursor, " + posStr + " ));\n"
                binding += INDENT*4 + "end if;"
        elif( var.isStringType() ):
                charType = databaseAdapter.supportedSqlCharType
                binding = INDENT*4 + "if not gse.Is_Null( cursor, " + posStr + " )then\n"
                binding += INDENT*5 + instanceName+'.'+var.adaName + ":= To_Unbounded_String( gse.Value( cursor, " + posStr + " ));\n" 
                binding += INDENT*4 + "end if;"
        elif( var.isNumericType() ):
                binding = INDENT*4 + "if not gse.Is_Null( cursor, " + posStr + " )then\n"
                binding += INDENT*5 + instanceName+'.'+var.adaName + ":= " + makeValueFunction( var, posStr ); # var.adaType + "( gse.Float_Value( cursor, " + posStr + " ));\n"
                binding += INDENT*4 + "end if;"
        elif ( var.isDateType() ):
                binding = INDENT*4 + "if not gse.Is_Null( cursor, " + posStr + " )then\n"
                binding += INDENT*5 + instanceName+'.'+var.adaName + " := gse.Time_Value( cursor, " + posStr + " );\n" 
                binding += INDENT*4 + "end if;"
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
        template = Template( file=templatesPath()+"retrieve_wstr.func.tmpl" )       
        template.functionHeader = makeRetrieveSHeader( table, CONNECTION_STRING, ' is' )
        template.listType = table.adaQualifiedListName
        template.addToMap = "l.append( "+ table.adaInstanceName +" )"
        template.bindings = []
        template.adaInstanceName = table.adaInstanceName
        template.variableDecl = table.adaInstanceName + " : " + table.adaQualifiedOutputRecord
        
        pos = 0
        for var in table.variables:
                binding = makeBinding( database.databaseAdapter, table.adaInstanceName, var, pos ) 
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
                "GNATCOLL.SQL.Postgres" ]

def getDBRenames():
        """
        Add a dict containing to=>from renames used in the io bodies
        """
        return { "gsi" : "GNATCOLL.SQL_Impl",
                 "gse" : "GNATCOLL.SQL.Exec",
                 "gsp" : "GNATCOLL.SQL.Postgres" };

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
        template.statement = "select max( "+var.varname+" ) from "+table.name
        template.functionName = "Next_Free_"+var.adaName
        template.adaName = var.adaName
        template.adaType = var.getAdaType( True )
        template.getFunction = makeValueFunction( var, "0", "0" )
        if( var.sqlType == 'BIGINT' ):
                template.whichBinding = 'L'
        else:
                template.whichBinding = 'I'
        s = str( template ) 
        return s
  
def makeDeleteProcBody( table ):
        template = Template( file=templatesPath()+"delete.func.tmpl" )
        return str( template )        
  
def makeDriverCommons():
        """
        This does nothing! Needed for compatibility with odbc version
        Write versions of support files db_commons, db_commons-psql to src/
        We just add some headers to each; otherwise they're uncustomised.
        """
        return
       
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
