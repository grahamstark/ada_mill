--
-- Created by ada_generator.py on 2014-02-14 14:43:50.722188
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
         type1 : standard_user_type1_Enum := a3;
         type2 : standard_user_type2_Enum := v1;
         a_bigint : Big_Int := 0;
         a_real : Long_Float := 0.0;
         a_decimal : Decimal_12_2 := 0.0;
         a_double : Long_Float := 0.0;
         a_boolean : Boolean := false;
         a_varchar : Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;
         a_date : Ada.Calendar.Time := FIRST_DATE;
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
         type1 => a3,
         type2 => v1,
         a_bigint => 0,
         a_real => 0.0,
         a_decimal => 0.0,
         a_double => 0.0,
         a_boolean => false,
         a_varchar => Ada.Strings.Unbounded.Null_Unbounded_String,
         a_date => FIRST_DATE
   );
   --
   -- simple print routine for standard_user : A user
   --
   function To_String( rec : Standard_User ) return String;

        
   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===

end Simple_Pg_Data;
