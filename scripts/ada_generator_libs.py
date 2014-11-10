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

from Cheetah.Template import Template
import paths
"""
A bunch of stuff is (or may be) shared between the db-specific ada generation module and the general one
"""
def templatesPath():
        return paths.getPaths().templatesPath+paths.getPaths().sep+paths.getPaths().sep;

def makePrimaryKeyCriterion( table, criterionName ):
        return makeCriterionList( table, criterionName, 'primaryKeyOnly', True )
        
def makeRetrieveSHeader( table, connection_string, ending ):
        return "function Retrieve( sqlstr : String; " + connection_string + " ) return " + table.adaQualifiedListName +ending;

def makeSaveProcHeader( table, connection_string, ending ): 
        return "procedure Save( "+  table.adaInstanceName + " : " + table.adaQualifiedOutputRecord+ "; overwrite : Boolean := True; " + connection_string + " )"+ ending

def makeUpdateProcHeader( table, connection_string, ending ): 
        return "procedure Update( "+  table.adaInstanceName + " : " + table.adaQualifiedOutputRecord+ "; " + connection_string + " )"+ ending

def makeDeleteSpecificProcHeader( table, connection_string, ending ):
        return "procedure Delete( " + table.adaInstanceName + " : in out " + table.adaQualifiedOutputRecord +"; "+ connection_string + " )" + ending

def makeNextFreeHeader( var, connection_string, ending ):
        return "function Next_Free_"+var.adaName+"( " + connection_string + ") return " + var.getAdaType( True ) + ending


def makeCriterionList( table, criterionName, includeAll, qualifyVarname ):
        """        
         table, 
         criterionName, 
         includeAll, 
         qualifyVarname - add the ada table name to each entry 
        """
        l = [];
        for var in table.variables:
                if( (includeAll == 'all' ) or 
                    ( (includeAll == 'primaryKeyOnly') and var.isPrimaryKey ) or
                    ( (includeAll=='allButPrimaryKey') and ( not var.isPrimaryKey ))):
                        varname = var.adaName
                        if( qualifyVarname ):
                                varname = table.adaInstanceName+"."+varname
                        critElement = "Add_"+var.adaName+"( "+criterionName +", "+ varname +" )"
                        l.append( critElement );
        return l               

def makePrimaryKeySubmitFields( table ):
        pks = []
        for var in table.variables:
                if( var.isPrimaryKey ):
                        pks.append( table.adaInstanceName + '.' + var.adaName  )
        return ', '.join( pks )
        
def makeDeleteSpecificProcBody( table, connection_string ):
        template = Template( file=templatesPath()+"delete_specific.func.tmpl" )
        template.procedureHeader = makeDeleteSpecificProcHeader( table, connection_string, ' is' )
        template.primaryKeyCriteria = makePrimaryKeyCriterion( table, 'c' )
        template.assignToNullRecord = table.adaInstanceName + " := " + table.adaQualifiedNullName
        s = str(template) 
        return s
        

