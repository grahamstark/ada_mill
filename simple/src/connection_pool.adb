with Ada.Assertions;
with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with GNATColl.Traces;
with GNATCOLL.SQL.Postgres; 

with Environment;

-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===


package body Connection_Pool is 

   -- FIXME make
   -- this protected type for syncronisation
   
   use Ada.Strings.Unbounded;
   use Ada.Containers;
   use Ada.Assertions;
   
   log_trace : GNATColl.Traces.Trace_Handle := GNATColl.Traces.Create( "CONNECTION_POOL" );
   
   procedure Log( s : String ) is
   begin
      GNATColl.Traces.Trace( log_trace, s );
   end Log;

   -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===

   --
   -- NOTE: not really a connection pool! the connection_pool.adb-full is a complete
   -- implementation. Just here to keep the interface the same.
   -- 
   -- Tests show this is just as fast;see Performance_And_Threading_Tests in the southampton project
   -- TODO write this up; allow option in build to allow full version
   -- TODO make things like auto commit, buffering options in XML
   -- 
   use dexec;
   
   function Lease return dexec.Database_Connection is
      db_descr : Database_Description := GNATCOLL.SQL.Postgres.Setup( 
         Database => Environment.Get_database_Name, 
         User     => Environment.Get_username, 
         Host     => Environment.Get_server_name, 
         Password => Environment.Get_password );
      c : Database_Connection := db_descr.Build_Connection;
   begin
      c.Automatic_Transactions( Active => True );
      return c;      
   end Lease;
   
   procedure Shutdown is
   begin
      null;
   end Shutdown;
   
   procedure Return_Connection( conn : in out dexec.Database_Connection ) is
   begin
      conn.Commit;
      Free( conn );
   end  Return_Connection;

   procedure Initialise( 
      initial_size : Positive := 30 ) is
   begin
      null;
   end Initialise;
   
   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===
     
end Connection_Pool;
