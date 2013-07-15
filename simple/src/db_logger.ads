--
-- Created by ada_generator.py on 2013-04-04 19:21:44.145319
-- 
with Base_Types;
--
-- Graham's 10 minute DB_Logger
--
-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package DB_Logger is
   -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===
   
   type Log_Level is ( debug_level, info_level, warn_level, error_level );
   
   procedure set_Log_Level( new_level : Log_Level );
   
   procedure open( filename : String; maxSizeKB : integer := -1; line_break : String := Base_Types.UNIX_NEW_LINE );
   
   procedure debug( message : String );
   procedure info( message : String );
   procedure warn( message : String );
   procedure error( message : String );

   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===
   
end DB_Logger;
