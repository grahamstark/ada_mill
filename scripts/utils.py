import sys, os
from string import capwords, strip
import re

INDENT = '   '
     
MAXLENGTH = 120

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
def adafyName( name ):
        s = ''
        for p in range( len(name) ):
                if( p > 1 ):
                        if( name[p].isupper() and name[p-1].islower() ):
                                s += '_'
                s += name[p]                
        return capwords( s, '_' ).replace( ' ', '_' )
 
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



#
# This is stolen from: http://norvig.com/python-iaq.html ?? Licence ??
#
class Enum:

    """Create an enumerated type, then add var/value pairs to it.
    The constructor and the method .ints(names) take a list of variable names,
    and assign them consecutive integers as values.    The method .strs(names)
    assigns each variable name to itself (that is variable 'v' has value 'v').
    The method .vals(a=99, b=200) allows you to assign any value to variables.
    A 'list of variable names' can also be a string, which will be .split().
    The method .end() returns one more than the maximum int value.
    Example: opcodes = Enum("add sub load store").vals(illegal=255)."""
  
    def __init__(self, names=[]): self.ints(names)
    
    def match( self, var ):
        """ return the value matching the string var. or raise and AttributeError."""
        if not var in vars(self).keys(): 
            raise AttributeError("no such name '" + var + "' in enum")
        return vars(self)[ var ]
        

    def set(self, var, val):
        """Set var to the value val in the enum."""
        if var in vars(self).keys(): raise AttributeError("duplicate var in enum")
        if val in vars(self).values(): raise ValueError("duplicate value in enum")
        vars(self)[var] = val
        return self
  
    def strs(self, names):
        """Set each of the names to itself (as a string) in the enum."""
        for var in self._parse(names): self.set(var, var)
        return self

    def ints(self, names):
        """Set each of the names to the next highest int in the enum."""
        for var in self._parse(names): self.set(var, self.end())
        return self

    def vals(self, **entries):
        """Set each of var=val pairs in the enum."""
        for (var, val) in entries.items(): self.set(var, val)
        return self

    def end(self):
        """One more than the largest int value in the enum, or 0 if none."""
        try: return max([x for x in vars(self).values() if type(x)==type(0)]) + 1
        except ValueError: return 0
    
    def _parse(self, names):
        ### If names is a string, parse it as a list of names.
        if type(names) == type(""): return names.split()
        else: return names
