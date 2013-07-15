--
-- Created by ada_generator.py on 2013-06-11 17:03:46.734385
-- 
with Ada.Containers.Vectors;
--
-- FIXME: may not be needed
--
with Ada.Calendar;

with Base_Types; use Base_Types;

with Ada.Strings.Unbounded;
with Test_Package;
with Test_Package;
with Test_Package_2;

-- === CUSTOM IMPORTS START ===
-- a                                                                                                            
-- b                                                                                                            
-- c                                                                                                            
-- === CUSTOM IMPORTS END ===

package Simple_Pg_Data is

   use Ada.Strings.Unbounded;
   
   use Test_Package;
   use Test_Package;
   use Test_Package_2;

   -- === CUSTOM TYPES START ===
   -- d                                                                                                            
   -- e                                                                                                            
   -- f                                                                                                            
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
         Type1 : An_Enum := An_Enum'First;
         Type2 : standard_user_type2_Enum := v1;
         Date_Created : Ada.Calendar.Time := FIRST_DATE;
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
         Type1 => An_Enum'First,
         Type2 => v1,
         Date_Created => FIRST_DATE
   );
   --
   -- simple print routine for standard_user : A user
   --
   function To_String( rec : Standard_User_Type ) return String;

        
   -- === CUSTOM PROCS START ===
   -- g                                                                                                            
   -- h                                                                                                         
   -- i                                                                                                         
   -- === CUSTOM PROCS END ===

end Simple_Pg_Data;
