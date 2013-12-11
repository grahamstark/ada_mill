from paths import WORKING_PATHS
from Cheetah.Template import Template
import datetime
from utils import adafyName, readLinesBetween


def writeODBCIni( database ):
        dbname = database.dataSource.database
        outfile = file( WORKING_PATHS.etcDir + 'odbc.ini' , 'w' );
        ## stop cheeta dying because of unicode characters; no idea what's going on here.
        dbtype = database.dataSource.databaseType.encode('ascii', 'replace') 
        odbcName = WORKING_PATHS.templatesPath + dbtype + '_odbc_ini.tmpl'
        template = Template( file=odbcName )
        template.date = datetime.datetime.now()
        template.description = 'Database '+ database.description 
        template.database = dbname 
        template.dbDecl = '['+dbname+']'
        outfile.write( str(template) )
        outfile.close()
        
def writeLoggingConfigFile( database ):
        "GNATCOLL config file, with one line per logged package"
        outfileName = WORKING_PATHS.etcDir+ 'logging_config_file.txt'
        template = Template( file=WORKING_PATHS.templatesPath+"logging_config_file.txt.tmpl" )
        template.dbPackages = []
        template.customLogs = readLinesBetween( outfileName, ".*CUSTOM.*LOGGING.*START", ".*CUSTOM.*LOGGING.*END" )

        template.logFileName = WORKING_PATHS.logDir+database.dataSource.database+".log"
        for table in database.tables:
                template.dbPackages.append( (table.adaTypeName+"_IO").upper() );
        template.testCase = adafyName( database.dataSource.database +  '_test' ).upper();
        outfile = file( outfileName, 'w' );
        outfile.write( str(template) )
        outfile.close()
        
        
#
# write a sample odbc file and project file into etc/ in the output dir
#
def writeMiscFiles( database ):
        writeODBCIni( database )
        writeLoggingConfigFile( database )
