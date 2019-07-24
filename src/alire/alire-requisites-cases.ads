with Alire.Interfaces;
with Alire.Properties;
with Alire.TOML_Adapters;

with TOML;

generic
   --  Encapsulated enumeration type
   type Enum is (<>);

   --  Encapsulating property that contains one of the enumerated values
   type Property is new Properties.Property with private;
   with function Element (P : Property) return Enum;

   Name      : String; -- String used for Image (seen by the user).
   TOML_Name : String; -- String used for case(toml-name) expressions in files.
package Alire.Requisites.Cases with Preelaborate is

   --  Specific requisites for use over enumerations

   function TOML_Key return String is (TOML_Name);
   --  Re-export this value due to visibility bug.

   package Enum_Requisites is new For_Property (Property);

   type Enumerable (<>) is
     new Enum_Requisites.Requisite
     and Interfaces.Tomifiable with private;

   type All_Cases_Array is array (Enum) of Tree;
   --  Every case points to a requisite tree, that at leaves will have
   --  a Requisites.Booleans.Requisite.

   function New_Case (Cases : All_Cases_Array) return Enumerable;
   --  The function that creates a tree node.

   type TOML_Array is array (Enum) of TOML.TOML_Value;
   --  Immediate TOML value for each case.

   function Load_Cases (From  : TOML_Adapters.Key_Queue;
                        Cases : out TOML_Array) return Outcome;
   --  Intermediate loader that does not resolve leaves. Used by
   --  Conditional_Trees, that need to get either the Values or
   --  further Requisites.

   overriding
   function From_TOML (This : in out Enumerable;
                       From : TOML_Adapters.Key_Queue)
                       return Outcome;
   --  From points to the pairs, not to the parent 'case(xx)' table

   function From_TOML (From   : TOML_Adapters.Key_Queue;
                       Result : out Outcome)
                       return Interfaces.Detomifiable'Class with
     Post => From_TOML'Result in Enumerable;

   overriding
   function To_TOML (This : Enumerable) return TOML.TOML_Value;
   --  Returns a table composed of another table with the values. E.g.:
   --  ['case(toml-name)']
   --    'enum1|enum3' = true
   --    'enum2|enum4' = false

private

   function Is_Boolean (This : Enumerable; I : Enum) return Boolean;

   function As_Boolean (This : Enumerable; I : Enum) return Boolean;

   type Enumerable is new Enum_Requisites.Requisite and Interfaces.Tomifiable
   with record
      Cases : All_Cases_Array;
   end record;

   function Image_Case (Cases : All_Cases_Array; I : Enum) return String is
     (I'Img & " => " & Cases (I).Image
      & (if I /= Cases'Last
         then ", " & Image_Case (Cases, Enum'Succ (I))
         else ""));

   overriding
   function Image (E : Enumerable) return String is
     ("(case " & Name & " is " & Image_Case (E.Cases, E.Cases'First) & ")");

   overriding
   function Is_Satisfied (E : Enumerable; P : Property) return Boolean is
     (E.Cases (Element (P)).Check (Properties.To_Vector (P)));

   overriding
   function Children_Are_Satisfied (E : Enumerable;
                                    P : Property;
                                    V : Properties.Vector)
                                    return Boolean is
     (E.Cases (Element (P)).Check (V));

   function New_Case (Cases : All_Cases_Array) return Enumerable is
     (Cases => Cases);

end Alire.Requisites.Cases;
