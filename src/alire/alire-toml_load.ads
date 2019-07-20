with Alire.Conditional;
with Alire.TOML_Adapters;
with Alire.Properties.From_TOML;
with Alire.Requisites;

package Alire.TOML_Load with Preelaborate is

   function Load_Common (From    : TOML_Adapters.Key_Queue;
                         Loaders : Properties.From_TOML.Loader_Array;
                         Props   : in out Conditional.Properties;
                         Deps    : in out Conditional.Dependencies;
                         Avail   : in out Requisites.Tree)
                         return Outcome;

end Alire.TOML_Load;
