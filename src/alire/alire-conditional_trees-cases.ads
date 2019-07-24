with Alire.Requisites.Cases;
with Alire.TOML_Adapters;

generic
   pragma Warnings (Off);
   with package Requisite_Cases is new Requisites.Cases (<>);
package Alire.Conditional_Trees.Cases with Preelaborate is

   function From_TOML (From   : TOML_Adapters.Key_Queue;
                       Result : out Outcome)
                       return Tree;
   --  From points to the pairs, not to the parent 'case(xx)' table

end Alire.Conditional_Trees.Cases;
