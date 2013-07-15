with DB_Commons.ODBC;
with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with GNU.DB.SQLCLI; 

package body Connection_Pool is 

   -- FIXME make
   -- this protected type for syncronisation
   
   use Ada.Strings.Unbounded;
   use Ada.Containers;
   
   function Equal_Connections( left, right : dodbc.Database_Connection ) return Boolean is
      use GNU.DB.SQLCLI;
   begin
      return left.Environment = right.Environment and left.connection = right.connection;
   end Equal_Connections;
   
   package Connection_List_Package is new Ada.Containers.Vectors( 
      Index_Type   => Positive, 
      Element_Type => dodbc.Database_Connection,
      "=" => Equal_Connections );
   
   subtype Connection_List is Connection_List_Package.Vector;
   
   used_connections : Connection_List;
   free_connections : Connection_List;
   
   t_server_name  : Unbounded_String;
   t_user_name    : Unbounded_String;
   t_password     : Unbounded_String;

   procedure Initialise( 
      server_name  : String;
      user_name    : String;
      password     : String;
      initial_size : Positive ) is
   begin
      t_server_name  := To_Unbounded_String( server_name );
      t_user_name    := To_Unbounded_String( user_name );
      t_password     := To_Unbounded_String( password );
      for i in 1 .. initial_size loop
         free_connections.Append( dodbc.Connect( server_name, user_name, password ));
      end loop;
   end Initialise;
   
   function Lease return dodbc.Database_Connection is
      c : dodbc.Database_Connection;
      n : Natural := Natural( free_connections.Length );
   begin
      if n = 0 then
         c := dodbc.Connect( 
            To_String( t_server_name ), 
            To_String( t_user_name ), 
            To_String( t_password ));
            used_connections.Append( c );         
       else
          c := free_connections.Element( n );
          used_connections.Append( c );
          free_connections.Delete( n );
      end if;
      return c;
   end Lease;
   
   procedure Return_Connection( c : dodbc.Database_Connection ) is
   use Connection_List_Package;
      cur : Cursor:= used_connections.Find( c );
   begin
      used_connections.Delete( cur );
      free_connections.Append( c );
   end  Return_Connection;
   
   procedure Shutdown is
   use Connection_List_Package;
      
      procedure Close( cur : Cursor ) is
         c : dodbc.Database_Connection := Element( cur );
      begin
         dodbc.Disconnect( c );
       end Close;
      
   begin
      used_connections.Iterate( Close'Access );
      used_connections.Clear;
      free_connections.Iterate( Close'Access );
      free_connections.Clear;
   end Shutdown;
    
end Connection_Pool;
