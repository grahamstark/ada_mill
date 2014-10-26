--
-- Created by ada_generator.py on 2014-02-01 15:59:58.826804
-- 
with GNU.DB.SQLCLI; use GNU.DB.SQLCLI;
with Base_Types; use Base_Types;
with Ada.Strings.Unbounded;
-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package DB_Commons.ODBC is
   
   use Ada.Strings.Unbounded;

   -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===
   
   type Database_Connection is record
      Environment : SQLHENV;
      connection  : SQLHDBC;
   end record;
   
   package L_Out_Binding is new GNU.DB.SQLCLI.IntegerBinding( Big_Int );
   package I_Out_Binding is new GNU.DB.SQLCLI.IntegerBinding( Integer );
   package R_Out_Binding is new GNU.DB.SQLCLI.FloatBinding( Real );
   
   Null_Database_Connection : constant Database_Connection := 
      ( Environment => SQL_NULL_HANDLE, connection => SQL_NULL_HANDLE );

   function Connect( Server_Name : String; User_Name : String; password : String ) return Database_Connection;
   
   procedure Disconnect( con : in out Database_Connection );
   
   function Initialise_Prepared_Statement( con : SQLHDBC; query : String ) return SQLHDBC;
   function Initialise_Prepared_Statement( con : SQLHDBC; query : Unbounded_String ) return SQLHDBC;

      
   procedure Close_Prepared_Statement( statement : in out GNU.DB.SQLCLI.SQLHDBC );
   
   procedure Commit( con : in out SQLHDBC );
   
   procedure Execute( ps : in out SQLHDBC );
   
   procedure Next_Row( ps : in out SQLHDBC; has_data : in out boolean );
   
   --
   -- odbc time handling
   --
   function To_String( t : SQL_TIMESTAMP_STRUCT ) return String;
   function Ada_Time_To_Timestamp( adaTime : Ada.Calendar.Time ) return SQL_TIMESTAMP_STRUCT;
   function Timestamp_To_Date_Time( sqlTime : SQL_TIMESTAMP_STRUCT ) return Date_Time_Rec;
   function timestamp_To_Ada_Time( sqlTime : SQL_TIMESTAMP_STRUCT ) return Ada.Calendar.Time;

   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===
   
end DB_Commons.ODBC;
