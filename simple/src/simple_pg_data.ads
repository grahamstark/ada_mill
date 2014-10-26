--
-- Created by ada_generator.py on 2014-02-01 16:13:07.400622
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
   type Group_Members is record
         group_name : Unbounded_String := MISSING_W_KEY;
         user_id : Integer := MISSING_I_KEY;
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
         group_name => MISSING_W_KEY,
         user_id => MISSING_I_KEY
   );
   --
   -- simple print routine for group_members : Group a user belongs to
   --
   function To_String( rec : Group_Members ) return String;

   --
   -- record modelling standard_group : Group a user belongs to
   --
   type Standard_Group is record
         name : Unbounded_String := To_Unbounded_String( "SATTSIM" );
         description : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
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
         name => To_Unbounded_String( "SATTSIM" ),
         description => Ada.Strings.Unbounded.Null_Unbounded_String
   );
   --
   -- simple print routine for standard_group : Group a user belongs to
   --
   function To_String( rec : Standard_Group ) return String;

   --
   -- record modelling standard_user : A user
   --
   type Standard_User is record
         user_id : Integer := Integer'First;
         username : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
         password : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
         type1 : An_Enum := An_Enum'First;
         type2 : standard_user_type2_Enum := v1;
         date_created : Ada.Calendar.Time := FIRST_DATE;
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
         user_id => Integer'First,
         username => Ada.Strings.Unbounded.Null_Unbounded_String,
         password => Ada.Strings.Unbounded.Null_Unbounded_String,
         type1 => An_Enum'First,
         type2 => v1,
         date_created => FIRST_DATE
   );
   --
   -- simple print routine for standard_user : A user
   --
   function To_String( rec : Standard_User ) return String;

        
   -- === CUSTOM PROCS START ===
   -- g                                                                                                                
   -- h                                                                                                             
   -- i                                                                                                             
   -- === CUSTOM PROCS END ===

end Simple_Pg_Data;
