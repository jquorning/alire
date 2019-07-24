with Alire.Conditional_Trees.Cases;
with Alire.Requisites.Platform;

package Alire.Conditional.Cases is

   package For_Dependencies is
     new Conditional.For_Dependencies.Cases
       (Requisites.Platform.Compiler_TOML_Cases);

end Alire.Conditional.Cases;
