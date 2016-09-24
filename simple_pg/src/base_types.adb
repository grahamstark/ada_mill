--
-- Created by ada_generator.py on 2016-09-24 16:35:18.291388
--

with Ada.Strings.Fixed;
with Ada.Strings.Maps.Constants;
with Ada.Exceptions;

-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package body Base_Types is

   -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===

   function Boolean_Value( s : String ) return Boolean is
      use Ada.Strings.Fixed;
      US : constant String := 
      Trim( Translate( s, Ada.Strings.Maps.Constants.Upper_Case_Map ), Ada.Strings.Both );
   begin
      if US = "TRUE" or US = "T" or US = "YES" or US = "1" then
         return True;
      elsif US = "FALSE" or US = "F" or US = "NO" or US = "0" then
         return False;
      end if;
      Ada.Exceptions.Raise_Exception( Constraint_Error'Identity, "Could not translate |" & s & "| to Boolean" );
   end Boolean_Value;
     

   function Slice_To_Unbounded( s : String; start : Positive; stop : Natural ) return Unbounded_String is
   begin
      return To_Unbounded_String( Slice( To_Unbounded_String( s ), start, stop ) );
   end Slice_To_Unbounded;

   package body Float_Mapper is
      
     procedure SQL_Map_To_Array( s : String; a : out Array_Type ) is
        use Ada.Strings.Fixed;
        p1,p2 : Integer := Ada.Strings.Fixed.Index( s, "{", s'First )+1;
     begin
        for i in a'Range loop
           p2 := Ada.Strings.Fixed.Index( s, ",", p1 ); 
           if( p2 <= 0 )then
              p2 := Ada.Strings.Fixed.Index( s, "}", s'First );
           end if;
           a( i ) := Data_Type'Value( s( p1 .. p2-1 ));
           p1 := p2+1;
        end loop;
     end SQL_Map_To_Array;
     
     function Array_To_SQL_String( a : Array_Type ) return String is
        use Ada.Strings.Unbounded;
        s : Unbounded_String;
     begin
        for i in a'Range loop
           declare
              its : constant String := Data_Type'Image( a( i ));
           begin   
              s := s & its( its'First .. its'Last );
           end;
           if( i < a'Last )then
              s := s & ",";
           end if;
        end loop;
        return "{" & To_String( s ) & "}";
     end Array_To_SQL_String;
     
     function To_String( a : Array_Type ) return String is
        use Ada.Strings.Unbounded;
        s : Unbounded_String;
     begin
        for i in a'Range loop
           declare
              key : constant String := Index'Image( i );
              val : constant String := Data_Type'Image( a( i ));
           begin   
              s := s & key & "=>" & val;
           end;
           if( i < a'Last )then
              s := s & ",";
           end if;
        end loop;
        return "[" & To_String( s ) & "]";
     end To_String;
    end Float_Mapper;
   
   package body Discrete_Mapper is
   
     procedure SQL_Map_To_Array( s : String; a : out Array_Type ) is
        use Ada.Strings.Fixed;
        p1,p2 : Integer := Ada.Strings.Fixed.Index( s, "{", s'First )+1;
     begin
        for i in a'Range loop
           p2 := Ada.Strings.Fixed.Index( s, ",", p1 ); 
           if( p2 <= 0 )then
              p2 := Ada.Strings.Fixed.Index( s, "}", s'First );
           end if;
           a( i ) := Data_Type'Val( Integer'Value( s( p1 .. p2-1 )));
           p1 := p2+1;
        end loop;
     end SQL_Map_To_Array;
     
     function Array_To_SQL_String( a : Array_Type ) return String is
        use Ada.Strings.Unbounded;
        s : Unbounded_String;
     begin
        for i in a'Range loop
           declare
              its : constant String := Integer'Image( Data_Type'Pos( a( i )));
           begin   
              s := s & its; -- ( its'First+1 .. its'Last );
           end;
           if( i < a'Last )then
              s := s & ",";
           end if;
        end loop;
        return "{" & To_String( s ) & "}";
     end Array_To_SQL_String;
   
     function To_String( a : Array_Type ) return String is
        use Ada.Strings.Unbounded;
        s : Unbounded_String;
     begin
        for i in a'Range loop
           declare
              key : constant String := Index'Image( i );
              val : constant String := Data_Type'Image( a( i ));
           begin   
              s := s & key & "=>" & val;
           end;
           if( i < a'Last )then
              s := s & ",";
           end if;
        end loop;
        return "[" & To_String( s ) & "]";
     end To_String;
     
     
   end Discrete_Mapper;

   package body Boolean_Mapper is
   
      procedure SQL_Map_To_Array( s : String; a : out Array_Type ) is
         use Ada.Strings.Fixed;
         p1,p2 : Integer := Ada.Strings.Fixed.Index( s, "{", s'First )+1;
      begin
         for i in a'Range loop
            p2 := Ada.Strings.Fixed.Index( s, ",", p1 ); 
            if( p2 <= 0 )then
               p2 := Ada.Strings.Fixed.Index( s, "}", s'First );
            end if;
            a( i ) := Boolean_Value( s( p1 .. p2-1 ));
            p1 := p2+1;
         end loop;
      end SQL_Map_To_Array;
     
      function Array_To_SQL_String( a : Array_Type ) return String is
         use Ada.Strings.Unbounded;
         s : Unbounded_String;
      begin
         for i in a'Range loop
            declare
               its : constant String := ( if a( i ) then "t" else "f" );
            begin   
               s := s & its; 
            end;
            if( i < a'Last )then
               s := s & ",";
            end if;
         end loop;
         return "{" & To_String( s ) & "}";
      end Array_To_SQL_String;
   
      function To_String( a : Array_Type ) return String is
         use Ada.Strings.Unbounded;
         s : Unbounded_String;
      begin
         for i in a'Range loop
            declare
               key : constant String := Index'Image( i );
               val : constant String := Boolean'Image( a( i ));
            begin   
               s := s & key & "=>" & val;
            end;
            if( i < a'Last )then
               s := s & ",";
            end if;
         end loop;
         return "[" & To_String( s ) & "]";
      end To_String;
   end Boolean_Mapper;
   
   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===

end Base_Types;
