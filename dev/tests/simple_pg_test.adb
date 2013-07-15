--
-- Created by ada_generator.py on 2012-02-23 13:59:31.023092
-- 


with Ada.Calendar;
with Ada.Containers.Vectors;
with Ada.Exceptions;
with Ada.Strings.Unbounded; 

with AUnit.Assertions;             
with AUnit.Test_Cases; 
   
with DB_Logger;
with Base_Types;
with Environment;
with DB_Commons.ODBC;
with DB_Commons;
with Simple_Pg_Data;

with Connection_Pool;

with Standard_User_IO;
with Standard_Group_IO;
with Group_Members_IO;

package body Simple_Pg_Test is

   RECORDS_TO_ADD     : constant integer := 100;
   RECORDS_TO_DELETE  : constant integer := 50;
   RECORDS_TO_ALTER   : constant integer := 50;
   
   package d renames DB_Commons;
   
   use Base_Types;
   use ada.strings.Unbounded;
   use Simple_Pg_Data;
   
   use AUnit.Test_Cases;
   use AUnit.Assertions;
   use AUnit.Test_Cases.Registration;
   
   use Ada.Strings.Unbounded;
   use Ada.Exceptions;
   use Ada.Calendar;
   
   
--
-- test creating and deleting records  
--
--
   procedure Standard_User_Create_Test(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
      --
      -- local print iteration routine
      --
      procedure Print( pos : Standard_User_List.Cursor ) is 
      Standard_User_Test_Item : Simple_Pg_Data.Standard_User;
      begin
         Standard_User_Test_Item := Standard_User_List.element( pos );
         DB_Logger.info( To_String( Standard_User_Test_Item ));
      end print;

   
      Standard_User_Test_Item : Simple_Pg_Data.Standard_User;
      Standard_User_test_list : Simple_Pg_Data.Standard_User_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      DB_Logger.info( "Starting test Standard_User_Create_Test" );
      
      DB_Logger.info( "Clearing out the table" );
      Standard_User_io.Delete( criteria );
      
      DB_Logger.info( "Standard_User_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         Standard_User_Test_Item.User_Id := Standard_User_io.Next_Free_User_Id;
         Standard_User_Test_Item.Username := To_Unbounded_String("dat forUsername");
         Standard_User_Test_Item.Password := To_Unbounded_String("dat forPassword");
         Standard_User_Test_Item.Salary := 10201.11;
         Standard_User_Test_Item.Rate := 1010100.012;
         Standard_User_Test_Item.Date_Created := Ada.Calendar.Clock;
         Standard_User_io.Save( Standard_User_Test_Item, False );         
      end loop;
      
      Standard_User_test_list := Standard_User_Io.Retrieve( criteria );
      
      DB_Logger.info( "Standard_User_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         Standard_User_Test_Item := Standard_User_List.element( Standard_User_test_list, i );
         Standard_User_Test_Item.Username := To_Unbounded_String("Altered::dat forUsername");
         Standard_User_Test_Item.Password := To_Unbounded_String("Altered::dat forPassword");
         Standard_User_io.Save( Standard_User_Test_Item );         
      end loop;
      
      DB_Logger.info( "Standard_User_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         Standard_User_Test_Item := Standard_User_List.element( Standard_User_test_list, i );
         Standard_User_io.Delete( Standard_User_Test_Item );         
      end loop;
      
      DB_Logger.info( "Standard_User_Create_Test: retrieve all records" );
      Standard_User_List.iterate( Standard_User_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      DB_Logger.info( "Ending test Standard_User_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         DB_Logger.error( "Standard_User_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Standard_User_Create_Test : exception thrown " & Exception_Information(Error) );
   end Standard_User_Create_Test;

   
--
-- test creating and deleting records  
--
--
   procedure Standard_Group_Create_Test(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
      --
      -- local print iteration routine
      --
      procedure Print( pos : Standard_Group_List.Cursor ) is 
      Standard_Group_Test_Item : Simple_Pg_Data.Standard_Group;
      begin
         Standard_Group_Test_Item := Standard_Group_List.element( pos );
         DB_Logger.info( To_String( Standard_Group_Test_Item ));
      end print;

   
      Standard_Group_Test_Item : Simple_Pg_Data.Standard_Group;
      Standard_Group_test_list : Simple_Pg_Data.Standard_Group_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      DB_Logger.info( "Starting test Standard_Group_Create_Test" );
      
      DB_Logger.info( "Clearing out the table" );
      Standard_Group_io.Delete( criteria );
      
      DB_Logger.info( "Standard_Group_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         Standard_Group_Test_Item.Name := To_Unbounded_String( "k_" & i'img );
         Standard_Group_Test_Item.Description := To_Unbounded_String("dat forDescription");
         Standard_Group_io.Save( Standard_Group_Test_Item, False );         
      end loop;
      
      Standard_Group_test_list := Standard_Group_Io.Retrieve( criteria );
      
      DB_Logger.info( "Standard_Group_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         Standard_Group_Test_Item := Standard_Group_List.element( Standard_Group_test_list, i );
         Standard_Group_Test_Item.Description := To_Unbounded_String("Altered::dat forDescription");
         Standard_Group_io.Save( Standard_Group_Test_Item );         
      end loop;
      
      DB_Logger.info( "Standard_Group_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         Standard_Group_Test_Item := Standard_Group_List.element( Standard_Group_test_list, i );
         Standard_Group_io.Delete( Standard_Group_Test_Item );         
      end loop;
      
      DB_Logger.info( "Standard_Group_Create_Test: retrieve all records" );
      Standard_Group_List.iterate( Standard_Group_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      DB_Logger.info( "Ending test Standard_Group_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         DB_Logger.error( "Standard_Group_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Standard_Group_Create_Test : exception thrown " & Exception_Information(Error) );
   end Standard_Group_Create_Test;

   
--
-- test creating and deleting records  
--
--
   procedure Group_Members_Create_Test(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
      --
      -- local print iteration routine
      --
      procedure Print( pos : Group_Members_List.Cursor ) is 
      Group_Members_Test_Item : Simple_Pg_Data.Group_Members;
      begin
         Group_Members_Test_Item := Group_Members_List.element( pos );
         DB_Logger.info( To_String( Group_Members_Test_Item ));
      end print;

   
      Group_Members_Test_Item : Simple_Pg_Data.Group_Members;
      Group_Members_test_list : Simple_Pg_Data.Group_Members_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      DB_Logger.info( "Starting test Group_Members_Create_Test" );
      
      DB_Logger.info( "Clearing out the table" );
      Group_Members_io.Delete( criteria );
      
      DB_Logger.info( "Group_Members_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         Group_Members_Test_Item.Group_Name := To_Unbounded_String( "k_" & i'img );
         Group_Members_Test_Item.User_Id := Group_Members_io.Next_Free_User_Id;
         Group_Members_io.Save( Group_Members_Test_Item, False );         
      end loop;
      
      Group_Members_test_list := Group_Members_Io.Retrieve( criteria );
      
      DB_Logger.info( "Group_Members_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         Group_Members_Test_Item := Group_Members_List.element( Group_Members_test_list, i );
         Group_Members_io.Save( Group_Members_Test_Item );         
      end loop;
      
      DB_Logger.info( "Group_Members_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         Group_Members_Test_Item := Group_Members_List.element( Group_Members_test_list, i );
         Group_Members_io.Delete( Group_Members_Test_Item );         
      end loop;
      
      DB_Logger.info( "Group_Members_Create_Test: retrieve all records" );
      Group_Members_List.iterate( Group_Members_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      DB_Logger.info( "Ending test Group_Members_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         DB_Logger.error( "Group_Members_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Group_Members_Create_Test : exception thrown " & Exception_Information(Error) );
   end Group_Members_Create_Test;

   
   
   
   
   
   procedure Register_Tests (T : in out Test_Case) is
   begin
      --
      -- Tests of record creation/deletion
      --
      Register_Routine (T, Standard_User_Create_Test'Access, "Test of Creation and deletion of Standard_User" );
      Register_Routine (T, Standard_Group_Create_Test'Access, "Test of Creation and deletion of Standard_Group" );
      Register_Routine (T, Group_Members_Create_Test'Access, "Test of Creation and deletion of Group_Members" );
      --
      -- Tests of foreign key relationships
      --
      --  not implemented yet Register_Routine (T, Standard_User_Child_Retrieve_Test'Access, "Test of Finding Children of Standard_User" );
      --  not implemented yet Register_Routine (T, Standard_Group_Child_Retrieve_Test'Access, "Test of Finding Children of Standard_Group" );
   end Register_Tests;
   
   --  Register routines to be run
   
   
   function Name ( t : Test_Case ) return Message_String is
   begin
          return Format( "Simple_Pg_Test Test Suite" );
   end Name;

   
   --  Preparation performed before each routine:
   procedure Set_Up( t : in out Test_Case ) is
   begin
      null;
   end Set_Up;
   
   --  Preparation performed before each routine:
   procedure Shut_Down( t : in out Test_Case ) is
   begin
      null; -- Connection_Pool.Shutdown;
   end Shut_Down;
begin
        DB_Logger.set_Log_Level( DB_Logger.debug_level );
      Connection_Pool.Initialise(
         Environment.Get_Server_Name,
         Environment.Get_Username,
         Environment.Get_Password,
         50 );

end Simple_Pg_Test;
