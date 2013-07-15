with DB_Commons.ODBC;

package Connection_Pool is

   package dodbc renames DB_Commons.ODBC;

   procedure Initialise( 
      server_name  : String;
      user_name    : String;
      password     : String;
      initial_size : Positive );
      
   function Lease return dodbc.Database_Connection;
   procedure Return_Connection( c : dodbc.Database_Connection );
   procedure Shutdown;
   
end Connection_Pool;
