--
-- Created by ada_generator.py on 2011-08-17 19:52:30.835516
-- 
with base_types;
--
-- Graham's 10 minute logger
--
package Logger is
   
   type Log_Level is ( debug_level, info_level, warn_level, error_level );
   
   procedure set_Log_Level( new_level : Log_Level );
   
   procedure open( filename : String; maxSizeKB : integer := -1; line_break : String := base_types.UNIX_NEW_LINE );
   
   procedure debug( message : String );
   procedure info( message : String );
   procedure warn( message : String );
   procedure error( message : String );
   
end Logger;
