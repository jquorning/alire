private with Alire.Utils;

with TOML; use all type TOML.Any_Value_Kind;

package Alire.TOML_Adapters with Preelaborate is

   type Key_Queue is new TOML.TOML_Value with private;
   --  Helper type that simplifies keeping track of processed keys during load.

   function From (Value : TOML.TOML_Value) return Key_Queue with
     Pre => TOML.Kind (Value) = TOML.TOML_Table;
   --  Create a new queue wrapping a deep copy of a TOML value.

   function Pop (Queue : Key_Queue;
                 Value : out TOML.TOML_Value) return String;
   --  Get a Key/Value pair. The returned string is the key. The pair is
   --  removed from the queue. An empty string is returned when no more pairs
   --  are left.

   function Pop (Queue : Key_Queue;
                 Key   : String;
                 Value : out TOML.TOML_Value) return Boolean;
   --  Remove Key from the given set of keys and set Value to the
   --  corresponding value in Queue. Return whether Key was present.

   function Report_Extra_Keys (Queue : Key_Queue) return Outcome;
   --  If Queue still contains pending keys, consider it's an error, return
   --  false and fill error with extra keys. Just return true otherwise.

   --  Helpers to create TOML values with ease

   function "+" (S : String) return TOML.TOML_Value is
      (TOML.Create_String (S));

   function To_Array (V : TOML.TOML_Value) return TOML.TOML_Value with
     Pre  => V.Kind in TOML.Atom_Value_Kind or V.Kind = TOML.TOML_Array,
     Post => To_Array'Result.Kind = TOML.TOML_Array;
   --  Take an atom value and return an array of a single element
   --  If already an array, do nothing

   function To_Table (Key : String;
                      Val : TOML.TOML_Value) return TOML.TOML_Value with
     Post => To_Table'Result.Kind = TOML.TOML_Table;
   --  Create a table with a single key=val entry

   function Adafy (Key : String) return String;
   --  Take a toml key and substitute every '-' with a '_';

   generic
      type Enum is (<>);
   function Tomify_As_String (E : Enum) return String;

   generic
      type Enum is (<>);
   function Tomify (E : Enum) return TOML.TOML_Value;
   --  Simple tomifier for when the image is enough
   --  The resulting string is lowercase and with - instead of _
   --  E.g: Post_Fetch becomes post-fetch

private

   type Key_Queue is new TOML.TOML_Value with null record;

   -----------
   -- Adafy --
   -----------

   function Adafy (Key : String) return String is
     (Utils.Replace
        (Key,
         Match => "-",
         Subst => "_"));

   ----------------------
   -- Tomify_As_String --
   ----------------------

   function Tomify_As_String (E : Enum) return String is
     (Utils.Replace
        (Utils.To_Lower_Case (E'Img),
         Match => "_",
         Subst => "-"));

   ------------
   -- Tomify --
   ------------

   function Tomify (E : Enum) return TOML.TOML_Value is
     (TOML.Create_String
        (Utils.Replace
             (Utils.To_Lower_Case (E'Img),
              Match => "_",
              Subst => "-")));

end Alire.TOML_Adapters;
