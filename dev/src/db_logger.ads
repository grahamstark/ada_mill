--
-- Created by ada_generator.py on 2012-02-23 13:59:30.956309
-- 
with Base_Types;
--
-- Graham's 10 minute DB_Logger
--
package DB_Logger is
   
   type Log_Level is ( debug_level, info_level, warn_level, error_level );
   
   procedure set_Log_Level( new_level : Log_Level );
   
   procedure open( filename : String; maxSizeKB : integer := -1; line_break : String := Base_Types.UNIX_NEW_LINE );
   
   procedure debug( message : String );
   procedure info( message : String );
   procedure warn( message : String );
   procedure error( message : String );
   
end DB_Logger;
