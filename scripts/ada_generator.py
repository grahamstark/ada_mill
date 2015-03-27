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
import paths
import os
from table_model import DataSource, Format, Qualification, ItemType
from utils import makePlural, adafyName, makePaddedString, \
        INDENT, MAXLENGTH, readLinesBetween, makeUniqueArray, \
        notNullOrBlank, isNullOrBlank
from ada_generator_libs import makeRetrieveSHeader, makeSaveProcHeader, \
        makeRetrieveCHeader, \
        makeUpdateProcHeader, makeDeleteSpecificProcHeader, makeCriterionList, \
        makePrimaryKeyCriterion, makeNextFreeHeader, makeDeleteSpecificProcBody

def makeAddOrderingColumnDecl( var, ending ):
        s = "procedure Add_"+var.adaName+"_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc )" + ending
        return s

def makeAddOrderingColumnBody( var ):
        template = Template( file=paths.getPaths().templatesPath+"add_to_criterion_ordering.func.tmpl" )
        template.header = makeAddOrderingColumnDecl( var, ' is' )
        template.criterion = 'elem : d.Order_By_Element := d.Make_Order_By_Element( "'+ var.varname + '", direction  )'
        template.functionName = "Add_"+var.adaName+"_To_Orderings"
        s = str(template) 
        return s

def makeUpdateStatement( table ):
        print ""

def makeInsertStatement( table ):
        s = "insert into %{SCHEMA}"+table.qualifiedName()+" values( "

def makeCastStatement( var ):
        if( var.hasUserDefinedAdaType() ):
                return var.getAdaType( False ) + "( " + var.adaName + " )"
        else:
                return var.getAdaType( True )

def makeCriteriaDecl( var, isString, ending ):
        if var.arrayInfo != None:
                adaType = var.arrayInfo.name
        elif isString:
                adaType = 'String'
        else:
                adaType = var.getAdaType( True )
        return "procedure Add_"+var.adaName+"( c : in out d.Criteria; "+var.adaName+" : "+ adaType +"; op : d.operation_type:= d.eq; join : d.join_type := d.join_and )" + ending
        
def makePrimaryKeySubmitFields( table ):
        pks = []
        instanceName = table.makeName( Format.ada, Qualification.full, ItemType.instanceName )
        for var in table.variables:
                if( var.isPrimaryKey ):
                        pks.append( table.instanceName + '.' + var.adaName  )
        return ', '.join( pks )

def makeCriteriaBody( var, isString = False ):
        if( isString ):
                adaType = 'String'
        else:
                adaType = var.getAdaType( True )
        # adaType = str.capitalize( adaType );
        template = Template( file=paths.getPaths().templatesPath+"add_to_criterion.func.tmpl" )
        if var.arrayInfo != None :
                value = var.arrayInfo.stringFromArrayDeclaration( var.adaName )
        elif( var.schemaType == 'BOOLEAN' ):
                value = var.adaName # assumes support for boolean in db, otherwise cast to 0/1 integer
        elif( var.schemaType == 'ENUM' ):
                value = "Integer( " + adaType+"'Pos( "+var.adaName +" ))"
        elif adaType == 'Unbounded_String':
                value = "To_String( "+var.adaName +" )"
        elif var.hasUserDefinedAdaType():
                value = makeCastStatement( var )
        else:
                value = var.adaName
        # handle decimals from generic functions, one per decimal type; these are declared locally to the current package
        #
        if var.arrayInfo != None:
                function = "d.Make_Criterion_Element"
        elif var.isDecimalType():
                function = "Make_Criterion_Element_"+adaType
        else:   # .. otherwise, use the default versions in the db_commons package, aliased as 'd' here
                function = 'd.Make_Criterion_Element';                
        s = 'elem : d.Criterion := '+ function + '( "'+ var.varname +'", op, join, '+ value 
        if var.isStringType() and var.size > 1:
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
        outputRecord = table.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.table )
        return "function Retrieve_By_PK( " + pkFields + "; " + connection_string + " ) return " + outputRecord + ending
        
def makePKBody( table, connection_string ):
        template = Template( file=paths.getPaths().templatesPath+"retrieve_pk.func.tmpl" )
        instanceName = table.makeName( Format.ada, Qualification.unqualified, ItemType.instanceName )
        outputRecord = table.makeName( Format.ada, Qualification.full, ItemType.table )
        nullName = table.makeName( Format.ada, Qualification.full, ItemType.null_constant )
        containerName = table.makeName( Format.ada, Qualification.full, ItemType.list_container )
        if( table.hasPrimaryKey()):                                
                template.functionHeader = makePKHeader( table, connection_string, ' is' )
        template.listType = table.makeName( Format.ada, Qualification.full, ItemType.alist )
        template.variableDecl = instanceName + " : " + outputRecord 
        template.primaryKeyCriteria = makeCriterionList( table, 'c', 'primaryKeyOnly', False )
        template.getNullRecord = instanceName + " := " +  nullName
        template.getFirstRecord = instanceName + " := " + containerName+ ".First_Element( l )"
        template.notEmpty = "not "+ containerName +".is_empty( l )" 
        template.adaName = instanceName
        s = str(template) 
        return s

def makeIsNullFunc( table, adaDataPackageName ):
        instanceName = table.makeName( Format.ada, Qualification.unqualified, ItemType.instanceName )
        qualifiedNullName = table.makeName( Format.ada, Qualification.full, ItemType.null_constant )
        template = Template( file=paths.getPaths().templatesPath+"is_null.func.tmpl" )       
        template.adaName = table.makeName( Format.ada, Qualification.full, ItemType.table )
        template.functionHeader = makeIsNullFuncHeader( table, ' is' )
        template.returnStatement = 'return '+ instanceName + ' = ' + qualifiedNullName
        if notNullOrBlank( table.schemaName ):
                schemaBit = '.' + table.schemaName
        else:
                schemaBit = ''
        template.use = '' #"use " + adaDataPackageName + schemaBit
        template.nullName = qualifiedNullName
        s = str(template) 
        return s
        
def makeIsNullFuncHeader( table, ending ):
        instanceName = table.makeName( 
                Format.ada, 
                Qualification.unqualified, 
                ItemType.instanceName )
        outputRecord = table.makeName( 
                Format.ada, 
                Qualification.unqualified, 
                ItemType.table )
        return "function Is_Null( "+ instanceName + " : " + outputRecord + " ) return Boolean"+ending;

def makeRetrieveCFunc( table, connection_string ):
        template = Template( file=paths.getPaths().templatesPath+"retrieve_by_c.func.tmpl" )
        template.functionHeader = makeRetrieveCHeader( table, connection_string, ' is' )
        s = str(template) 
        return s

def makeChildRetrieveHeader( table, parentTable, packagedAdaName, connection_string, ending ):
        instanceName = table.makeName( 
                Format.ada, 
                Qualification.unqualified, 
                ItemType.instanceName )
        outputRecord = table.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.table )
        return "function Retrieve_Child_"+parentTable.replace( ".", "_" ) + \
                "( " + instanceName + " : " + \
                outputRecord +"; " + connection_string + \
                ") return " + packagedAdaName+ending

def makeChildRetrieveBody( table, parentTable, fk, connection_string ):
        """
        If the table has a foreign key with the same primary key,
        add a function that retrieves the single record in the referencing table
        referred to by the table primary key. 
        """
        instanceName = table.makeName( 
                Format.ada, 
                Qualification.unqualified, 
                ItemType.instanceName )
        parentQualifiedOutputRecord = parentTable.makeName(
                Format.ada,
                Qualification.full,
                ItemType.table )
        parentTableTypeName = parentTable.makeName(
                Format.ada,
                Qualification.full,
                ItemType.table )
        
        template = Template( file=paths.getPaths().templatesPath+"retrieve_child.func.tmpl" )
        
        template.functionHeader = makeChildRetrieveHeader( 
                table = table, 
                parentTable = parentTableTypeName, 
                packagedAdaName = parentQualifiedOutputRecord, 
                connection_string = connection_string, 
                ending = ' is' )
        
        template.functionName = "Retrieve_Child_"+ parentTableTypeName.replace( ".", "_" )
        referencePackage = parentTable.makeName( Format.ada, Qualification.full, ItemType.io_package )
        localPK = []
        for p in range(len( fk.childCols ) ):
                localName = str.capitalize( fk.childCols[p] ) + " => " + instanceName +"."+ adafyName(fk.parentCols[p])
                localPK.append( localName )
        localPKValues = (",\n"+INDENT*3).join( localPK )
        template.returnStatement = "return " + referencePackage + ".retrieve_By_PK( \n"+INDENT*3+localPKValues + ",\n" + INDENT*3+"Connection => connection )"
        s = str(template) 
        return s

def makeAssociatedRetrieveHeader( table, parentTableName, listAdaName, connection_string, ending ):
        instanceName = table.makeName( 
                Format.ada, 
                Qualification.unqualified, 
                ItemType.instanceName )
        qualifiedOutputRecord = table.makeName(
                Format.ada,
                Qualification.full,
                ItemType.table )                
        return "function Retrieve_Associated_"+ \
               makePlural( parentTableName.replace( '.', '_' )) + \
               "( " +  instanceName + " : " + \
               qualifiedOutputRecord +"; " + connection_string + \
               " ) return " + listAdaName+ending

def makeAssociatedRetrieveBody( table, parentTable, fk, connection_string ): 
        instanceName = table.makeName( 
                Format.ada, 
                Qualification.unqualified, 
                ItemType.instanceName )
        template = Template( file=paths.getPaths().templatesPath+"retrieve_associated.func.tmpl" )
        parentTableName = parentTable.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.table )
        parentQualifiedListName = parentTable.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.alist )
        template.functionHeader = makeAssociatedRetrieveHeader( 
                table, 
                parentTableName, 
                parentQualifiedListName, connection_string, ' is' )
        template.allCriteria = []
        template.functionName = "Retrieve_Associated_"+ \
               makePlural( parentTableName.replace( '.', '_' ))
               
        referencePackage = parentTable.makeName( Format.ada, Qualification.full, ItemType.io_package ) # ioNameFromPackageName( parentTableame )
        template.returnStatement = "return " + referencePackage + ".retrieve( c, connection )"
        for p in range( len( fk.childCols ) ):
                # note these are the other way around from how you'd think of it
                # since the foriegn key is originally a property of the referencing table
                # not the table we're on (if you see what I mean).
                localName = adafyName( fk.childCols[p] )
                foreignName = adafyName( fk.parentCols[p] )
                crit = referencePackage+".Add_"+localName+"( c, " + instanceName+"."+foreignName + " )"
                template.allCriteria.append( crit )
        s = str(template) 
        return s

def makeIOAds( database, adaTypePackages, table ):
        if TARGETS.binding == 'odbc':
                import ada_specific_odbc as asp
        elif TARGETS.binding == 'native':
                if TARGETS.databaseType == 'postgres':
                        import ada_specific_postgres as asp
                elif TARGETS.databaseType == 'sqlite':
                        import ada_specific_sqlite as asp
                                
        instanceName = table.makeName( 
                Format.ada, 
                Qualification.unqualified, 
                ItemType.instanceName )
        outputRecord = table.makeName(
                Format.ada,
                Qualification.full,
                ItemType.table )
        print "makeIOAds; outputRecord = " + outputRecord
        packageName = table.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.io_package )
        outfileName = paths.getPaths().srcDir + table.makeName( 
                Format.ada_filename, 
                Qualification.full, 
                ItemType.io_package ) + ".ads" 
        dataPackageName = database.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.data_package_name ) 
        template = Template( file=paths.getPaths().templatesPath+"io.ads.tmpl" )
        template.connectionString = asp.CONNECTION_STRING        
        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
        template.IOName = packageName
        template.dbWiths = asp.getDBAdsWiths();
        template.IOName_Upper_Case = packageName.upper()
        template.schema_name = table.schemaName
        template.criteria = []
        template.nullName = table.makeName( Format.ada, Qualification.full, ItemType.null_constant );
        template.orderingStatements = []
        template.incr_integer_pk_fields = []
        for name in table.childRelations:
                fk = table.childRelations[ name ]
                parentTable = database.getOneTable( fk.childSchemaName, fk.childTableName ) #table.schemaName
                if parentTable.schemaName != table.schemaName:
                        adaTypePackages.append( parentTable.makeName( Format.ada, Qualification.full, ItemType.schema_name )) 

        template.adaTypePackages = makeUniqueArray( adaTypePackages + table.adaTypePackages )
        for var in table.variables:
                # if var.arrayInfo != None:
                template.orderingStatements.append( makeAddOrderingColumnDecl( var, ';' ));
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
        template.outputRecordType = outputRecord
        template.outputRecordName = instanceName
        template.associated = []
        template.date = datetime.datetime.now()
        for name in table.childRelations:
                fk = table.childRelations[ name ]
                childTable = database.getOneTable( fk.childSchemaName, fk.childTableName );
                # print( "getting child fk.childSchemaName=|"+fk.childSchemaName+"| fk.childTableName=|"+fk.childTableName )
                adaChildInstanceName = childTable.makeName( Format.ada, Qualification.full, ItemType.table )
                adaChildRecordName = childTable.makeName( Format.ada, Qualification.full, ItemType.table )
                if( fk.isOneToOne ):
                        childFunc = makeChildRetrieveHeader( 
                                table             = table, 
                                parentTable       = adaChildInstanceName, 
                                packagedAdaName   = adaChildRecordName, 
                                connection_string = asp.CONNECTION_STRING, 
                                ending            = ';' )
                        template.associated.append( childFunc );
                else:
                        listAdaName = childTable.makeName( 
                                Format.ada, 
                                Qualification.full, 
                                ItemType.list_container )
                        assocFunc = makeAssociatedRetrieveHeader( 
                                table, 
                                adaChildRecordName, 
                                childTable.makeName( 
                                        Format.ada, 
                                        Qualification.full, 
                                        ItemType.alist ), 
                                asp.CONNECTION_STRING, 
                                ';' )
                        template.associated.append( assocFunc );
        template.dataPackageName = dataPackageName 
        
        template.preparedInsertStatementHeader = asp.makePreparedInsertStatementHeader()
        template.configuredInsertParamsHeader = asp.makeConfiguredInsertParamsHeader( table )
        
        template.preparedRetrieveStatementHeaders = asp.makePreparedRetrieveStatementHeaders()
        template.configuredRetrieveParamsHeader = asp.makeConfiguredRetrieveParamsHeader( table )
        template.mapFromCursorHeader = asp.makeMapFromCursorHeader( outputRecord );
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
        s = 'DELETE_PART : constant String := "delete from %{SCHEMA}'+table.qualifiedName()+' "'
        return s

def makeSelectPartString( table ):
        s = 'SELECT_PART : constant String := "select " &'+"\n"
        s += sqlVariablesList( table )
        s += " &\n";
        s += INDENT*3 + '" from %{SCHEMA}'+table.qualifiedName()+' " '
        return s
        
def makeInsertPartString( table ):
        s = 'INSERT_PART : constant String := "insert into %{SCHEMA}'+table.qualifiedName()+' (" &'+"\n"
        s += sqlVariablesList( table )
        s += " &\n";
        s += INDENT*3 + '" ) values " '
        return s

def makeUpdatePartString( table ):
        s = 'UPDATE_PART : constant String := "update %{SCHEMA}'+table.qualifiedName()+' set  "'
        return s

def  makeEnvironmentADB( runtime ):
        """
         Write an adb file with calls for getting passwords, usernames, database name
         writes to src/environment.adb.
        """
        outfileName = paths.getPaths().srcDir+'environment.adb'
        template = Template( file=paths.getPaths().templatesPath + "environment.adb.tmpl" )
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

def makeToStringBody( table, indent ):
        template = Template( file=paths.getPaths().templatesPath+"to_string.proc.tmpl" )
        # stupidly, indents are not consistent between the ads decl and the body so I have to duplicate
        # this header. I wrote the data decl before I really (??) got the hang of this.
        template.indent = INDENT*indent
        uqname = table.makeName( Format.ada, Qualification.unqualified, ItemType.table )
        template.procedureHeader = "function To_String( rec : " + uqname + " ) return String is"
        template.returnStr = 'return  "'+ uqname +': " &'+"\n"
        p = 0
        for var in table.variables:
                p += 1
                s = INDENT*(indent + 2) + '"'+var.adaName+' = " & ' 
                if( var.arrayInfo != None ):
                        s += var.arrayInfo.toStringDeclaration( "rec." + var.adaName );
                elif( var.isStringType() ):
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
        s = var.adaName + " : " 
        if var.arrayInfo != None:
                s += var.arrayInfo.arrayDeclaration( var.getDefaultAdaValue())
        else:
                s += var.adaType + " := " + var.getDefaultAdaValue()                
        return s 
        
def makeContainerPackage( table, numIndents = 1 ):
        """
         table - Table class from table_model.py
         Ada containers package declaration for a table; if table name is 'fred' gives you: 
         'package fred_list is new Ada.Containers.Vectors( element_type=>fred, index_type=>Positive );
         (plus some comments)
        """
        packageName = table.makeName( 
                Format.ada, 
                Qualification.unqualified, 
                ItemType.list_container )
        listName = table.makeName( 
                Format.ada, 
                Qualification.unqualified, 
                ItemType.alist )
        typeName = table.makeName( 
                Format.ada, 
                Qualification.unqualified, 
                ItemType.table )
        s = INDENT*numIndents+ "--\n"
        s += INDENT*numIndents+ "-- container for "+ \
                table.makeName( Format.ada, Qualification.unqualified, ItemType.table ) + " : "  + \
                table.description[:MAXLENGTH] +"\n"
        s += INDENT*numIndents+ "--\n"
        s += INDENT*numIndents+ "package "+ packageName + \
                " is new Ada.Containers.Vectors\n"
        s += INDENT*(numIndents+1) + "(Element_Type => "+ \
                table.makeName( Format.ada, Qualification.unqualified, ItemType.table )+",\n"
        s += INDENT*(numIndents+1) + "Index_Type => Positive );\n"
        s += INDENT*(numIndents) + "subtype "+ listName + " is " + packageName + ".Vector;\n" 
        return s
        
def makeChildCollection( adaName ):
        """
        adaName - a string like Variable_One
        Return a declaration for a list of some type; something like 'freds : fred_List.vector'
        """
        return makePlural( adaName ) + " : "+adaName+"_List.Vector"

def makeRecord( table, numIndents = 1 ):
        """
         table - Table class from table_model.py
        Make the Ada record declaration for the given table. See table_model.py for the (very limited)  b
        xml=>sql=>ada type mappings and defaults.
        """
        uqname = table.makeName( Format.ada, Qualification.unqualified, ItemType.table )
        print "making record for table " + uqname 
        s = INDENT*numIndents +"--\n"
        s += INDENT*numIndents +"-- record modelling "+ uqname + " : " + table.description[:MAXLENGTH]+"\n"
        s += INDENT*numIndents +"--\n"
        s += INDENT*numIndents + 'type ' + uqname + " is record\n";
        for var in table.variables:
                s += INDENT*(numIndents+1) + makeSingleAdaRecordElement( var )+";\n";
        s += INDENT*numIndents + "end record;\n"
        return s
        
def makeToStringDecl( table, ending, numIndents = 1 ):
        uqname = table.makeName( Format.ada, Qualification.unqualified, ItemType.table )
        s = INDENT*numIndents +"--\n"
        s += INDENT*numIndents +"-- simple print routine for "+uqname + " : " +table.description[:MAXLENGTH]+"\n"
        s += INDENT*numIndents +"--\n"
        s += INDENT*numIndents + "function To_String( rec : " + uqname + ' ) return String'+ending +"\n"; 
        return s
        
def makeDefaultRecordDecl( table, numIndents = 1 ):        
        """
        Make a record that signals, effectively, Null, with some unlikely values for the primary key fields
        """
        uqname = table.makeName( Format.ada, Qualification.unqualified, ItemType.table )
        s = INDENT*numIndents +"--\n"
        s += INDENT*numIndents +"-- default value for "+uqname + " : " +table.description[:MAXLENGTH]+"\n"
        s += INDENT*numIndents +"--\n"
        s += INDENT*numIndents + table.makeName( Format.ada, Qualification.unqualified, ItemType.null_constant ) + \
                " : constant " + uqname + " := (\n";
        elems = []
        for var in table.variables:
                if var.arrayInfo == None:
                        elems.append( INDENT*(numIndents+2) + var.adaName + " => " + var.getDefaultAdaValue() );
                else:
                        elems.append( INDENT*(numIndents+2) + var.adaName + " => ( others => " + var.getDefaultAdaValue() + " )");
        s += ",\n". join( elems );
                       
        s += "\n"+INDENT*numIndents + ");\n"
        return s

#
# will reverse order of tabList, so send a copy
#
def makeRecordList( tabList, numIndents = 1 ):
        tabList.reverse()
        records = []   
        if len( tabList ) > 0:
                records = []   
                for table in tabList:
                        if( table.adaExternalName == '' ):
                                record = makeRecord( table, numIndents )
                                record += makeContainerPackage( table, numIndents )
                                record += makeDefaultRecordDecl( table, numIndents )
                                record += makeToStringDecl( table, ';', numIndents );
                                records.append( record );
        return records

def makeOneDataADS( database, parent, addArrayDecls ):
        """
         Write a .ads file containing all the data records and container declarations 
         writes to a file  in the src output directory. 
        """
        packageName = database.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.schema_name ) #+'_Data'
        records = makeRecordList( database.getAllTables( False ), 1 )   
        # rtabs = copy.deepcopy( schema.tables ) # FIXME: maybe one per schema??
        totalRecords = len( database.getAllTables( True )) # fixme slow copy
        childPackages = []
        print "makeOneDataADS entered "
        if totalRecords > 0 :                
                outfileName = paths.getPaths().srcDir + \
                        database.makeName( 
                                Format.ada_filename, 
                                Qualification.full, 
                                ItemType.schema_name ) + '.ads'
                print "makeDataADS writing to " + outfileName
                customImports = readLinesBetween( outfileName, 
                        ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
                customTypes = readLinesBetween( outfileName, 
                        ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
                customProcs = readLinesBetween( outfileName, 
                        ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
                outfile = file( outfileName, 'w' );
                template = Template( file=paths.getPaths().templatesPath+"data.ads.tmpl" )
                template.records = records;
                template.customImports = customImports;
                template.customTypes = customTypes;
                template.customProcs = customProcs;
                template.adaTypePackages = parent.adaTypePackages
                template.name = packageName
                if addArrayDecls == True:
                        template.arrayDeclarations = parent.getArrayDeclarations()                
                        template.arrayPackages = parent.getArrayPackages()
                else:
                        template.arrayDeclarations = []                
                        template.arrayPackages = []
                        
                template.date = datetime.datetime.now()
                template.childPackages = childPackages;        
                outfile.write( str(template) )
                outfile.close


def makeDataADS( database ):
        makeOneDataADS( database, database, True )
        for schema in database.schemas:
                makeOneDataADS( schema, database, False )
                
        # childPackages = []
                # stemplate = Template( 
                        # file=paths.getPaths().templatesPath+"child_package.ads.tmpl" )
                # stemplate.name = schema.makeName( 
                        # Format.ada_filename, 
                        # Qualification.unqualified, 
                        # ItemType.schema_name )
                # stemplate.records = makeRecordList( schema.tables, 2 )
                # childPackages.append( str( stemplate ))


def makeToStringBodies( rtabs, indent ):
        rtabs.reverse()
        to_strings = []
        for table in rtabs:
                if( table.adaExternalName == '' ):
                        to_strings.append( makeToStringBody( table, indent ))
        return to_strings;

def makeOneDataADB( database, parent ):
        """
         Write a .adb file  
         writes to a file in the src output directory. 
        """
        packageName = database.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.schema_name )  #+'_Data'
        template = Template( file=paths.getPaths().templatesPath+"data.adb.tmpl" )
        template.toStrings = []
        template.name = packageName
        template.date = datetime.datetime.now()
        to_strings = []
        outfileName = paths.getPaths().srcDir+database.makeName( 
                Format.ada_filename, 
                Qualification.full, 
                ItemType.schema_name ) +'.adb' # _data
        print "makeOneDataADB; writing to " + outfileName
        tabs = database.getAllTables( False )
        n_tables = len( tabs )
        template.toStrings = makeToStringBodies( tabs, 1 );
        template.childPackages = []
        if( n_tables > 0 ) or ( os.path.exists( outfileName )):                
                template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
                template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
                template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
                outfile = file( outfileName, 'w' );
                outfile.write( str( template ))
                outfile.close

def makeDataADB( database ):
        makeOneDataADB( database, database )
        for schema in database.schemas:
                makeOneDataADB( schema, database )
# 
                # stemplate = Template( file=paths.getPaths().templatesPath+"child_package.adb.tmpl" )
                # stemplate.name = str.capitalize( schema.schemaName )
                # tostrs = makeToStringBodies( schema.tables, 2 )
                # stemplate.toStrings = tostrs
                # n_tables += len( tostrs )
                # if len( tostrs ) > 0: 
                        # template.childPackages.append( str( stemplate ))

def makeEnvironmentADS( runtime ):
        """
         Write an ads file with calls for getting passwords, usernames, database name
         writes to src/environment.ads.
        """
        outfileName = paths.getPaths().srcDir+'environment.ads'
        template = Template( file=paths.getPaths().templatesPath+"environment.ads.tmpl" )

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
        outfileName = paths.getPaths().srcDir+'base_types.ads'
        template = Template( file=paths.getPaths().templatesPath+"base_types.ads.tmpl" )
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
                        # print "appending " + e.name + " to enums"
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
        outfileName = paths.getPaths().srcDir+'base_types.adb'
        template = Template( file=paths.getPaths().templatesPath+"base_types.adb.tmpl" )
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
                        outfileName = paths.getPaths().srcDir + target+"."+ext
                        template = Template( file=paths.getPaths().templatesPath+""+target+"."+ext+"."+"tmpl" )
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
        outfileName = paths.getPaths().testsDir+ database.databaseName +  '_test.ads'
        template = Template( file=paths.getPaths().templatesPath+"test_case.ads.tmpl" )
        template.testName = adafyName( database.databaseName +  '_test' );
        template.date = datetime.datetime.now()
        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )

        outfile = file( outfileName, 'w' );
        outfile.write( str(template) )
        outfile.close()
        
def makeChildTests( databaseName, testName, table ):
        return ''        

def makeCreateTest( databaseName, procName, table ):
        """
         Write an create test 
        """
        
        adaTypeName = table.makeName( Format.ada, Qualification.full, ItemType.table )
        template = Template( file=paths.getPaths().templatesPath+"create_test.proc.tmpl" )
        ioPackageName = table.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.io_package )
        # procName = table.adaTypeName()+ "_Create_Test"
        instanceName = table.makeName( 
                Format.ada, 
                Qualification.unqualified, 
                ItemType.instanceName ) 
        varname = instanceName + "_test_item";
        listname = instanceName+"_test_list";
        cursor = table.makeName( Format.ada, Qualification.full, ItemType.list_container )+'.Cursor'
        template.childPackageUse = ''
        # not needed since all children now
        # if notNullOrBlank( table.schemaName ):
        #        template.childPackageUse = 'use ' + str.capitalize( table.schemaName )+';'
        template.procName = procName;        
        template.procedureHeader = "procedure "+procName + "( T : in out AUnit.Test_Cases.Test_Case'Class ) is"
        ## qualified names here can solve some name clashes, even though the data package is withed
        template.variableDeclaration = varname + " : " + adaTypeName; 
        template.listDeclaration = listname + " : " + table.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.alist );
        template.printHeader = 'procedure Print( pos : ' + cursor + ' ) is '
        template.clearTable =  ioPackageName +".Delete( criteria )"
        template.retrieveUser = varname+' := '+table.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.list_container )+'.Element( pos )'
        template.toString = 'Log( To_String( '+ varname + ' ))'
        template.completeListStatement = listname +' := '+ ioPackageName +'.Retrieve( criteria )'
        template.iterate = table.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.list_container )+'.iterate( ' + listname +", print'Access )"
        template.createKeyStatements = []
        template.createDataStatements = []
        template.modifyDataStatements = []
        template.saveStatement = ioPackageName + ".Save( "+varname+", False )"
        template.updateStatement = ioPackageName + ".Save( "+varname+" )"
        template.deleteStatement = ioPackageName + ".Delete( "+varname+" )"
        # template.dataPackageName = table.makeName( Format.ada, Qualification.full, ItemType.schema_name )
        template.elementFromList = varname+ ' := ' + table.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.list_container )+'.element( '+listname+', i )' 
        for var in table.variables:
                if( var.isPrimaryKey ):
                        #
                        # FIXME only works with integers and strings
                        #
                        if var.isStringType():
                                key = varname + '.'+var.adaName+ ' := To_Unbounded_String( "k_" & i\'img )' 
                        elif var.isIntegerType():
                                key = varname+'.'+var.adaName+ ' := ' + ioPackageName + \
                                        '.Next_Free_'+var.adaName  
                        else:
                                key = varname+'.'+var.adaName+ ' := ' + var.getAdaType( True ) + "'First"
                        template.createKeyStatements.append( key )
                else:
                        assign = "-- missing declaration for "+varname+'.'+var.adaName
                        if var.arrayInfo != None:
                                data = "( others => " + var.getDefaultAdaValue() + " )"
                                assign = varname+'.'+var.adaName+ ' := '+ data;
                        elif var.isStringType():
                                data = 'dat for'+var.adaName 
                                assign = varname+'.'+var.adaName+ ' := To_Unbounded_String("'+data+'" & i\'Img )'
                                template.modifyDataStatements.append( varname+'.'+var.adaName+ ' := To_Unbounded_String("Altered::'+data+'" & i\'Img)' )
                        elif var.isDateType():
                                assign = varname+'.'+var.adaName+ ' := Ada.Calendar.Clock'
                        elif var.isFloatingPointType():
                                assign = varname+'.'+var.adaName+ ' := 1010100.012 + ' + var.adaType + "( i )"
                        elif var.isDecimalType():
                                # fixme breaks if this is a unique key
                                v = '10201.'+( int(var.scale)*'1')
                                assign = varname+'.'+var.adaName+ ' := '+v
                        ## finish??
                        template.createDataStatements.append( assign )
        return str( template )

def writeTestCaseADB( database ):
        """
         Write a  test case adb file 
        """
        outfileName = paths.getPaths().testsDir+ database.databaseName +  '_test.adb'
        template = Template( file=paths.getPaths().templatesPath+"test_case.adb.tmpl" )
        template.testName = adafyName( database.databaseName +  '_Test' );
        template.testName_Upper_Case = adafyName( database.databaseName +  '_Test' ).upper();
        template.customImports = readLinesBetween( outfileName, ".*CUSTOM.*IMPORTS.*START", ".*CUSTOM.*IMPORT.*END" )
        template.customTypes = readLinesBetween( outfileName, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
        template.customProcs = readLinesBetween( outfileName, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )
        template.logFileName = paths.getPaths().etcDir+ 'logging_config_file.txt'
        
        template.datapackage = database.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.data_package_name ) 
        template.dbPackages = []
        template.otherPackages = database.adaTypePackagesCompleteSet
        template.createRegisters = []
        template.childRegisters = []
        template.createTests = []
        template.childTests = []
        
        for table in database.getAllTables():
                adaTypeName = table.makeName( 
                        Format.ada, 
                        Qualification.full, 
                        ItemType.table )
                ioPackageName = table.makeName( 
                        Format.ada, 
                        Qualification.full, 
                        ItemType.io_package )
                testName = ( adaTypeName+ "_Create_Test" ).replace( '.', '_' )
                childTestName = ( adaTypeName+ "_Child_Retrieve_Test" ).replace( '.', '_' )
                template.dbPackages.append( ioPackageName );
                template.createRegisters.append( "Register_Routine (T, " + testName + "'Access, " + '"Test of Creation and deletion of '+adaTypeName+'" );' );
                template.createTests.append( makeCreateTest( database.databaseName, testName, table ))
                if( len( table.childRelations ) > 0 ):
                        template.childRegisters.append( "Register_Routine (T, " + childTestName + "'Access, " + '"Test of Finding Children of '+adaTypeName+'" );' );
                        template.childTests.append( makeChildTests( database.databaseName, childTestName, table ) ) 
        # template.dbPackages.append( str.capitalize( database.name ));
        for schema in database.schemas:
                template.dbPackages.append( schema.makeName( Format.ada, Qualification.full, ItemType.schema_name ));
                
        template.date = datetime.datetime.now()
        outfile = file( outfileName, 'w' );
        outfile.write( str(template) )
        outfile.close()

def writeSuiteADB( database ):
        """
         Write the exe file bit (adb) for the test case 
        """
        outfile = file( paths.getPaths().testsDir+ 'suite.adb', 'w' );
        template = Template( file=paths.getPaths().templatesPath+"suite.adb.tmpl" )
        template.testFile = adafyName( database.databaseName +"_Test" )
        template.testCase = adafyName( database.databaseName +  '_test.Test_Case' );
        template.date = datetime.datetime.now()
        outfile.write( str(template) )
        outfile.close()
        
def writeHarness():
        outfile = file( paths.getPaths().testsDir+ 'harness.adb', 'w' );
        template = Template( file=paths.getPaths().templatesPath+"harness.adb.tmpl" )
        template.date = datetime.datetime.now()
        outfile.write( str(template) )
        outfile.close() 
        
def makeIOAdb( database, table ):
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
        instanceName = table.makeName( 
                Format.ada, 
                Qualification.unqualified, 
                ItemType.instanceName )
        outputRecord = table.makeName( 
                Format.ada, 
                Qualification.unqualified, 
                ItemType.table )
        adaTypeName = table.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.table )
        packageName = table.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.io_package )
        outfileName = paths.getPaths().srcDir+table.makeName( 
                Format.ada_filename, 
                Qualification.full, 
                ItemType.io_package ) + '.adb' 
        template = Template( file=paths.getPaths().templatesPath+"io.adb.tmpl" )
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
        template.IOName = packageName
        template.IOName_Upper_Case = packageName.upper()
        template.criteria = []
        template.nullName = table.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.null_constant )
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
        dataPackageName = database.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.data_package_name )
        template.isNullFunc = makeIsNullFunc( table, dataPackageName )

        template.retrieveByCFunc = makeRetrieveCFunc( table, asp.CONNECTION_STRING );
        
        template.retrieveBySFunc = asp.makeRetrieveSFunc( table, database );
        template.updateFunc = asp.makeUpdateProcBody( table );
        template.saveFunc = asp.makeSaveProcBody( table );
        template.deleteSpecificFunc = makeDeleteSpecificProcBody( table, asp.CONNECTION_STRING );
        template.deleteFunc = asp.makeDeleteProcBody( table );
        template.outputRecordType = outputRecord
        template.outputRecordName = adaTypeName
        template.associated = []
        template.date = datetime.datetime.now()
        for name in table.childRelations:
                fk = table.childRelations[ name ]
                parentTable = database.getOneTable( fk.childSchemaName, fk.childTableName ) #table.schemaName
                template.localWiths.append( parentTable.makeName( Format.ada, Qualification.full, ItemType.table )+"_IO") 
                if( fk.isOneToOne ):
                        childFunc = makeChildRetrieveBody( table, parentTable, fk, asp.CONNECTION_STRING )
                        template.associated.append( childFunc );
                else:
                        listAdaName = parentTable.makeName( Format.ada, Qualification.full, ItemType.alist ) # database.adaDataPackageName +"."+parentTable.adaTypeName()+"_List.Vector"
                        assocFunc = makeAssociatedRetrieveBody( table, parentTable, fk, asp.CONNECTION_STRING ); #, listAdaName, fk )
                        template.associated.append( assocFunc );
        template.dataPackageName = database.makeName( 
                Format.ada, 
                Qualification.full, 
                ItemType.data_package_name ) 
        template.preparedInsertStatementBody = asp.makePreparedInsertStatementBody( table )
        template.configuredInsertParamsBody = asp.makeConfiguredInsertParamsBody( table )
        template.preparedRetrieveStatementBodies = asp.makePreparedRetrieveStatementBodies( table )
        template.configuredRetrieveParamsBody = asp.makeConfiguredRetrieveParamsBody( table )
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
        for table in database.getAllTables():
                makeIOAds( database, database.adaTypePackages, table )
                makeIOAdb( database, table )

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

