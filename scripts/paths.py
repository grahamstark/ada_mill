# ////////////////////////////////
#
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
# $Revision: 15956 $
# $Author: graham_s $
# $Date: 2013-04-04 18:46:31 +0100 (Thu, 04 Apr 2013) $
#
import sys, os
from utils import makeDirIfDoesntExist

class Paths:
        def __repr__( self ):
                s = ''
                s += " sep = |"+self.sep+"|\n"
                s += " scriptPath = |"+self.scriptPath+"|\n"
                s += " templatesPath = |"+self.templatesPath+"|\n"
                s += " outputRootDir = |"+self.outputRootDir+"|\n"
                s += " srcDir = |"+self.srcDir+"|\n"
                s += " dbDir = |"+self.dbDir+"|\n"
                s += " xmlDir = |"+self.xmlDir+"|\n"
                s += " testsDir = |"+self.testsDir+"|\n"
                s += " binDir = |"+self.binDir+"|\n"
                return s
        
        def makeTargetDirs( self ):
                makeDirIfDoesntExist( self.dbDir )
                makeDirIfDoesntExist( self.srcDir )                
                makeDirIfDoesntExist( self.testsDir )
                makeDirIfDoesntExist( self.binDir )
                makeDirIfDoesntExist( self.etcDir )
                makeDirIfDoesntExist( self.logDir )
                
        def __init__( self ):
                self.sep = os.path.sep        
                self.scriptPath = sys.path[0]
                self.templatesPath = self.scriptPath+self.sep+'templates'+self.sep
                self.outputRootDir = sys.argv[1]+self.sep
                self.srcDir = self.outputRootDir+"src"+self.sep
                self.dbDir = self.outputRootDir+"database"+self.sep
                self.xmlDir = self.outputRootDir+"xml"+self.sep
                self.testsDir = self.outputRootDir+"tests"+self.sep
                self.binDir = self.outputRootDir+"bin"+self.sep
                self.etcDir = self.outputRootDir+"etc"+self.sep
                self.logDir = self.outputRootDir+"log"+self.sep
                
#                
# global variable, sorry
#
WORKING_PATHS = Paths()
