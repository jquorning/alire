with Alire.Actions;
with Alire.Conditional;
with Alire.Properties.Labeled;
with Alire.Properties.Licenses;
with Alire.Properties.Scenarios;
with Alire.TOML_Adapters;

package Alire.Properties.From_TOML with Preelaborate is

   type Property_Loader is access
     function (Key    : String;
               Value  : TOML.TOML_Value;
               Result : out Outcome)
               return Conditional.Properties;
   --  Function that must be provided by each concrete Property class.

   type Property_Keys is (Actions,
                          Authors,
                          Description,
                          Executables,
                          GPR_Externals,
                          GPR_Set_Externals,
                          Licenses,
                          Maintainers,
                          Notes,
                          Project_Files,
                          Website);
   --  These enum values must match the toml key they represent with '-' => '_'

   type Loader_Array is array (Property_Keys range <>) of Property_Loader;

   General_Loaders : constant Loader_Array (Property_Keys) :=
                       (Actions  => Alire.Actions.From_TOML'Access,
                        GPR_Externals ..
                        GPR_Set_Externals
                                 => Properties.Scenarios.From_TOML'Access,
                        Licenses => Properties.Licenses.From_TOML'Access,
                        others   => Labeled.From_TOML'Access);

   Release_Loaders : constant Loader_Array (Property_Keys) :=
                       (Actions       => Alire.Actions.From_TOML'Access,
                        Executables   => Labeled.From_TOML'Access,
                        GPR_Externals ..
                        GPR_Set_Externals
                                      => Properties.Scenarios.From_TOML'Access,
                        Notes         => Labeled.From_TOML'Access,
                        Project_Files => Labeled.From_TOML'Access,
                        others        => null);

   function Load (Properties : in out Conditional.Properties;
                  Loaders    :        Loader_Array;
                  From       :        TOML_Adapters.Key_Queue)
                  return Outcome;

end Alire.Properties.From_TOML;
