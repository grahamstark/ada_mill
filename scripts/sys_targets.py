class Targets:
        def __repr__( self ):
                s = ''
                s += " database type = |"+self.databaseType+"|\n"
                s += " binding = |"+self.binding+"|\n"
            
            
        def __init__( self, binding, databaseType ):
                self.databaseType = databaseType       
                self.binding = binding        

TARGETS = Targets( "", "" );
