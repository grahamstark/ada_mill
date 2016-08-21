with Ada.Assertions;
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
   use Ada.Assertions;
   
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
   use type Ada.Containers.Count_Type;
   
   protected type Pool_Type is

      entry Lease( c : out dexec.Database_Connection );
      procedure Return_Connection( c : dexec.Database_Connection );
      procedure Initialise( 
         server_name  : String;
         database     : String;
         user_name    : String;
         password     : String;
         initial_size : Positive;
         max_size     : Natural );
      procedure Shutdown;
         
   private
      maximum_size     : Count_Type;
      used_connections : Connection_List;
      free_connections : Connection_List;
      db_descr         : dexec.Database_Description;
   end Pool_Type;
   
   protected body Pool_Type is
   
         function Make_Connection( auto_transactions : Boolean := False ) return dexec.Database_Connection is
         dc : dexec.Database_Connection := db_descr.Build_Connection;
      begin
         dc.Automatic_Transactions( auto_transactions );
         return dc;      
      end Make_Connection;
   
      procedure Initialise( 
         server_name  : String;
         database     : String;
         user_name    : String;
         password     : String;
         initial_size : Positive;
         max_size     : Natural ) is
      begin
         if( max_size = 0 ) then 
            maximum_size := Count_Type( initial_size );
         else                      
            maximum_size := Count_Type( max_size );
         end if;
         Assert( Natural( maximum_size ) >= initial_size, "maximum_size < initial_size " & maximum_size'Img & " : " & initial_size'Img );
         db_descr :=  GNATCOLL.SQL.Postgres.Setup( database, user_name, server_name, password );
         for i in 1 .. initial_size loop
            free_connections.Append( Make_Connection );
         end loop;
      end Initialise;
      
      entry Lease( c : out dexec.Database_Connection ) when
           free_connections.Length > 0  or 
           ( free_connections.Length + used_connections.Length ) < maximum_size is
         nf : constant Natural := Natural( free_connections.Length ); 
      begin
         Log( "leasing, before; free connections: " & free_connections.Length'Img &
              " used: " & used_connections.Length'Img );
         if nf = 0  then
            c := Make_Connection; 
            used_connections.Append( c );
         else
            c := free_connections.Element( nf );
            used_connections.Append( c );
            free_connections.Delete( nf );
         end if;
      end Lease;
      
      procedure Return_Connection( c : dexec.Database_Connection ) is
      use Connection_List_Package;
         cur : Cursor:= used_connections.Find( c );
      begin
         Log( "returning; before- free connections: " & free_connections.Length'Img &
           " used: " & used_connections.Length'Img );
         used_connections.Delete( cur );
         if c.In_Transaction then
            c.Commit_Or_Rollback;
         end if;
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

   end Pool_Type;
   
   pool : Pool_Type;
   
   function Lease return dexec.Database_Connection is
      c : dexec.Database_Connection;
   begin
      pool.lease( c );
      return c;
   end Lease;
   
   procedure Shutdown is
   begin
      pool.Shutdown;
   end Shutdown;
   
   procedure Return_Connection( conn : in out dexec.Database_Connection ) is
   begin
      pool.Return_Connection( conn );
   end  Return_Connection;
   
   procedure Initialise( 
      server_name  : String;
      database     : String;
      user_name    : String;
      password     : String;
      initial_size : Positive;
      maximum_size : Natural := 0 ) is
   begin
      pool.Initialise( 
         server_name, 
         database, 
         user_name,   
         password,    
         initial_size,
         maximum_size );
   end Initialise;

   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===
     
end Connection_Pool;
