with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with GNATColl.Traces;
with GNATCOLL.SQL.Postgres; 


-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===


package body Connection_Pool is 

   -- FIXME make
   -- this protected type for syncronisation
   
   use Ada.Strings.Unbounded;
   use Ada.Containers;

   log_trace : GNATColl.Traces.Trace_Handle := GNATColl.Traces.Create( "CONNECTION_POOL" );
   
   procedure Log( s : String ) is
   begin
      GNATColl.Traces.Trace( log_trace, s );
   end Log;

   -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===
   
   function Equal_Connections( left, right : dexec.Database_Connection ) return Boolean is
      use type dexec.Database_Connection;
   begin
      return left = right;
   end Equal_Connections;
   
   package Connection_List_Package is new Ada.Containers.Vectors( 
      Index_Type   => Positive, 
      Element_Type => dexec.Database_Connection,
      "=" => Equal_Connections );
   
   subtype Connection_List is Connection_List_Package.Vector;
   
   
   
   used_connections : Connection_List;
   free_connections : Connection_List;
   db_descr       : dexec.Database_Description;
   
   procedure Initialise( 
      server_name  : String;
      database     : String;
      user_name    : String;
      password     : String;
      initial_size : Positive ) is
   begin
      db_descr :=  GNATCOLL.SQL.Postgres.Setup( database, user_name, server_name, password );
      for i in 1 .. initial_size loop
         free_connections.Append( db_descr.Build_Connection );
      end loop;
   end Initialise;
   
   function Lease return dexec.Database_Connection is
      c : dexec.Database_Connection;
      n : Natural := Natural( free_connections.Length );
   begin
      if n = 0 then
         c := db_descr.Build_Connection; 
         used_connections.Append( c );         
       else
          c := free_connections.Element( n );
          used_connections.Append( c );
          free_connections.Delete( n );
      end if;
      return c;
   end Lease;
   
   procedure Return_Connection( c : dexec.Database_Connection ) is
   use Connection_List_Package;
      cur : Cursor:= used_connections.Find( c );
   begin
      used_connections.Delete( cur );
      free_connections.Append( c );
   end  Return_Connection;
   
   procedure Shutdown is
   use Connection_List_Package;
      
      procedure Close( cur : Cursor ) is
         c : dexec.Database_Connection := Element( cur );
      begin
         dexec.Free( c );
       end Close;
      
   begin
      used_connections.Iterate( Close'Access );
      used_connections.Clear;
      free_connections.Iterate( Close'Access );
      free_connections.Clear;
   end Shutdown;

   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===
     
end Connection_Pool;
