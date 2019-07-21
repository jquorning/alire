with TOML;

package Alire.Requisites.From_TOML with Preelaborate is

   function From_TOML (This : out Tree;
                       From :     TOML.TOML_Value;
                       Ctxt :     String)
                       return Outcome;

end Alire.Requisites.From_TOML;
