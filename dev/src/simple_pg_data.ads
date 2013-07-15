--
-- Created by ada_generator.py on 2012-02-23 13:59:30.708893
-- 
with Ada.Containers.Vectors;
--
-- FIXME: may not be needed
--
with Ada.Calendar;

with Base_Types; use Base_Types;

with Ada.Strings.Unbounded;

package Simple_Pg_Data is

   use Ada.Strings.Unbounded;

      --
      -- record modelling group_members : Group a user belongs to
      --
      type Group_Members is record
         Group_Name : Unbounded_String := MISSING_W_KEY;
         User_Id : integer := MISSING_I_KEY;
      end record;
      --
      -- container for group_members : Group a user belongs to
      --
      package Group_Members_List is new Ada.Containers.Vectors
         (Element_Type => Group_Members,
         Index_Type => Positive );
      --
      -- default value for group_members : Group a user belongs to
      --
      Null_Group_Members : constant Group_Members := (
         Group_Name => MISSING_W_KEY,
         User_Id => MISSING_I_KEY
      );
      --
      -- simple print routine for group_members : Group a user belongs to
      --
      function To_String( rec : Group_Members ) return String;

      --
      -- record modelling standard_group : Group a user belongs to
      --
      type Standard_Group is record
         Name : Unbounded_String := MISSING_W_KEY;
         Description : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
         Group_Members : Group_Members_List.Vector;
      end record;
      --
      -- container for standard_group : Group a user belongs to
      --
      package Standard_Group_List is new Ada.Containers.Vectors
         (Element_Type => Standard_Group,
         Index_Type => Positive );
      --
      -- default value for standard_group : Group a user belongs to
      --
      Null_Standard_Group : constant Standard_Group := (
         Name => MISSING_W_KEY,
         Description => Ada.Strings.Unbounded.Null_Unbounded_String,
         Group_Members => Group_Members_List.Empty_Vector
      );
      --
      -- simple print routine for standard_group : Group a user belongs to
      --
      function To_String( rec : Standard_Group ) return String;

      --
      -- record modelling standard_user : A user
      --
      type Standard_User is record
         User_Id : integer := MISSING_I_KEY;
         Username : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
         Password : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
         Salary : Decimal_10_2 := 0.0;
         Rate : Real := 0.0;
         Date_Created : Ada.Calendar.Time := FIRST_DATE;
         Group_Members : Group_Members_List.Vector;
      end record;
      --
      -- container for standard_user : A user
      --
      package Standard_User_List is new Ada.Containers.Vectors
         (Element_Type => Standard_User,
         Index_Type => Positive );
      --
      -- default value for standard_user : A user
      --
      Null_Standard_User : constant Standard_User := (
         User_Id => MISSING_I_KEY,
         Username => Ada.Strings.Unbounded.Null_Unbounded_String,
         Password => Ada.Strings.Unbounded.Null_Unbounded_String,
         Salary => 0.0,
         Rate => 0.0,
         Date_Created => FIRST_DATE,
         Group_Members => Group_Members_List.Empty_Vector
      );
      --
      -- simple print routine for standard_user : A user
      --
      function To_String( rec : Standard_User ) return String;

        

end Simple_Pg_Data;
