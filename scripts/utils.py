import sys, os
from string import capwords, strip, replace, lower
import re
import traceback
import shutil
import filecmp
 
INDENT = '   '
     
MAXLENGTH = 120

# FIXME DOESN'T WORK - get this to catch outside the try block?
# 
# def blowUp( label ):
        # # a = []
        # # p = a[1]
        # raise Exception( label )
        # 

# def printTrace( label = '' ):
        # traceback.format_list( traceback.extract_stack( limit = 100 ))
        # try:
                # blowUp( label )
        # except Exception as ex:  #IndexError: #
                # exc_type, exc_value, exc_traceback = sys.exc_info()
                # # exc_traceback = sys.exc_info()
                # traceback.format_list( traceback.extract_stack( limit = 100 ))
                # formatted_lines = traceback.format_exc(limit=100).splitlines()
                # traceback.print_exception( exc_type, exc_value, exc_traceback,
                              # limit=200, file=sys.stdout )
        # 


def isNullOrBlank( s ):
        return s == '' or s == None

def notNullOrBlank( s ):
        return not isNullOrBlank( s )

def concatList( alist, delim = "." ):
        l2 = [a for a in alist if a not in [None, '', ' ']]
        return delim.join( l2 ) 

def concatenate( s1, s2, delim='.'):
        if notNullOrBlank( s1 ) and notNullOrBlank( s2 ):
                return s1 + delim + s2
        elif notNullOrBlank( s1 ):
                return s1
        elif notNullOrBlank( s2 ):
                return s2
        else:
                return None

# def ioNameFromPackageName( name ):
        # return adafyName( name ).replace( '.', '_' )+"_IO";        
# 
# def packageNameToFileName( packageName ):
        # return replace( lower( packageName ), '.', '-' );
        
def nameToAdaFileName( name ):
        return replace( lower( name ), '.', '-' );
        

def readLinesBetween( fileName, startRE, endRE ):
        """
        returns an array of lines in fileName between the two markers, which
        can be regular expressions.
        Returns a zero length array if file doesn't exist or doesn't contain 
        start marker
        """
        targetLines = []
        if( not os.path.exists( fileName )):
                return targetLines;
        f = file( fileName, 'r' );
        lines = f.readlines()
        adding = 0
        for l in lines:
                header = 0
                if re.match( startRE, l ) != None:
                        adding = 1
                        header = 1
                elif re.match( endRE, l ) != None:
                        adding = 0;
                        header = 1
                if adding and not header:
                        targetLines.append( l.rstrip('\n'))
        f.close()
        return targetLines;

# fred_joe => Fred_Joe 
# and fredJoe => Fred_Joe

# different from str.capwords since that lowercases existing upper case letters first
# so you can't do 'fred_joe.xx into Fred_Joe.Xx in steps
def cwords( name, delim = ' ' ):
        l = name.split( delim )
        for i in range( len(l)):
                l[i] = str.upper( l[i][0] ) + l[i][1:]
        return delim.join( l )
                                

def adafyName( name, spaceBetweenWords = True ):
        s = ''
        # add
        nlen = len( name )
        if nlen <= 1:
                return name
        if spaceBetweenWords:
                for p in range( len(name) ):
                        if( p > 1 ):
                                if( name[p].isupper() and name[p-1].islower() ):
                                        s += '_'
                        s += name[p]
        else:
                s = name
        s = cwords( s, '_' )
        s = cwords( s, '.' )
        s = s.replace( ' ', '_' )
        return s
 
def makePlural( w ):
        if( not w.endswith('s') ):
                w += 's'
        return w


def makeDirIfDoesntExist( path ):
        if( not os.path.exists( path ) ):
                os.makedirs( path )


def makePaddedString( nIndents, char, size, lineBreak = 72 ):
        """ write a string in ADA conventions, broken up into blocks of
            at most linebreak per line
        """
        s = "\n"
        buff = ''
        size = min( size, len(char))
        for p in range( size ):
                buff += char[p]
                if( len( buff ) == lineBreak):
                        s += INDENT*nIndents + '"'+buff+ '"'
                        if( p < size ):
                               s += ' &'
                        s += "\n"
                        buff = ''
        if( len( buff ) > 0 ):
                s += INDENT*nIndents + '"'+buff+ '"'
        return s;
        
def makeCommentString( nIndents, char, size, lineBreak = 72 ):
        """ write a comment string in ADA conventions, broken up into blocks of
            at most linebreak per line
        """
        buff = ''
        s = ''
        char = strip( char )
        size = min( size, len(char))
        for p in range( size ):
                ch = char[p]
                if( ch != "\n" ):
                        buff += ch
                        if( len( buff ) >= lineBreak) and (char[p] == ' ' ):
                                s += INDENT*nIndents + '-- '+buff + "\n"
                                buff = ''
        if( len( buff ) > 0 ):
                s += INDENT*nIndents + '-- '+buff
        return s;

# from: http://stackoverflow.com/questions/480214/how-do-you-remove-duplicates-from-a-list-in-python-whilst-preserving-order
def makeUniqueArray( seq ):
        seen = set()
        seen_add = seen.add
        return [ x for x in seq if x not in seen and not seen_add(x)]

        
class Singleton:
        """
        From: http://stackoverflow.com/questions/42558/python-and-the-singleton-pattern
        A non-thread-safe helper class to ease implementing singletons.
        This should be used as a decorator -- not a metaclass -- to the
        class that should be a singleton.
        
        The decorated class can define one `__init__` function that
        takes only the `self` argument. Other than that, there are
        no restrictions that apply to the decorated class.
        
        To get the singleton instance, use the `Instance` method. Trying
        to use `__call__` will result in a `TypeError` being raised.
        
        Limitations: The decorated class cannot be inherited from.
        
        """
        
        def __init__(self, decorated):
                self._decorated = decorated
        
        def Instance(self):
                """
                Returns the singleton instance. Upon its first call, it creates a
                new instance of the decorated class and calls its `__init__` method.
                On all subsequent calls, the already created instance is returned.
                
                """
                try:
                        return self._instance
                except AttributeError:
                        self._instance = self._decorated()
                        return self._instance
        
        def __call__(self):
                raise TypeError('Singletons must be accessed through `Instance()`.')
        
        def __instancecheck__(self, inst):      
                return isinstance(inst, self._decorated)
                
def conditionalWrite( fileName, newBody ):
        """
        write the body to filename if filename doesn't already contain exactly the same contents
        """
        if os.path.isfile( fileName ): 
                tmpName = fileName + '.tmp'
                outfile = file( tmpName, 'w' );        
                outfile.write( newBody ) 
                outfile.close()
                if not filecmp.cmp( fileName, tmpName, False ):
                        print "overwriting file |" + fileName + "| with |" + tmpName + "|\n"
                        shutil.copyfile( tmpName, fileName )
                else:
                        print "leaving " + fileName + " alone"
                os.remove( tmpName )
        else:
                print "creating new " + fileName
                outfile = file( fileName, 'w' );        
                outfile.write( newBody ) 
                outfile.close()
                
