with GNATCOLL.SQL.Exec;

-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package Connection_Pool is

    -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===
   
   package dexec renames GNATCOLL.SQL.Exec; 

   procedure Initialise( initial_size : Positive := 30 );
   function Lease return dexec.Database_Connection;
   procedure Return_Connection( conn : in out dexec.Database_Connection );
   procedure Shutdown;

   -- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===
   
end Connection_Pool;
