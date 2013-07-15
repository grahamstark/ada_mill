--
-- Created by ada_generator.py on 2012-02-23 13:59:30.911122
-- 
with Ada.Calendar;
with Ada.Containers.Vectors;
with Ada.Strings.Bounded;
with Ada.Strings.Wide_Fixed;
with ada.strings.Unbounded; 
with Base_Types; use Base_Types;
 
package DB_Commons is

   subtype Real is Base_Types.Real;
   subtype Decimal is Base_Types.Decimal;
   --
   --  Simple date time record to serve as an intermediate type
   --  between ADA time records and (say) ODBC date/time types
   --
   type Date_Time_Rec is record
      year,
      month,
      day,
      hour,
      minute,
      second : integer;
      fraction : Real;
   end record;
   
   function Date_Time_To_Ada_Time( dTime : Date_Time_Rec ) return Ada.Calendar.Time; 
   function Ada_Time_To_Date_Time( adaTime : Ada.Calendar.Time ) return Date_Time_Rec;
   function to_string( t : Date_Time_Rec ) return String;
   function to_string( t : Ada.Calendar.Time ) return String;
   --
   -- Criteria: simple (??) way to construct queries
   --
   type Asc_Or_Desc is ( asc, desc );
    
   type operation_type is ( like, gt, ge, lt, le, ne, eq );
   
   type field_type is ( string_type, decimal_type, real_type, integer_type, varchar_type, blob_type, clob_type );
   
   type join_type is ( join_and, join_or );
   
   type Criterion is private;
   type Criteria is private;
   type Order_By_Element is private;
   
   function Make_Order_By_Element( varname : String; direction : Asc_Or_Desc ) return Order_By_Element;

   function Make_Criterion_Element( varname : String;
                                  op : operation_type;
                                  join : join_type; 
                                  value : String;
                                  max_length : integer := -1  ) return Criterion;
                                  
   function Make_Criterion_Element( 
      varname : String;
      op : operation_type;
      join : join_type; 
      value : Integer  ) return Criterion;

   function Make_Criterion_Element( 
      varname : String;
      op : operation_type;
      join : join_type; 
      value : Big_Integer  ) return Criterion;
                                  
   function Make_Criterion_Element( 
      varname : String;
      op : operation_type;
      join : join_type; 
      value : Real  ) return Criterion;
                                  
   function Make_Criterion_Element( 
      varname : String;
      op : operation_type;
      join : join_type; 
      t : Ada.Calendar.Time  ) return Criterion;
                                  
                                  
   generic
      type Dec is delta<> digits<>;
      function Make_Decimal_Criterion_Element( 
         varname : String;
         op : operation_type;
         join : join_type; 
         value : Dec  ) return Criterion;
                                  
   --
   -- return a string like 'where xx='1' and yy=22 order by smith
   --
   function To_String( c : Criteria; join_str_override : String := "" ) return String;
   
   --
   -- return a string like '22', 23, 11 
   --
   function To_Crude_Array_Of_Values( c : Criteria ) return String;
   
   procedure add_to_criteria( cr : in out Criteria; elem : Criterion );
   procedure add_to_criteria( cr : in out Criteria; ob : Order_By_Element );
   
   DB_Exception : exception;
   
   private 
 
   use ada.strings.Unbounded;
   
   package String80 is new Ada.Strings.Bounded.Generic_Bounded_Length (80);
   
   use String80;
   
   type Criterion is record
      s : Unbounded_String;
      value : Unbounded_String;
      join : Join_Type;
   end record;
   
   type Order_By_Element is new Ada.Strings.Unbounded.Unbounded_String;
           
   package Criteria_P is new Ada.Containers.Vectors( 
      Element_Type => Criterion, 
      Index_Type => Positive );
           
   package Order_By_P is new Ada.Containers.Vectors( 
      Element_Type => Order_By_Element, 
      Index_Type => Positive );
   
   type Criteria is record
      elements : Criteria_P.Vector;
      orderings : Order_By_P.Vector;
   end record;
   
end DB_Commons;
