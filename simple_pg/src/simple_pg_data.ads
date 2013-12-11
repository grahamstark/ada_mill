--
-- Created by ada_generator.py on 2013-06-11 18:39:29.617053
-- 
with Ada.Containers.Vectors;
--
-- FIXME: may not be needed
--
with Ada.Calendar;

with Base_Types; use Base_Types;

with Ada.Strings.Unbounded;

-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package Simple_Pg_Data is

   use Ada.Strings.Unbounded;
   

   -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===


   --
   -- record modelling group_members : Group a user belongs to
   --
   type Group_Members_Type is record
         Group_Name : Unbounded_String := MISSING_W_KEY;
         User_Id : Integer := MISSING_I_KEY;
   end record;
   --
   -- container for group_members : Group a user belongs to
   --
   package Group_Members_Type_List is new Ada.Containers.Vectors
      (Element_Type => Group_Members_Type,
      Index_Type => Positive );
   --
   -- default value for group_members : Group a user belongs to
   --
   Null_Group_Members_Type : constant Group_Members_Type := (
         Group_Name => MISSING_W_KEY,
         User_Id => MISSING_I_KEY
   );
   --
   -- simple print routine for group_members : Group a user belongs to
   --
   function To_String( rec : Group_Members_Type ) return String;

   --
   -- record modelling standard_group : Group a user belongs to
   --
   type Standard_Group_Type is record
         Name : Unbounded_String := MISSING_W_KEY;
         Description : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
   end record;
   --
   -- container for standard_group : Group a user belongs to
   --
   package Standard_Group_Type_List is new Ada.Containers.Vectors
      (Element_Type => Standard_Group_Type,
      Index_Type => Positive );
   --
   -- default value for standard_group : Group a user belongs to
   --
   Null_Standard_Group_Type : constant Standard_Group_Type := (
         Name => MISSING_W_KEY,
         Description => Ada.Strings.Unbounded.Null_Unbounded_String
   );
   --
   -- simple print routine for standard_group : Group a user belongs to
   --
   function To_String( rec : Standard_Group_Type ) return String;

   --
   -- record modelling standard_user : A user
   --
   type Standard_User_Type is record
         User_Id : Integer := MISSING_I_KEY;
         Username : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
         Password : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
         Type1 : standard_user_type1_Enum := a3;
         Type2 : standard_user_type2_Enum := v1;
         A_Bigint : Big_Integer := 0;
         A_Real : Real := 0.0;
         A_Decimal : Decimal_12_2 := 0.0;
         A_Double : Real := 0.0;
         A_Boolean : Boolean := false;
         A_Varchar : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
         A_Date : Ada.Calendar.Time := FIRST_DATE;
   end record;
   --
   -- container for standard_user : A user
   --
   package Standard_User_Type_List is new Ada.Containers.Vectors
      (Element_Type => Standard_User_Type,
      Index_Type => Positive );
   --
   -- default value for standard_user : A user
   --
   Null_Standard_User_Type : constant Standard_User_Type := (
         User_Id => MISSING_I_KEY,
         Username => Ada.Strings.Unbounded.Null_Unbounded_String,
         Password => Ada.Strings.Unbounded.Null_Unbounded_String,
         Type1 => a3,
         Type2 => v1,
         A_Bigint => 0,
         A_Real => 0.0,
         A_Decimal => 0.0,
         A_Double => 0.0,
         A_Boolean => false,
         A_Varchar => Ada.Strings.Unbounded.Null_Unbounded_String,
         A_Date => FIRST_DATE
   );
   --
   -- simple print routine for standard_user : A user
   --
   function To_String( rec : Standard_User_Type ) return String;

        
   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===

end Simple_Pg_Data;