with Alire.Conditional;
with Alire.Licensing;
with Alire.TOML_Keys;

with TOML;

package Alire.Properties.Licenses with Preelaborate is

   type License (Custom : Boolean) is new Property with record
      case Custom is
         when False =>
            Known : Licensing.Licenses;
         when True =>
            Text  : UString;
      end case;
   end record;

   function New_License (Known : Licensing.Licenses) return License;

   function New_License (From  : String) return License;

   overriding
   function Key (Dummy_L : License) return String
   is (TOML_Keys.License);

   overriding
   function Image (L : License) return String;

   overriding
   function To_TOML (L : License) return TOML.TOML_Value;

   function From_TOML (Key    : String;
                       Value  : TOML.TOML_Value;
                       Result : out Outcome)
                       return Conditional.Properties;

private

   use all type Licensing.Licenses;

   function New_License (From  : String) return License is
     (if Licensing.From_String (From) = Licensing.Unknown
      then License'(Custom => True, Text => +From)
      else New_License (Licensing.From_String (From)));

   function New_License (Known : Licensing.Licenses) return License is
     (License'(Custom => False,
               Known  => Known));

   overriding
   function Image (L : License) return String is
     ("License: " &
      (if L.Custom
       then +L.Text
       else L.Known'Img));

   overriding
   function To_TOML (L : License) return TOML.TOML_Value is
     (TOML.Create_String
        (if L.Custom
         then +L.Text
         else +Licensing.License_Labels (L.Known)));

end Alire.Properties.Licenses;
