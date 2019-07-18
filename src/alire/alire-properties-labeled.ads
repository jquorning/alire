with Alire.Conditional;
private with Alire.TOML_Keys;
private with Alire.Utils;

package Alire.Properties.Labeled with Preelaborate is

   --  Properties that have a string atomic/array value and a name.
   --  Note that string arrays are internally stored as several individual
   --  properties with the same label at present.

   type Labels is
     (Author,
      --  VIP

      Comment,
      --  Extra text

      Description,
      --  Free-form but short description

      Executable,
      --  A resulting executable built by the project

      Maintainer,
      --  Info about the maintainer of the alr-packaged project

      Path,
      --  Extra path for PATH to add to build (prepended)

      Project_File,
      --  Buildable project files in the release, with full relative path

      Website
      --  A website other than the repository
     );

   type Cardinalities is (Unique, Multiple); -- Are they atoms or arrays?

   Cardinality : array (Labels) of Cardinalities :=
                   (Author       => Multiple,
                    Comment      => Unique,
                    Description  => Unique,
                    Executable   => Unique,
                    Maintainer   => Multiple,
                    Path         => Multiple,
                    Project_File => Multiple,
                    Website      => Unique);

   Mandatory : array (Labels) of Boolean :=
                 (Author       => False,
                  Comment      => False,
                  Description  => True,
                  Executable   => False,
                  Maintainer   => True,
                  Path         => False,
                  Project_File => False,
                  Website      => False);

   type Label (<>) is new
     Properties.Property and
     Interfaces.Tomifiable
   with private;

   function New_Label (Name  : Labels;
                       Value : String) return Label;

   function Name (L : Label) return Labels;

   function Value (L : Label) return String;

   --  TODO: use this one in Releases instead of the non-reusables Values
   function Filter (LV : Vector; Name : Labels) return Vector;
   --  Return only Label'Class with matching name

   overriding function Image (L : Label) return String;

   function Key (L : Labels) return String;

   overriding function Key (L : Label) return String;

   overriding function To_TOML (L : Label) return TOML.TOML_Value with
     Post => To_TOML'Result.Kind = TOML.TOML_String;
   --  Returns only the value, not the name (TOML key)

   function To_TOML_Array (LV   : Vector;
                           Name : Labels)
                           return TOML.TOML_Value
     with
       Post => To_TOML_Array'Result.Kind = TOML.TOML_Array;
   --  Filter LV and generate a key = [values ...] table.

   function From_TOML (Key    : String;
                       Value  : TOML.TOML_Value;
                       Result : out Outcome)
                       return Conditional.Properties;

   generic
      Name : Labels;
   function Cond_New_Label (Value : String) return Conditional.Properties;

   generic
      Name : Labels;
   function Cond_New_Path_Label (Value : Platform_Independent_Path)
                                 return Conditional.Properties;

private

   type Label (Length : Natural) is new
     Properties.Property and
     Interfaces.Tomifiable with
   record
      Name  : Labels;
      Value : String (1 .. Length);
   end record;

   function New_Label (Name : Labels; Value : String) return Label is
     (Properties.Property with Value'Length, Name, Value);

   function Name (L : Label) return Labels is (L.Name);

   function Value (L : Label) return String is (L.Value);

--     function Vec_New_Label (Value : String) return Properties.Vector is
--       (To_Vector (New_Label (Name, Value), 1));

   function Cond_New_Label (Value : String) return Conditional.Properties is
     (Conditional.For_Properties.New_Value (New_Label (Name, Value)));

   function Cond_New_Path_Label (Value : Platform_Independent_Path)
                                 return Conditional.Properties
   is (Conditional.For_Properties.New_Value
       (New_Label (Name, Utils.To_Native (Value))));

   overriding
   function Image (L : Label) return String
   is (Utils.To_Mixed_Case (L.Name'Img) & ": " & L.Value);

   function Key (L : Labels) return String
   is (case L is
          when Author       => TOML_Keys.Author,
          when Comment      => TOML_Keys.Comment,
          when Description  => TOML_Keys.Description,
          when Executable   => TOML_Keys.Executable,
          when Maintainer   => TOML_Keys.Maintainer,
          when Path         => TOML_Keys.Path,
          when Project_File => TOML_Keys.Project_File,
          when Website      => TOML_Keys.Website);

   overriding
   function Key (L : Label) return String is (Key (L.Name));

   overriding
   function To_TOML (L : Label) return TOML.TOML_Value
   is (TOML.Create_String (L.Value));

end Alire.Properties.Labeled;
