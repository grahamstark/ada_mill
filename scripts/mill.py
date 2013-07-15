#!/usr/bin/env python
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
# $Revision: 16126 $
# $Author: graham_s $
# $Date: 2013-05-24 16:59:01 +0100 (Fri, 24 May 2013) $
#

import sys, os
from lxml import etree
from sql_generator import makeDatabaseSQL
        
from ada_generator import makeDataADS, makeDataADB, makeCommons, makeBasicTypesADB, \
        makeBaseTypesADS, makeEnvironmentADS, makeEnvironmentADB, \
        writeTestCaseADS, writeHarness, writeSuiteADB, writeTestCaseADB, \
        makeIO, writeConnectionPool

from paths import WORKING_PATHS
from table_model import parseXMLFiles, databaseToXML
from etc_files import writeMiscFiles;
from sys_targets import TARGETS;

if( len( sys.argv ) < 3 ):
        sys.exit("use python mill.py [target dir; should have schemas in xml/ dir] [binding (odbc|)")

binding = sys.argv[2]



print "***** using the following paths ********"

print WORKING_PATHS ## a global variable, I'm afraid

WORKING_PATHS.makeTargetDirs();

print "parsing schema"
database = parseXMLFiles()
TARGETS.binding = binding
TARGETS.databaseType = database.dataSource.databaseType

if TARGETS.binding == 'odbc':
        import ada_specific_odbc as asp
elif TARGETS.binding == 'native':
        if TARGETS.databaseType == 'postgres':
                import ada_specific_postgres as asp
        elif sys_targets.TARGETS.databaseType == 'sqlite':
                import ada_specific_sqlite as asp

print database;
print "writing sql database schema to " + WORKING_PATHS.dbDir
makeDatabaseSQL( database )

print "making ada source files to " + WORKING_PATHS.srcDir
makeDataADS( database );
makeDataADB( database );

makeEnvironmentADS( database.dataSource )
makeEnvironmentADB( database.dataSource )

makeBaseTypesADS( database );
makeBasicTypesADB();
makeIO( database )
makeCommons()
asp.makeDriverCommons()
writeConnectionPool();
asp.writeProjectFile( database );

print "writing sample configuration and project file to "+WORKING_PATHS.etcDir
writeMiscFiles( database )
print "writing test cases"
writeTestCaseADS( database )
writeSuiteADB( database )
writeHarness()
writeTestCaseADB( database )

print "done!"
## test testcode
# doc = databaseToXML( database )
# print etree.tostring( doc, method='xml', encoding="UTF-8", pretty_print=True )
