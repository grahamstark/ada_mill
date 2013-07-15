with GNATCOLL.SQL.Exec;

-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package Connection_Pool is

    -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===
   
   package dexec renames GNATCOLL.SQL.Exec; 

   procedure Initialise( 
      server_name  : String;
      database     : String;
      user_name    : String;
      password     : String;
      initial_size : Positive );
      
   function Lease return dexec.Database_Connection;
   procedure Return_Connection( c : dexec.Database_Connection );
   procedure Shutdown;

   -- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===
   
   
end Connection_Pool;
