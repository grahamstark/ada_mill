# ////////////////////////////////
# 
# copyrigh(c) 2007 Graham Stark (graham.stark@virtual-worlds.biz)
#
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
# $Revision: 13949 $
# $Author: graham_s $
# $Date: 2012-02-08 15:40:40 +0000 (Wed, 08 Feb 2012) $
#

"""
Code to generate an SQL Schema
"""
from table_model import Table, ForeignKey, Variable, DataSource
import datetime
import paths

INDENT = '       ';
constraintCount = 0 ## global variable hack for db names, sorry

def makeFKName( table, databaseAdapter, n, constraintCount ):
        if( databaseAdapter.safeVariableNameLength < 20 ):
                kn = "c%(tc)d"%{'tc':constraintCount} ## db2 objects to long (> 18 chars) names, so give it something simple
        else:
                kn = "%(name)s_FK_%(n)d" % { 'name':table.name, 'n': n }
        return kn
        
def writeTable( table, databaseAdapter ):
        global constraintCount
        clauses = []
        for var in table.variables:
                varstring =  INDENT+var.varname+ " " + var.sqlType
                if var.isArray:
                        varstring += "[] "
                
                if( var.notNull ):
                        varstring += ' not null'
                if( var.default != None ):
                        varstring += ' default '
                        default = var.getDefaultSQLValue( databaseAdapter )
                        if( var.isStringType() ):
                                default = "'"+default+"'";
                        if var.arrayInfo != None:
                                default = var.arrayInfo.sqlArrayDefaultDeclaration( default );
                        varstring += default;
                        
                clauses.append( varstring )
        if( table.hasPrimaryKey() ):
                constraintCount += 1                        
                varstring =  INDENT+'PRIMARY KEY( ' +  ', '.join( table.primaryKey ) + " )";
                clauses.append( varstring );
        if( table.hasForeignKeys() ):
                n = 0
                for fk in table.foreignKeys:
                        constraintCount += 1                        
                        keyName = makeFKName( table, databaseAdapter, n, constraintCount )                        
                        # print "fk.childSchemaName " + fk.childSchemaName
                        # print "fk.parentSchemaName " + fk.parentSchemaName
                        if fk.inDifferentSchemas():
                                parentTableName = fk.childSchemaName + "." + fk.parentTableName
                        else:
                                parentTableName = fk.parentTableName
                        fkString = INDENT+"CONSTRAINT "+ keyName +" FOREIGN KEY( "+ ', '.join( fk.childCols ) + ') references ' + parentTableName + "( "+  ', '.join( fk.parentCols ) + " )"
                        if( (fk.onDelete != None) and (fk.onDelete != '' )):
                                fkString += " on delete " +  fk.onDelete                
                        if( (fk.onUpdate != None) and (fk.onUpdate != '' )):
                                fkString += " on update " +  fk.onUpdate                
                        clauses.append( fkString );
                        n += 1
        tabstr = 'CREATE TABLE '+table.qualifiedName()+"( \n"
        tabstr += ",\n". join( clauses );
        tabstr += "\n)"
        # append something like 'type=innodb' in the mysql case to the end of the table definitions
        tabstr += databaseAdapter.tablePostText 
        tabstr += ";\n";
        if table.hasIndexes():
                for index in table.indexes:
                        name = '_'.join( index.columns )
                        cols = ', '.join( index.columns )
                        constraintCount += 1
                        if( databaseAdapter.safeVariableNameLength < 20 ):
                                indname = "c%(tc)d"%{'tc':constraintCount}  # db2 obhects to > 18 chars in names, so give it something simple..
                        else:
                                indname =  "uniq_%(table)s_%(name)s" % { 'name': name, 'cols': cols, 'table':table.name }
                        indexStr = "CREATE INDEX %(indname)s ON %(table)s( %(cols)s );\n" %{ 'indname': indname, 'cols': cols, 'table':table.qualifiedName() }
                        tabstr += indexStr
        #
        #
        # fixme near dup of above
        #
        if table.hasUniqueIndexes():
                for index in table.uniqueIndexes:
                        name = '_'.join( index.columns )
                        cols = ', '.join( index.columns )
                        constraintCount += 1
                        if( databaseAdapter.safeVariableNameLength < 20 ):
                                indname = "c%(tc)d"%{'tc':constraintCount}
                        else:
                                indname =  "uniq_%(table)s_%(name)s" % { 'name': name, 'cols': cols, 'table':table.name }
                        indexStr = "CREATE UNIQUE INDEX %(indname)s ON %(table)s( %(cols)s );\n" %{ 'indname': indname, 'cols': cols, 'table':table.qualifiedName() }
                        tabstr += indexStr
        return tabstr

def makeDatabaseSQL( database ):
        outfile = file( paths.getPaths().dbDir + database.dataSource.database+".sql" , 'w' );
        outfile.write( "--\n-- created on "+datetime.datetime.now().strftime("%d-%m-%Y")+" by Mill\n--\n" );
        outfile.write( database.databaseAdapter.databasePreamble )
        outfile.write( "\n\n" )
        schemaNames = []
        for schema in database.schemas:
                outfile.write( "drop schema if exists " + schema.name + " cascade;\n" )
                outfile.write( "create schema " + schema.name + ";\n\n" )
                schemaNames.append( schema.name );
        # FIXME postgres only
        if( len( schemaNames ) > 0 ):
                outfile.write( "set search_path=public," + ",".join( schemaNames )+";\n\n" )
        for table in database.tables:
                outfile.write( writeTable( table, database.databaseAdapter ) )
                outfile.write( "\n" )
        for schema in database.schemas:
                outfile.write( "--\n--\n-- tables for schema " + schema.name + "  starts\n--\n--\n" )
                for table in schema.tables:
                        outfile.write( writeTable( table, database.databaseAdapter ) )
                        outfile.write( "\n" )
        outfile.write( database.databaseAdapter.databasePostText )
        outfile.close()        
