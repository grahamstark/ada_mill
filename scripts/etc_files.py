import paths
from Cheetah.Template import Template
import datetime
from utils import adafyName, readLinesBetween
from table_model import Format, ItemType, Qualification

def writeODBCIni( database ):
        dbname = database.databaseName
        outfile = file( paths.getPaths().etcDir + 'odbc.ini' , 'w' );
        ## stop cheeta dying because of unicode characters; no idea what's going on here.
        dbtype = database.dataSource.databaseType.encode('ascii', 'replace') 
        odbcName = paths.getPaths().templatesPath + dbtype + '_odbc_ini.tmpl'
        template = Template( file=odbcName )
        template.date = datetime.datetime.now()
        template.description = 'Database '+ database.description 
        template.database = dbname 
        template.dbDecl = '['+dbname+']'
        outfile.write( str(template) )
        outfile.close()
        
def writeLoggingConfigFile( database ):
        "GNATCOLL config file, with one line per logged package"
        outfileName = paths.getPaths().etcDir+ 'logging_config_file.txt'
        template = Template( file=paths.getPaths().templatesPath+"logging_config_file.txt.tmpl" )
        template.dbPackages = []
        template.customLogs = readLinesBetween( outfileName, ".*CUSTOM.*LOGGING.*START", ".*CUSTOM.*LOGGING.*END" )

        template.logFileName = database.databaseName+".log" # paths.getPaths().logDir+
        for table in database.tables:
                instanceName = table.makeName( Format.ada, Qualification.full, ItemType.io_package ).upper()
                template.dbPackages.append( instanceName );
        template.testCase = adafyName( database.databaseName +  '_test' ).upper();
        outfile = file( outfileName, 'w' );
        outfile.write( str(template) )
        outfile.close()
        
#
# write a sample odbc file and project file into etc/ in the output dir
#
def writeMiscFiles( database ):
        writeODBCIni( database )
        writeLoggingConfigFile( database )
