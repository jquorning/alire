with Alire.Conditional_Trees.Cases;
with Alire.Requisites.Platform;

generic
   with package Trees is new Conditional_Trees (<>);
package Alire.Properties.Platform.Cases with Preelaborate is

   --  Packages used in new index, purely case-based.

   package Compiler_Cases is new Trees.Cases
     (Requisites.Platform.Compiler_TOML_Cases);

   --  Make loaders available

   type Case_Loader_Keys is (Compiler,
                             Distribution,
                             OS,
                             Word_Size);
   --  Must match the toml text

   type Conditional_Case_Loader is access
     function (From   : TOML_Adapters.Key_Queue;
               Result : out Outcome)
               return Trees.Tree;

   Loaders : constant array
     (Case_Loader_Keys) of Conditional_Case_Loader :=
        (Compiler     => Compiler_Cases.From_TOML'Access,
         Distribution => Compiler_Cases.From_TOML'Access,
         OS           => Compiler_Cases.From_TOML'Access,
         Word_Size    => Compiler_Cases.From_TOML'Access);

end Alire.Properties.Platform.Cases;
