from lxml import etree

def setBoolAttribute( node, attr, b ):
        if( b ):
                s = 'true'
        else:
                s = 'false'
        node.set( attr, s )

def setIntAttribute( node, attr, b ):
        if( b == None ):
                return
        s = str( b )
        node.set( attr, s )

def setFloatAttribute( node, attr, b ):
        if( b == None ):
                return
        s = str(b)
        node.set( attr, s )


def getBoolAttribute( node, attr, default=None ):
        a = get( node, attr, default )
        return ((a == '1') or ( a == 'true' ))
       

def getIntAttribute( node, attr, default=None ):
        a = get( node, attr, default )
        if( a == None ):
                return int(default)
        return int( a )
        
def getFloatAttribute( node, attr, default=None ):
        a = get( node, attr, default )
        if( a == None ):
                return float(default)
        return float( a )        
