with DB_Commons.ODBC;

-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package Connection_Pool is

   -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===

   package dodbc renames DB_Commons.ODBC;

   --
   -- Note: server_name is unused here but here for compatibility 
   -- with other drivers; just use database 
   --
   procedure Initialise( 
      server_name   : String;
      database_name : String;
      user_name     : String;
      password      : String;
      initial_size  : Positive );
      
   function Lease return dodbc.Database_Connection;
   procedure Return_Connection( c : dodbc.Database_Connection );
   procedure Shutdown;
   
   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===
   
end Connection_Pool;
