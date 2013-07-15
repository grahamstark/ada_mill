--
-- Created by ada_generator.py on 2013-06-11 18:39:29.818166
-- 
with Ada.Calendar;
with Ada.Containers.Vectors;
with Ada.Exceptions;  
with Ada.Strings.Unbounded; 
with Ada.Text_IO.Editing;
with Text_IO;
with Base_Types; use Base_Types;
with GNATColl.Traces;

-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package body DB_Commons is

   use Ada.Exceptions;
   use Ada.Strings.Unbounded;

   -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===

   log_trace : GNATColl.Traces.Trace_Handle := GNATColl.Traces.Create( "DB_COMMONS" );
   
   procedure Log( s : String ) is
   begin
      GNATColl.Traces.Trace( log_trace, s );
   end Log;

   
   -- return a string like '2007-09-24 16:07:47'
   function to_string( t : Date_Time_Rec ) return String is      
      
      YEAR_PICTURE : constant Ada.Text_IO.Editing.Picture :=
         Ada.Text_IO.Editing.To_Picture ("9999");
      TWO_PICTURE : constant Ada.Text_IO.Editing.Picture :=
         Ada.Text_IO.Editing.To_Picture ("99");
      
      type some_decimal is delta 1.0 digits 4;
      
      package Decimal_Format is new Ada.Text_IO.Editing.Decimal_Output (
         Num => some_decimal,
         Default_Currency => "",
         Default_Fill => '0',
         Default_Separator => ',',
         Default_Radix_Mark => '.');
      
      use Ada.Calendar;
      
      s : Bounded_String := to_bounded_string( "" );
   begin
      s := s & decimal_format.image( some_decimal(t.year) ,YEAR_PICTURE ) & "-";
      s := s & decimal_format.image( some_decimal(t.month),TWO_PICTURE ) & "-";
      s := s & decimal_format.image( some_decimal(t.day),TWO_PICTURE ) & " ";
      s := s & decimal_format.image( some_decimal(t.hour),TWO_PICTURE ) & ":";
      s := s & decimal_format.image( some_decimal(t.minute),TWO_PICTURE ) & ":";
      s := s & decimal_format.image( some_decimal(t.second),TWO_PICTURE );
      return to_string( s );
   end to_string;
   
   

   function Date_Time_To_Ada_Time( dTime : Date_Time_Rec ) return Ada.Calendar.Time is
      use Ada.Calendar;
        secs : Day_Duration;
   begin
      secs := Day_Duration( 3600*dTime.hour + 60 * dTime.minute + dTime.second ) + Day_Duration( dTime.fraction );
      return Time_Of( 
               Year_Number(dTime.year),
               Month_Number( dTime.month ),
               Day_Number( dTime.day ),
               secs );
   end Date_Time_To_Ada_Time;
   
   function round_down( d : Ada.Calendar.Day_Duration ) return Integer is
   begin
      return Integer(Real'Floor(Real( d )));
   end round_down;

   function Ada_Time_To_Date_Time( adaTime : Ada.Calendar.Time ) return Date_Time_Rec is
   use Ada.Calendar;
      dTime : Date_Time_Rec;
      secs : Day_Duration :=  Seconds( adaTime );
      remaining : Day_Duration := secs; 
   begin
      dTime.year := INTEGER( Year(adaTime));
      dTime.month := INTEGER( Month( adaTime ));
      dTime.day := INTEGER( Day( adaTime ));
      dTime.hour := round_down( secs / 3600.0 );
      
      remaining :=  secs - Day_Duration(dTime.hour)*3600.0;
      dTime.minute := round_down(remaining / 60.0 );
      remaining := remaining - Day_Duration( dTime.minute )*60.0;
      dTime.second := round_down(remaining);
      
      remaining := remaining - Day_Duration( dTime.second );
      dTime.fraction := Real(remaining);
      return dTime;
   end Ada_Time_To_Date_Time;
   
   function to_string( t : Ada.Calendar.Time ) return String is 
   begin
      return to_string( Ada_Time_To_Date_Time( t ));
   end to_string;


   Quoting_Character : constant String := "'";
   
   function joinStr( join : join_type ) return String is
   begin
           case join is
                   when join_and => return "and";
                   when join_or => return "or";
           end case;
   end joinStr;
   
   function likeStr( op : operation_type ) return String is
   begin
           case op is
                   when like => return "like" ;
                   when gt => return  ">" ;
                   when ge => return ">=" ;
                   when lt => return "<" ;
                   when le => return "<=" ;
                   when ne => return "<>" ;
                   when eq => return "=" ;
           end case;
   end likeStr;
   
   function QuoteIdentifier ( ID : String ) return String is
   begin
           return Quoting_Character & ID & Quoting_Character;
   end QuoteIdentifier;
   
   pragma Inline( QuoteIdentifier );
   
   
   function Make_Criterion_Element( varname : String;
                                  op : operation_type;
                                  is_string : Boolean;
                                  join : join_type; 
                                  value : String  ) return Criterion is
   
   s : Unbounded_String := To_Unbounded_String( varname ) & " " & likeStr( op ) & " ";
   cr : Criterion;
   
   begin
      if( is_string ) then 
             s := s & QuoteIdentifier ( value );
             cr.value := To_Unbounded_String( QuoteIdentifier ( value ));
      else
             s := s & value;
             cr.value := To_Unbounded_String( value );
      end if;
      cr.s := s;
      cr.join := join;
       
      return cr;
   end Make_Criterion_Element;
   
   
   function Make_Criterion_Element( varname : String;
                                  op : operation_type;
                                  join : join_type; 
                                  t : Ada.Calendar.Time  ) return Criterion is
   values : String := to_string( t );
   begin
      return Make_Criterion_Element( varname, op, true, join, values );
   end Make_Criterion_Element;
                               

   
   function Make_Criterion_Element( varname : String;
                                  op : operation_type;
                                  join : join_type; 
                                  value : String;
                                  max_length : integer := -1 ) return Criterion is
   edited_string : Unbounded_String := To_Unbounded_String(value);                    
   --
   -- FIXME: got to be a better way of doing this!!!!s
   --
   begin
      if( max_length > 0 ) and ( Length(edited_string) > max_length ) then
         edited_string := 
            To_Unbounded_String( slice( edited_string, 1, max_length ));
      end if;
      return Make_Criterion_Element( varname, op, true, join, To_String(edited_string));
   end Make_Criterion_Element;
   
   function Make_Criterion_Element( varname : String;
                                  op : operation_type;
                                  join : join_type; 
                                  value : Integer
                                   ) return Criterion is
   begin
      return Make_Criterion_Element( varname, op, false, join, value'Img );
   end Make_Criterion_Element;
   
   function Make_Criterion_Element( 
      varname : String;
      op : operation_type;
      join : join_type; 
      value : Big_Integer  ) return Criterion is
   begin
      return Make_Criterion_Element( varname, op, false, join, value'Img );
   end Make_Criterion_Element;

   
   function Make_Criterion_Element( varname : String;
                                  op : operation_type;
                                  join : join_type; 
                                  value : Real  ) return Criterion is
   begin
      return Make_Criterion_Element( varname, op, false, join, value'Img );
   end Make_Criterion_Element;
   
   function Make_Order_By_Element( varname : String; direction : Asc_Or_Desc ) return Order_By_Element is
      s : Order_By_Element := To_Unbounded_String( " " ) & varname & " " & direction'Img;
   begin
      return s;      
   end Make_Order_By_Element;

   
   procedure Add_To_Criteria( cr : in out Criteria; elem : Criterion ) is
   begin
      Criteria_P.append( cr.elements, elem );
   end Add_To_Criteria;
  
   procedure Add_To_Criteria( cr : in out Criteria; ob : Order_By_Element ) is
   begin
      Order_By_P.append( cr.orderings, ob );
   end add_to_criteria;
   
   function To_Crude_Array_Of_Values( c : Criteria ) return String is
      s : Unbounded_String := To_Unbounded_String( "" );
      last_element : Criterion;
      
      procedure Add_Element_To_String( pos : Criteria_P.Cursor ) is
      use Criteria_P;
      crit : Criterion;
      begin
         crit := element( pos );
         s := s & crit.value; 
         if( crit /= last_element ) then
               s := s & ", ";
         end if;
             
      end Add_Element_To_String;
      
   begin
      if( not Criteria_P.is_empty( c.elements )) then
         last_element := Criteria_P.Last_Element( c.elements );
         Criteria_P.iterate( c.elements, add_element_to_string'Access );
      end if;
      return To_String( s );    
   end To_Crude_Array_Of_Values;
   
   
   function To_String( c : Criteria; join_str_override : String := "" ) return String is
   
      s : Unbounded_String := To_Unbounded_String( "" );
      first_element : Criterion;
      first_order_by : Order_By_Element;
      
      procedure add_element_to_string( pos : Criteria_P.Cursor ) is
      use Criteria_P;
      crit : Criterion;
      begin
             crit := element( pos );
             if( crit /= first_element ) then
                     s := s & " ";
                     if( join_str_override = "" )then
                        s := s & joinStr( crit.join );
                     else
                        s := s & join_str_override;
                     end if;
                     s := s & " ";
             end if;
             s := s & crit.s; 
      end add_element_to_string;
      
      procedure add_ordering_to_string( pos : Order_By_P.Cursor ) is
      order : Order_By_Element;
      use Order_By_P;
      
      begin
             order := element( pos );
             if( order /= first_order_by ) then
                     s := s & ", ";
             end if;
             s := s & Unbounded_String(order); 
      end add_ordering_to_string;

   begin
      if( not Criteria_P.is_empty( c.elements )) then
         if( join_str_override = "" )then -- standard case: prefix with 'where'
            s := s & " where ";
         end if;
         first_element :=  Criteria_P.First_Element( c.elements );
         Criteria_P.iterate( c.elements, add_element_to_string'Access );
      end if;
      if( not Order_By_P.is_empty( c.orderings )) then
         s := s & " order by ";
         first_order_by :=  Order_By_P.First_Element( c.orderings );
         Order_By_P.iterate( c.orderings, add_ordering_to_string'Access );
      end if;   
      s := s & " ";
      return To_String( s );    
   end To_String;
   
   function Make_Decimal_Criterion_Element( varname : String;
                               op : operation_type;
                               join : join_type; 
                               value : Dec  ) return Criterion is
   begin
      return Make_Criterion_Element( varname, op, false, join, value'Img );         
   end Make_Decimal_Criterion_Element;
   
   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===
   
      
end DB_Commons;
