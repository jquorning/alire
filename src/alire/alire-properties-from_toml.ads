with Alire.Conditional;
with Alire.Properties.Labeled;
with Alire.Properties.Licenses;
with Alire.TOML_Adapters;

package Alire.Properties.From_TOML with Preelaborate is

   type Property_Loader is access
     function (Key    : String;
               Value  : TOML.TOML_Value;
               Result : out Outcome)
               return Conditional.Properties;
   --  Function that must be provided by each concrete Property class.

   type Property_Keys is (Authors,
                          Description,
                          Licenses,
                          Maintainers);
   --  These enum values must match the toml key they represent with '-' => '_'

   type Loader_Array is array (Property_Keys range <>) of Property_Loader;

   General_Loaders : constant Loader_Array (Property_Keys) :=
                       (Licenses => Properties.Licenses.From_TOML'Access,
                        others   => Labeled.From_TOML'Access);

   function Load (Properties : in out Conditional.Properties;
                  Loaders    :        Loader_Array;
                  From       :        TOML_Adapters.Key_Queue)
                  return Outcome;

end Alire.Properties.From_TOML;
