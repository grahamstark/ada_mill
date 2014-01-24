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
# $Revision: 16198 $
# $Author: graham_s $
# $Date: 2013-06-11 16:09:32 +0100 (Tue, 11 Jun 2013) $
#
"""
 code to generate our ada .ads and .adb files, using Cheetah templating system
 for the most part
"""
from Cheetah.Template import Template
import datetime
from sys_targets import TARGETS
from paths import WORKING_PATHS
from table_model import DataSource
from utils import makePlural, adafyName, makePaddedString, \
        INDENT, MAXLENGTH, readLinesBetween, makeUniqueArray, \
        packageNameToFileName
from ada_generator_libs import makeRetrieveSHeader, makeSaveProcHeader, \
        makeUpdateProcHeader, makeDeleteSpecificProcHeader, makeCriterionList, \
        makePrimaryKeyCriterion, makeNextFreeHeader, makeDeleteSpecificProcBody

def makeAddOrderingColumnDecl( var, ending ):
        s = "procedure Add_"+var.adaName+"_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc )" + ending
        return s

def makeAddOrderingColumnBody( var ):
        template = Template( file=WORKING_PATHS.templatesPath+"add_to_criterion_ordering.func.tmpl" )
        template.header = makeAddOrderingColumnDecl( var, ' is' )
        template.criterion = 'elem : d.Order_By_Element := d.Make_Order_By_Element( "'+ var.varname + '", direction  )'
        template.functionName = "Add_"+var.adaName+"_To_Orderings"
        s = str(template) 
        return s

def makeUpdateStatement( table ):
        print ""
        

def makeInsertStatement( table ):
        s = "insert into "+table.name+" values( "

def makeCastStatement( var ):
        if( var.hasUserDefinedAdaType() ):
                return var.getAdaType( False ) + "( " + var.adaName + " )"
        else:
                return var.getAdaType( True )

def makeCriteriaDecl( var, isString, ending ):
        if( isString ):
                adaType = 'String'
        else:
                adaType = var.getAdaType( True )
        return "procedure Add_"+var.adaName+"( c : in out d.Criteria; "+var.adaName+" : "+ adaType +"; op : d.operation_type:= d.eq; join : d.join_type := d.join_and )" + ending
        
def makePrimaryKeySubmitFields( table ):
        pks = []
        for var in table.variables:
                if( var.isPrimaryKey ):
                        pks.append( table.adaInstanceName + '.' + var.adaName  )
        return ', '.join( pks )
        

def makeCriteriaBody( var, isString = False ):
        if( isString ):
                adaType = 'String'
        else:
                adaType = var.getAdaType( True )
        template = Template( file=WORKING_PATHS.templatesPath+"add_to_criterion.func.tmpl" )
        if(( var.schemaType == 'BOOLEAN' ) or ( var.schemaType == 'ENUM' )):
                value = "Integer( " + adaType+"'Pos( "+var.adaName +" ))"
        elif( adaType == 'Unbounded_String' ):
                value = "To_String( "+var.adaName +" )"
        elif( var.hasUserDefinedAdaType() ):
                value = makeCastStatement( var )
        else:
                value = var.adaName
        # handle decimals from generic functions, one per decimal type; these are declared locally to the current package
        #
        if var.isDecimalType():
                function = "make_criterion_element_"+adaType
        else:   # .. otherwise, use the default versions in the db_commons package, aliased as 'd' here
                function = 'd.make_Criterion_Element';                
        s = 'elem : d.Criterion := '+ function + '( "'+ var.varname +'", op, join, '+ value 
        if var.isStringType():
                s += ", " + str( var.size ) ## the length of the sql variable, so we 
        template.criterion = s +" )" 
        template.header = makeCriteriaDecl( var, isString, ' is' )
        template.adaName = var.adaName
        s = str(template) 
        return s
  
def makePKHeader( table, connection_string, ending ):
        pks = []
        for var in table.variables:
                if( var.isPrimaryKey ):
                        pks.append( var.adaName + " : " + var.adaType )
        pkFields = '; '.join( pks )
        return "function Retrieve_By_PK( " + pkFields + "; " + connection_string + " ) return " + table.adaQualifiedOutputRecord + ending
        
def makePKBody( table, connection_string ):
        template = Template( file=WORKING_PATHS.templatesPath+"retrieve_pk.func.tmpl" )
        if( table.hasPrimaryKey()):                                
                template.functionHeader = makePKHeader( table, connection_string, ' is' )
        template.listType = table.adaQualifiedListName
        template.variableDecl = table.adaInstanceName + " : " + table.adaQualifiedOutputRecord 
        template.primaryKeyCriteria = makeCriterionList( table, 'c', 'primaryKeyOnly', False )
        template.getNullRecord = table.adaInstanceName + " := " +  table.adaQualifiedNullName
        template.getFirstRecord = table.adaInstanceName + " := " + table.adaQualifiedContainerName+ ".First_Element( l )"
        template.notEmpty = "not "+ table.adaQualifiedContainerName +".is_empty( l )" 
        template.adaName = table.adaInstanceName
        s = str(template) 
        return s


def makeIsNullFunc( table, adaDataPackageName ):
        template = Template( file=WORKING_PATHS.templatesPath+"is_null.func.tmpl" )       
        template.adaName = table.adaTypeName
        template.functionHeader = makeIsNullFuncHeader( table, ' is' )
        template.returnStatement = 'return '+table.adaInstanceName + ' = ' + table.adaQualifiedNullName
        template.use = "use "+adaDataPackageName
        template.nullName = table.adaQualifiedNullName
        s = str(template) 
        return s
        
def makeIsNullFuncHeader( table, ending ):
        return "function Is_Null( "+ table.adaInstanceName + " : " + table.adaQualifiedOutputRecord+ " ) return Boolean"+ending;

def makeRetrieveCHeader( table, connection_string, ending ):
        return "function Retrieve( c : d.Criteria; " + connection_string + " ) return " + table.adaQualifiedListName +ending

def makeRetrieveCFunc( table, connection_string ):
        template = Template( file=WORKING_PATHS.templatesPath+"retrieve_by_c.func.tmpl" )
        template.functionHeader = makeRetrieveCHeader( table, connection_string, ' is' )
        s = str(template) 
        return s
        

def makeChildRetrieveHeader( table, referencingTableName, packagedAdaName, connection_string, ending ):
        return "function Retrieve_Child_"+referencingTableName+"( " + table.adaInstanceName + " : " + table.adaQualifiedOutputRecord +"; " + connection_string + ") return " + packagedAdaName+ending

def makeChildRetrieveBody( table, referencingTable, fk, connection_string ):
        """
        If the table has a foreign key with the same primary key,
        add a function that retrieves the single record in the referencing table
        referred to by the table primary key. 
        """
        template = Template( file=WORKING_PATHS.templatesPath+"retrieve_child.func.tmpl" )
        template.functionHeader = makeChildRetrieveHeader( table, referencingTable.adaTypeName, referencingTable.adaQualifiedOutputRecord, connection_string, ' is' )
        template.functionName = "Retrieve_Child_"+ referencingTable.adaTypeName
        referencePackage = referencingTable.adaTypeName + "_IO"
        localPK = []
        for p in range( len( fk.localCols ) ):
                localName = table.adaInstanceName +"."+ adafyName(fk.localCols[p])
                localPK.append( localName )
        localPKValues = ', '.join( localPK )
        template.returnStatement = "return " + referencePackage + ".retrieve_By_PK( "+localPKValues + ", connection )"
        s = str(template) 
        return s


def makeAssociatedRetrieveHeader( table, referencingTableName, listAdaName, connection_string, ending ):
        return "function Retrieve_Associated_"+ makePlural( referencingTableName )+"( " +  table.adaInstanceName + " : " + table.adaQualifiedOutputRecord +"; " + connection_string + " ) return " + listAdaName+ending

def makeAssociatedRetrieveBody( table, referencingTable, fk, connection_string ): # Name, listAdaName, fk ):
        template = Template( file=WORKING_PATHS.templatesPath+"retrieve_associated.func.tmpl" )
        referencingTableName = referencingTable.adaTypeName
        template.functionHeader = makeAssociatedRetrieveHeader( table, referencingTableName, referencingTable.adaQualifiedListName, connection_string, ' is' )
        template.allCriteria = []
        template.functionName = "Retrieve_Associated_"+ makePlural( referencingTableName )
        referencePackage = referencingTableName + "_IO"
        template.returnStatement = "return " + referencePackage + ".retrieve( c, connection )"
        for p in range( len( fk.localCols ) ):
                # note these are the other way around from how you'd think of it
                # since the foriegn key is originally a property of the referencing table
                # not the table we're on (if you see what I mean).
                localName = adafyName( fk.localCols[p] )
                foreignName = adafyName( fk.foreignCols[p] )
                crit = referencePackage+".Add_"+localName+"( c, " + table.adaInstanceName+"."+foreignName + " )"
                template.allCriteria.append( crit )
        s = str(template) 
        return s



def make_io_ads( database, adaTypePackages, table ):
        if TARGETS.binding == 'odbc':
                import ada_specific_odbc as asp
        elif TARGETS.binding == 'native':
                if TARGETS.databaseType == 'postgres':
                        import ada_specific_postgres as asp
                elif TARGETS.databaseType == 'sqlite':
                        import ada_specific_sqlite as asp

        dataPackageName = database.adaDataPackageName();
        outfileName = (WORKING_PATHS.srcDir+table.adaTypeName+'_io.ads').lower()
        template = Template( file=WORKING_PATHS.templatesPath+"io.ads.tmpl" )
        template.connectionString = asp.CONNECTION_STRING        
        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
        template.IOName = table.adaTypeName+"_IO"
        template.dbWiths = asp.getDBAdsWiths();
        template.IOName_Upper_Case = (table.adaTypeName+"_IO").upper()
        template.criteria = []
        template.nullName = table.adaQualifiedNullName;
        template.orderingStatements = []
        template.incr_integer_pk_fields = []
        template.adaTypePackages = makeUniqueArray( adaTypePackages + table.adaTypePackages )
        for var in table.variables:
                template.orderingStatements.append(makeAddOrderingColumnDecl( var, ';' ));
                template.criteria.append( makeCriteriaDecl( var, False, ';' ))
                if( var.isStringType() ):
                        template.criteria.append( makeCriteriaDecl( var , True, ';' ))
                if( var.isPrimaryKey ):
                        if( var.isIntegerType() ):
                                template.incr_integer_pk_fields.append( makeNextFreeHeader( var, asp.CONNECTION_STRING, ';' ));
        
        if( table.hasPrimaryKey()):                                
                template.pkFunc = makePKHeader( table, asp.CONNECTION_STRING, ';' )
        else:
                template.pkFunc = ''
        template.isNullFunc = makeIsNullFuncHeader( table, ';' );
        template.retrieveByCFunc = makeRetrieveCHeader( table, asp.CONNECTION_STRING, ';' );
        template.retrieveBySFunc = makeRetrieveSHeader( table, asp.CONNECTION_STRING, ';' );
        template.saveFunc = makeSaveProcHeader( table, asp.CONNECTION_STRING, ';' );
        template.deleteSpecificFunc = makeDeleteSpecificProcHeader( table, asp.CONNECTION_STRING, ';' );
        template.outputRecordType = table.adaQualifiedOutputRecord
        template.outputRecordName = table.adaTypeName
        template.associated = []
        template.date = datetime.datetime.now()
        for name in table.childRelations:
                fk = table.childRelations[ name ]
                referencedTable =  database.getTable( name );
                # referencingTableName = referencedTable.adaQualifiedOutputRecord
                referencingTableName = referencedTable.adaTypeName
                if( fk.isOneToOne ):
                        packagedAdaName = dataPackageName+"."+referencingTableName;
                        childFunc = makeChildRetrieveHeader( table, referencingTableName, referencedTable.adaQualifiedOutputRecord, asp.CONNECTION_STRING, ';' )
                        template.associated.append( childFunc );
                else:
                        # listAdaName = dataPackageName+"."+referencingTableName+"_List.Vector"
                        listAdaName = referencedTable.adaListName;
                        assocFunc = makeAssociatedRetrieveHeader( table, referencingTableName, referencedTable.adaQualifiedListName, asp.CONNECTION_STRING, ';' )
                        template.associated.append( assocFunc );
        template.dataPackageName = dataPackageName 
        template.preparedInsertStatementHeader = asp.makePreparedInsertStatementHeader()
        template.configuredInsertParamsHeader = asp.makeConfiguredInsertParamsHeader()

        outfile = file( outfileName, 'w' );        
        outfile.write( str(template) ) 
        outfile.close()


def sqlVariablesList( table ):
        selects = []
        s = ''
        p = 0
        for var in table.variables:
                selects.append( var.varname );
                p += 1
                if( ( p % 10 ) == 0 ) :
                        s += INDENT*3 + '"' + (', '.join( selects )) 
                        if( p < len( table.variables )):
                                s += ','
                        s += '"' 
                        if( p < len( table.variables )):
                                s += " &\n";
                        selects = []
        if( len( selects ) > 0 ):
                s += INDENT*3 + '"' + (', '.join( selects )) + ' "';
        return s                

def makeDeletePartString( table ):
        s = 'DELETE_PART : constant String := "delete from '+table.name+' "'
        return s

def makeSelectPartString( table ):
        s = 'SELECT_PART : constant String := "select " &'+"\n"
        s += sqlVariablesList( table )
        s += " &\n";
        s += INDENT*3 + '" from '+table.name+' " '
        return s
        
def makeInsertPartString( table ):
        s = 'INSERT_PART : constant String := "insert into '+table.name+' (" &'+"\n"
        s += sqlVariablesList( table )
        s += " &\n";
        s += INDENT*3 + '" ) values " '
        return s

def makeUpdatePartString( table ):
        s = 'UPDATE_PART : constant String := "update '+table.name+' set  "'
        return s

def  makeEnvironmentADB( runtime ):
        """
         Write an adb file with calls for getting passwords, usernames, database name
         writes to src/environment.adb.
        """
        outfileName = WORKING_PATHS.srcDir+'environment.adb'
        template = Template( file=WORKING_PATHS.templatesPath + "environment.adb.tmpl" )
        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
        template.unit_name   = runtime.database+'_db_environment'
        template.hostname = runtime.hostname
        template.database = runtime.database
        template.password = runtime.password
        template.username = runtime.username
        template.date = datetime.datetime.now()
        outfile = file( outfileName, 'w' );
        outfile.write( str(template) )
        outfile.close()

       

def makeToStringBody( table ):
        template = Template( file=WORKING_PATHS.templatesPath+"to_string.proc.tmpl" )
        # stupidly, indents are not consistent between the ads decl and the body so I have to duplicate
        # this header. I wrote the data decl before I really (??) got the hang of this.
        template.procedureHeader = "function To_String( rec : " + table.adaTypeName + " ) return String is"
        template.returnStr = 'return  "'+table.adaTypeName+': " &'+"\n"
        p = 0
        for var in table.variables:
                p += 1
                s = INDENT*3 + '"'+var.adaName+' = " & ' 
                if( var.isStringType() ):
                        s += 'To_String( rec.' + var.adaName +" )" 
                elif( var.isDateType() ):                        
                        s += 'tio.Image( rec.' + var.adaName + ', tio.ISO_Date )';
                else:
                        s += 'rec.' + var.adaName+ "'Img"
                if( p < len( table.variables )):
                        s += " &\n"
                template.returnStr += s                                 
        return str(template);


def makeSingleAdaRecordElement( var ):
        """
        var - Variable class from table_model.py         
        Declaration for a single element in a record
        """
        return var.adaName + " : " + var.adaType + " := " + var.getDefaultAdaValue()
        
def makeContainerPackage( table ):
        """
         table - Table class from table_model.py
         Ada containers package declaration for a table; if table name is 'fred' gives you: 
         'package fred_list is new Ada.Containers.Vectors( element_type=>fred, index_type=>Positive );
         (plus some comments)
        """
        s = INDENT + "--\n"
        s += INDENT + "-- container for "+ table.name + " : " +table.description[:MAXLENGTH] +"\n"
        s += INDENT + "--\n"
        s += INDENT + "package "+ table.adaContainerName+" is new Ada.Containers.Vectors\n"
        s += INDENT*2 + "(Element_Type => "+table.adaTypeName+",\n"
        s += INDENT*2 + "Index_Type => Positive );\n"
        return s
        
def makeChildCollection( adaName ):
        """
        adaName - a string like Variable_One
        Return a declaration for a list of some type; something like 'freds : fred_List.vector'
        """
        return makePlural( adaName ) + " : "+adaName+"_List.Vector"

def makeRecord( table ):
        """
         table - Table class from table_model.py
        Make the Ada record declaration for the given table. See table_model.py for the (very limited)  b
        xml=>sql=>ada type mappings and defaults.
        """
        print "making record for table " + table.name
        s = INDENT +"--\n"
        s += INDENT +"-- record modelling "+ table.name + " : " + table.description[:MAXLENGTH]+"\n"
        s += INDENT +"--\n"
        s += INDENT + 'type ' + table.adaTypeName + " is record\n";
        for var in table.variables:
                s += INDENT*3 + makeSingleAdaRecordElement( var )+";\n";
                
        # for name in table.childRelations:
                # fk = table.childRelations[ name ]
                # adaName = adafyName( name )
                # if( fk.isOneToOne ):
                        # s += INDENT*3 + adaName + "_Child :" + adaName+' := Null_' + adaName+";\n";
                # else:
                        # s += INDENT*3 + makeChildCollection( adaName )+";\n";
                # 
        s += INDENT + "end record;\n"
        return s
        
def makeToStringDecl( table, ending ):
        s = INDENT*1 +"--\n"
        s += INDENT*1 +"-- simple print routine for "+table.name + " : " +table.description[:MAXLENGTH]+"\n"
        s += INDENT*1 +"--\n"
        s += INDENT*1 + "function To_String( rec : " + table.adaTypeName + ' ) return String'+ending +"\n"; 
        return s
        
        
def makeDefaultRecordDecl( table ):        
        """
        Make a record that signals, effectively, Null, with some unlikely values for the primary key fields
        """
        s = INDENT*1 +"--\n"
        s += INDENT*1 +"-- default value for "+table.name + " : " +table.description[:MAXLENGTH]+"\n"
        s += INDENT*1 +"--\n"
        s += INDENT*1 + table.adaNullName + " : constant " + table.adaTypeName + " := (\n";
        elems = []
        for var in table.variables:
                elems.append( INDENT*3 + var.adaName + " => " + var.getDefaultAdaValue() );
        # for name in table.childRelations:
                # fk = table.childRelations[ name ]
                # adaName = adafyName( name )                        
                # if( fk.isOneToOne ):
                        # # 1:1 relationship
                        # elems.append( INDENT*3 + adaName + '_Child => Null_' + adaName );
                # else:
                        # elems.append( INDENT*3 + makePlural(adaName) + ' => ' + adaName + "_List.Empty_Vector" );
        s += ",\n". join( elems );
                       
        s += "\n"+INDENT*1 + ");\n"
        return s

def makeDataADS( database ):
        """
         Write a .ads file containing all the data records and container declarations 
         writes to a file  in the src output directory. 
        """
        rtabs = database.tables[:]
        rtabs.reverse()
        records = []        
        for table in rtabs:
                if( table.adaExternalName == '' ):
                        record = makeRecord( table )
                        record += makeContainerPackage( table )
                        record += makeDefaultRecordDecl( table )
                        record += makeToStringDecl( table, ';' );
                        records.append( record );
        if( len( records ) > 0 ):
                outfileName = WORKING_PATHS.srcDir+packageNameToFileName( database.adaDataPackageName() )+'.ads'
                print "makeDataADS writing to " + outfileName
                customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
                customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
                customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
                
                outfile = file( outfileName, 'w' );
                
                template = Template( file=WORKING_PATHS.templatesPath+"data.ads.tmpl" )
                template.records = records;
                template.customImports = customImports;
                template.customTypes = customTypes;
                template.customProcs = customProcs;
                template.adaTypePackages = database.adaTypePackages
                template.name = database.adaDataPackageName
                template.date = datetime.datetime.now()
                outfile.write( str(template) )
                outfile.close
                
        
def makeDataADB( database ):
        """
         Write a .adb file  
         writes to a file in the src output directory. 
        """
        rtabs = database.tables[:]
        rtabs.reverse()
        template = Template( file=WORKING_PATHS.templatesPath+"data.adb.tmpl" )
        template.toStrings = []
        template.name = database.adaDataPackageName()
        template.date = datetime.datetime.now()
        n_tables = 0
        outfileName = WORKING_PATHS.srcDir+packageNameToFileName( database.adaDataPackageName())+'.adb'
        for table in rtabs:
                if( table.adaExternalName == '' ):
                        n_tables += 1
                        template.toStrings.append( makeToStringBody( table ) )
        if( n_tables > 0 ) or ( os.path.exists( outfileName )):                
                template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
                template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
                template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
                outfile = file( outfileName, 'w' );
                outfile.write( str(template) )
                outfile.close

def makeEnvironmentADS( runtime ):
        """
         Write an ads file with calls for getting passwords, usernames, database name
         writes to src/environment.ads.
        """
        outfileName = WORKING_PATHS.srcDir+'environment.ads'
        template = Template( file=WORKING_PATHS.templatesPath+"environment.ads.tmpl" )

        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )

        template.unit_name   = runtime.database+'_db_environment'
        template.date = datetime.datetime.now()
        outfile = file( outfileName, 'w' );
        outfile.write( str(template) )
        outfile.close()


def makeBaseTypesADS( database ):
        """
         Add declarations for any decimal types and enumerations to
         an ads file already containing some package defintions, aliases,
         and string types used throughout the output.
         writes to src/base_types.ads
        """
        outfileName = WORKING_PATHS.srcDir+'base_types.ads'
        template = Template( file=WORKING_PATHS.templatesPath+"base_types.ads.tmpl" )
        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
        decs = []
        for d in database.decimalTypes.values():
                decs.append( d.toAdaString )
        template.decimal_reps = decs;
        enums = []
        for e in database.enumeratedTypes.values():
                if( not e.isExternallyDefined()):
                        enums.append( e.toAdaString )
        template.enum_reps = enums;
        template.date = datetime.datetime.now()
        template.adaTypePackages = database.adaTypePackages
        outfile = file( outfileName, 'w' );
        outfile.write( str(template) )
        outfile.close()
        
def makeBasicTypesADB():
        """
        Write a body for the common types declarations to src/base_types.adb
        """
        outfileName = WORKING_PATHS.srcDir+'base_types.adb'
        template = Template( file=WORKING_PATHS.templatesPath+"base_types.adb.tmpl" )
        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
        template.date = datetime.datetime.now()
        outfile = file( outfileName, 'w' );
        outfile.write( str(template) )
        outfile.close()
        
def makeCommons():
        """
        Write versions of support files db_commons, and db_logger to src/
        We just add some headers to each; otherwise they're uncustomised.
        """
        targets = [ 'db_commons' ]
        exts = [ 'adb', 'ads' ]
        for target in targets:
                for ext in exts:
                        outfileName = WORKING_PATHS.srcDir + target+"."+ext
                        template = Template( file=WORKING_PATHS.templatesPath+""+target+"."+ext+"."+"tmpl" )
                        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
                        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
                        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
                        template.date = datetime.datetime.now()
                        outfile = file( outfileName, 'w' );
                        outfile.write( str(template) )
                        outfile.close()
                        
                        
def writeTestCaseADS( database ):
        """
         Write an  test case ads file 
        """
        outfileName = WORKING_PATHS.testsDir+ database.dataSource.database +  '_test.ads'
        template = Template( file=WORKING_PATHS.templatesPath+"test_case.ads.tmpl" )
        template.testName = adafyName( database.dataSource.database +  '_test' );
        template.date = datetime.datetime.now()
        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )

        outfile = file( outfileName, 'w' );
        outfile.write( str(template) )
        outfile.close()
        
def makeChildTests( databaseName, table ):
        return ''        

def makeCreateTest( databaseName, table ):
        """
         Write an create test 
        """
        template = Template( file=WORKING_PATHS.templatesPath+"create_test.proc.tmpl" )
        procName = table.adaTypeName+ "_Create_Test"
        varname = table.adaInstanceName+"_test_item";
        listname = table.adaInstanceName+"_test_list";
        cursor = table.adaContainerName+'.Cursor'
        template.procedureHeader = "procedure "+procName + "(  T : in out AUnit.Test_Cases.Test_Case'Class ) is"
        template.procName = procName;        
        ## qualified names here can solve some name clashes, even though the data package is withed
        template.variableDeclaration = varname + " : " + table.adaQualifiedOutputRecord; 
        template.listDeclaration = listname + " : " + table.adaQualifiedListName;
        template.printHeader = 'procedure Print( pos : ' + cursor + ' ) is '
        template.clearTable = table.adaTypeName+"_IO.Delete( criteria )"
        template.retrieveUser = varname+' := '+table.adaContainerName+'.element( pos )'
        template.toString = 'Log( To_String( '+ varname + ' ))'
        template.completeListStatement = listname +' := '+ table.adaIOPackageName+'.Retrieve( criteria )'
        template.iterate = table.adaContainerName+'.iterate( ' + listname +", print'Access )"
        template.createKeyStatements = []
        template.createDataStatements = []
        template.modifyDataStatements = []
        template.saveStatement = table.adaTypeName+"_IO.Save( "+varname+", False )"
        template.updateStatement = table.adaTypeName+"_IO.Save( "+varname+" )"
        template.deleteStatement = table.adaTypeName+"_IO.Delete( "+varname+" )"
        template.elementFromList = varname+ ' := ' + table.adaContainerName+'.element( '+listname+', i )' 
        for var in table.variables:
                if( var.isPrimaryKey ):
                        #
                        # FIXME only works with integers and strings
                        #
                        if var.isStringType():
                                key = varname+'.'+var.adaName+ ' := To_Unbounded_String( "k_" & i\'img )' 
                        elif var.isIntegerType():
                                key = varname+'.'+var.adaName+ ' := '+ table.adaTypeName +'_IO.Next_Free_'+var.adaName  
                        template.createKeyStatements.append( key )
                else:
                        assign = "-- missing"+varname+" declaration "
                        if( var.isStringType() ):
                                data = 'dat for'+var.adaName
                                assign = varname+'.'+var.adaName+ ' := To_Unbounded_String("'+data+'")'
                                template.modifyDataStatements.append( varname+'.'+var.adaName+ ' := To_Unbounded_String("Altered::'+data+'")' )
                        elif( var.isDateType() ):
                                assign = varname+'.'+var.adaName+ ' := Ada.Calendar.Clock'
                        elif( var.isFloatingPointType() ):
                                assign = varname+'.'+var.adaName+ ' := 1010100.012'
                        elif( var.isDecimalType() ):
                                v = '10201.'+( int(var.scale)*'1')
                                assign = varname+'.'+var.adaName+ ' := '+v
                        ## finish??
                        template.createDataStatements.append( assign )
        return str( template )


def writeTestCaseADB( database ):
        """
         Write a  test case adb file 
        """
        outfileName = WORKING_PATHS.testsDir+ database.dataSource.database +  '_test.adb'
        template = Template( file=WORKING_PATHS.templatesPath+"test_case.adb.tmpl" )
        template.testName = adafyName( database.dataSource.database +  '_test' );
        template.testName_Upper_Case = adafyName( database.dataSource.database +  '_test' ).upper();
        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
        template.logFileName = WORKING_PATHS.etcDir+ 'logging_config_file.txt'
        
        template.datapackage = adafyName( database.adaDataPackageName() );
        template.dbPackages = []
        template.otherPackages = database.adaTypePackagesCompleteSet
        template.createRegisters = []
        template.childRegisters = []
        template.createTests = []
        template.childTests = []
        for table in database.tables:
                template.dbPackages.append( table.adaTypeName+"_IO" );
                template.createRegisters.append( "Register_Routine (T, " + table.adaTypeName+ "_Create_Test'Access, " + '"Test of Creation and deletion of '+table.adaTypeName+'" );' );
                template.createTests.append( makeCreateTest( database.dataSource.database, table ))
                if( len( table.childRelations ) > 0 ):
                        template.childRegisters.append( "Register_Routine (T, " + table.adaTypeName+ "_Child_Retrieve_Test'Access, " + '"Test of Finding Children of '+table.adaTypeName+'" );' );
                        template.childTests.append( makeChildTests( database.dataSource.database, table ) ) 
        template.date = datetime.datetime.now()
        outfile = file( outfileName, 'w' );
        outfile.write( str(template) )
        outfile.close()

def writeSuiteADB( database ):
        """
         Write the exe file bit (adb) for the test case 
        """
        outfile = file( WORKING_PATHS.testsDir+ 'suite.adb', 'w' );
        template = Template( file=WORKING_PATHS.templatesPath+"suite.adb.tmpl" )
        template.testFile = adafyName( database.dataSource.database +"_Test" )
        template.testCase = adafyName( database.dataSource.database +  '_test.Test_Case' );
        template.date = datetime.datetime.now()
        outfile.write( str(template) )
        outfile.close()
        
def writeHarness():
        outfile = file( WORKING_PATHS.testsDir+ 'harness.adb', 'w' );
        template = Template( file=WORKING_PATHS.templatesPath+"harness.adb.tmpl" )
        template.date = datetime.datetime.now()
        outfile.write( str(template) )
        outfile.close() 
        
        
        
def make_io_adb( database, table ):
        """
         Make the adb (ada body) file for the io procs given table e.g. fred_io.adb into src/
         table - Table class from table_model.py
         database - complete enclosuing Database model from  table_model.py
        """
        if TARGETS.binding == 'odbc':
                import ada_specific_odbc as asp
        elif TARGETS.binding == 'native':
                if TARGETS.databaseType == 'postgres':
                        import ada_specific_postgres as asp
                elif TARGETS.databaseType == 'sqlite':
                        import ada_specific_sqlite as asp

        outfileName = (WORKING_PATHS.srcDir+table.adaTypeName+'_io.adb').lower()
        template = Template( file=WORKING_PATHS.templatesPath+"io.adb.tmpl" )
        template.dbWiths = asp.getDBWiths();
        template.dbRenames = asp.getDBRenames();
        template.dbUses = asp.getDBUses();
        template.connectionString = asp.CONNECTION_STRING        
        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
        template.selectPart = makeSelectPartString( table )
        template.insertPart = makeInsertPartString( table )
        template.deletePart = makeDeletePartString( table )
        template.updatePart = makeUpdatePartString( table )
        template.IOName = table.adaTypeName+"_IO"
        template.IOName_Upper_Case = ( table.adaTypeName+"_IO").upper()
        template.criteria = []
        template.nullName = table.adaQualifiedNullName;
        template.orderingStatements = []
        template.incr_integer_pk_fields = []
        template.localWiths = []
        template.decimalDeclarations = []
        template.errorCheck = asp.makeErrorCheckingCode()
        for dec in table.decimalTypes:
                gentype = "function make_criterion_element_"+dec+" is new d.Make_Decimal_Criterion_Element( "+dec+" )"
                template.decimalDeclarations.append( gentype ); 
        for var in table.variables:
                template.criteria.append( makeCriteriaBody( var ))
                template.orderingStatements.append( makeAddOrderingColumnBody( var ));
                if( var.isStringType() ):
                        template.criteria.append( makeCriteriaBody( var ,True ))
                if( var.isPrimaryKey ):
                        if( var.isIntegerType() ):
                                template.incr_integer_pk_fields.append( asp.makeNextFreeFunc( table, var ) );
        if( table.hasPrimaryKey()):                                
                template.pkFunc = makePKBody( table, asp.CONNECTION_STRING )
        else:
                template.pkFunc = ''
        template.has_primary_key = table.hasPrimaryKey();
        template.isNullFunc = makeIsNullFunc( table, database.adaDataPackageName() )

        template.retrieveByCFunc = makeRetrieveCFunc( table, asp.CONNECTION_STRING );
        
        template.retrieveBySFunc = asp.makeRetrieveSFunc( table, database );
        template.updateFunc = asp.makeUpdateProcBody( table );
        template.saveFunc = asp.makeSaveProcBody( table );
        template.deleteSpecificFunc = makeDeleteSpecificProcBody( table, asp.CONNECTION_STRING );
        template.deleteFunc = asp.makeDeleteProcBody( table );
        template.outputRecordType = table.adaQualifiedOutputRecord
        template.outputRecordName = table.adaTypeName
        template.associated = []
        template.date = datetime.datetime.now()
        for name in table.childRelations:
                fk = table.childRelations[ name ]
                referencingTable = database.getTable( name )
                template.localWiths.append( referencingTable.adaTypeName +"_IO" ) 
                if( fk.isOneToOne ):
                        childFunc = makeChildRetrieveBody( table, referencingTable, fk, asp.CONNECTION_STRING )
                        template.associated.append( childFunc );
                else:
                        listAdaName = database.adaDataPackageName() +"."+referencingTable.adaTypeName+"_List.Vector"
                        assocFunc = makeAssociatedRetrieveBody( table, referencingTable, fk, asp.CONNECTION_STRING ); #, listAdaName, fk )
                        template.associated.append( assocFunc );
        template.dataPackageName = database.adaDataPackageName() 
        template.preparedInsertStatementBody = asp.makePreparedInsertStatementBody( table )
        template.configuredInsertParamsBody = asp.makeConfiguredInsertParamsBody( table )
        outfile = file( outfileName, 'w' );
        outfile.write( str(template) ) 
        outfile.close()
        
def makeIO( database ):
        """
        database - complete enclosuing Database model from  table_model.py

        Make all the records needed to handle writing to and from the database
        there is one ads/adb pair per table in the database; for a table 'fred'
        these are fred_io.ads and fred_io.adb
         Write to src/
        """
        for table in database.tables:
                make_io_ads( database, database.adaTypePackages, table )
                make_io_adb( database, table )



def writeConnectionPool():
        """
        """
        if TARGETS.binding == 'odbc':
                import ada_specific_odbc as asp
        elif TARGETS.binding == 'native':
                if TARGETS.databaseType == 'postgres':
                        import ada_specific_postgres as asp
                elif TARGETS.databaseType == 'sqlite':
                        import ada_specific_sqlite as asp

        asp.writeConnectionPoolADS();
        asp.writeConnectionPoolADB();

