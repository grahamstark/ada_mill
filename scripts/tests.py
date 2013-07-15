import utils

lines = utils.readLinesBetween( "../simple/src/my_record_io.ads", ".*CUSTOM.*START.*", ".*CUSTOM.*END.*" );
customImports = utils.readLinesBetween( outfile, ".*CUSTOM.*IMPORT.*START", ".*CUSTOM.*IMPORT.*END" )
customTypes = utils.readLinesBetween( outfile, ".*CUSTOM.*TYPES.*START", ".*CUSTOM.*TYPES.*END" )
customProcs = utils.readLinesBetween( outfile, ".*CUSTOM.*PROCS.*START", ".*CUSTOM.*PROCS.*END" )

print lines
