--
-- Created by ada_generator.py on 2013-06-11 18:39:29.917590
-- 


with Ada.Calendar;
with Ada.Exceptions;
with Ada.Strings.Unbounded; 

with GNATColl.Traces;

with AUnit.Assertions;             
with AUnit.Test_Cases; 

with Base_Types;
with Environment;

with DB_Commons;
with Simple_Pg_Data;

with Connection_Pool;

with Standard_User_Type_IO;
with Standard_Group_Type_IO;
with Group_Members_Type_IO;


-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package body Simple_Pg_Test is

   RECORDS_TO_ADD     : constant integer := 100;
   RECORDS_TO_DELETE  : constant integer := 50;
   RECORDS_TO_ALTER   : constant integer := 50;
   
   package d renames DB_Commons;
   
   use Base_Types;
   use ada.strings.Unbounded;
   use Simple_Pg_Data;

   log_trace : GNATColl.Traces.Trace_Handle := GNATColl.Traces.Create( "SIMPLE_PG_TEST" );
   
   procedure Log( s : String ) is
   begin
      GNATColl.Traces.Trace( log_trace, s );
   end Log;

   
      -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===

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
   procedure Standard_User_Type_Create_Test(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
      --
      -- local print iteration routine
      --
      procedure Print( pos : Standard_User_Type_List.Cursor ) is 
      standard_user_test_item : Simple_Pg_Data.Standard_User_Type;
      begin
         standard_user_test_item := Standard_User_Type_List.element( pos );
         Log( To_String( standard_user_test_item ));
      end print;

   
      standard_user_test_item : Simple_Pg_Data.Standard_User_Type;
      standard_user_test_list : Simple_Pg_Data.Standard_User_Type_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      Log( "Starting test Standard_User_Type_Create_Test" );
      
      Log( "Clearing out the table" );
      Standard_User_Type_IO.Delete( criteria );
      
      Log( "Standard_User_Type_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         standard_user_test_item.User_Id := Standard_User_Type_IO.Next_Free_User_Id;
         standard_user_test_item.Username := To_Unbounded_String("dat forUsername");
         standard_user_test_item.Password := To_Unbounded_String("dat forPassword");
         -- missingstandard_user_test_item declaration ;
         -- missingstandard_user_test_item declaration ;
         -- missingstandard_user_test_item declaration ;
         standard_user_test_item.A_Real := 1010100.012;
         standard_user_test_item.A_Decimal := 10201.11;
         standard_user_test_item.A_Double := 1010100.012;
         -- missingstandard_user_test_item declaration ;
         standard_user_test_item.A_Varchar := To_Unbounded_String("dat forA_Varchar");
         standard_user_test_item.A_Date := Ada.Calendar.Clock;
         Standard_User_Type_IO.Save( standard_user_test_item, False );         
      end loop;
      
      standard_user_test_list := Standard_User_Type_IO.Retrieve( criteria );
      
      Log( "Standard_User_Type_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         standard_user_test_item := Standard_User_Type_List.element( standard_user_test_list, i );
         standard_user_test_item.Username := To_Unbounded_String("Altered::dat forUsername");
         standard_user_test_item.Password := To_Unbounded_String("Altered::dat forPassword");
         standard_user_test_item.A_Varchar := To_Unbounded_String("Altered::dat forA_Varchar");
         Standard_User_Type_IO.Save( standard_user_test_item );         
      end loop;
      
      Log( "Standard_User_Type_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         standard_user_test_item := Standard_User_Type_List.element( standard_user_test_list, i );
         Standard_User_Type_IO.Delete( standard_user_test_item );         
      end loop;
      
      Log( "Standard_User_Type_Create_Test: retrieve all records" );
      Standard_User_Type_List.iterate( standard_user_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      Log( "Ending test Standard_User_Type_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         Log( "Standard_User_Type_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Standard_User_Type_Create_Test : exception thrown " & Exception_Information(Error) );
   end Standard_User_Type_Create_Test;

   
--
-- test creating and deleting records  
--
--
   procedure Standard_Group_Type_Create_Test(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
      --
      -- local print iteration routine
      --
      procedure Print( pos : Standard_Group_Type_List.Cursor ) is 
      standard_group_test_item : Simple_Pg_Data.Standard_Group_Type;
      begin
         standard_group_test_item := Standard_Group_Type_List.element( pos );
         Log( To_String( standard_group_test_item ));
      end print;

   
      standard_group_test_item : Simple_Pg_Data.Standard_Group_Type;
      standard_group_test_list : Simple_Pg_Data.Standard_Group_Type_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      Log( "Starting test Standard_Group_Type_Create_Test" );
      
      Log( "Clearing out the table" );
      Standard_Group_Type_IO.Delete( criteria );
      
      Log( "Standard_Group_Type_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         standard_group_test_item.Name := To_Unbounded_String( "k_" & i'img );
         standard_group_test_item.Description := To_Unbounded_String("dat forDescription");
         Standard_Group_Type_IO.Save( standard_group_test_item, False );         
      end loop;
      
      standard_group_test_list := Standard_Group_Type_IO.Retrieve( criteria );
      
      Log( "Standard_Group_Type_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         standard_group_test_item := Standard_Group_Type_List.element( standard_group_test_list, i );
         standard_group_test_item.Description := To_Unbounded_String("Altered::dat forDescription");
         Standard_Group_Type_IO.Save( standard_group_test_item );         
      end loop;
      
      Log( "Standard_Group_Type_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         standard_group_test_item := Standard_Group_Type_List.element( standard_group_test_list, i );
         Standard_Group_Type_IO.Delete( standard_group_test_item );         
      end loop;
      
      Log( "Standard_Group_Type_Create_Test: retrieve all records" );
      Standard_Group_Type_List.iterate( standard_group_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      Log( "Ending test Standard_Group_Type_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         Log( "Standard_Group_Type_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Standard_Group_Type_Create_Test : exception thrown " & Exception_Information(Error) );
   end Standard_Group_Type_Create_Test;

   
--
-- test creating and deleting records  
--
--
   procedure Group_Members_Type_Create_Test(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
      --
      -- local print iteration routine
      --
      procedure Print( pos : Group_Members_Type_List.Cursor ) is 
      group_members_test_item : Simple_Pg_Data.Group_Members_Type;
      begin
         group_members_test_item := Group_Members_Type_List.element( pos );
         Log( To_String( group_members_test_item ));
      end print;

   
      group_members_test_item : Simple_Pg_Data.Group_Members_Type;
      group_members_test_list : Simple_Pg_Data.Group_Members_Type_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      Log( "Starting test Group_Members_Type_Create_Test" );
      
      Log( "Clearing out the table" );
      Group_Members_Type_IO.Delete( criteria );
      
      Log( "Group_Members_Type_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         group_members_test_item.Group_Name := To_Unbounded_String( "k_" & i'img );
         group_members_test_item.User_Id := Group_Members_Type_IO.Next_Free_User_Id;
         Group_Members_Type_IO.Save( group_members_test_item, False );         
      end loop;
      
      group_members_test_list := Group_Members_Type_IO.Retrieve( criteria );
      
      Log( "Group_Members_Type_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         group_members_test_item := Group_Members_Type_List.element( group_members_test_list, i );
         Group_Members_Type_IO.Save( group_members_test_item );         
      end loop;
      
      Log( "Group_Members_Type_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         group_members_test_item := Group_Members_Type_List.element( group_members_test_list, i );
         Group_Members_Type_IO.Delete( group_members_test_item );         
      end loop;
      
      Log( "Group_Members_Type_Create_Test: retrieve all records" );
      Group_Members_Type_List.iterate( group_members_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      Log( "Ending test Group_Members_Type_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         Log( "Group_Members_Type_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Group_Members_Type_Create_Test : exception thrown " & Exception_Information(Error) );
   end Group_Members_Type_Create_Test;

   
   
   
   
   
   procedure Register_Tests (T : in out Test_Case) is
   begin
      --
      -- Tests of record creation/deletion
      --
      Register_Routine (T, Standard_User_Type_Create_Test'Access, "Test of Creation and deletion of Standard_User_Type" );
      Register_Routine (T, Standard_Group_Type_Create_Test'Access, "Test of Creation and deletion of Standard_Group_Type" );
      Register_Routine (T, Group_Members_Type_Create_Test'Access, "Test of Creation and deletion of Group_Members_Type" );
      --
      -- Tests of foreign key relationships
      --
      --  not implemented yet Register_Routine (T, Standard_User_Type_Child_Retrieve_Test'Access, "Test of Finding Children of Standard_User_Type" );
      --  not implemented yet Register_Routine (T, Standard_Group_Type_Child_Retrieve_Test'Access, "Test of Finding Children of Standard_Group_Type" );
   end Register_Tests;
   
   --  Register routines to be run
   
   
   function Name ( t : Test_Case ) return Message_String is
   begin
      return Format( "Simple_Pg_Test Test Suite" );
   end Name;

   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===
   
   --  Preparation performed before each routine:
   procedure Set_Up( t : in out Test_Case ) is
   begin
       Connection_Pool.Initialise(
              Environment.Get_Server_Name,
              Environment.Get_Database_Name,
              Environment.Get_Username,
              Environment.Get_Password,
              10 );
      GNATColl.Traces.Parse_Config_File( "./etc/logging_config_file.txt" );
   end Set_Up;
   
   --  Preparation performed after each routine:
   procedure Shut_Down( t : in out Test_Case ) is
   begin
      Connection_Pool.Shutdown;
   end Shut_Down;
   
   
begin
   null;
end Simple_Pg_Test;
