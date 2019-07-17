with Ada.Containers.Indefinite_Ordered_Maps;

with Alire.Properties;
with Alire.Utils;
with Alire.Properties.Labeled;

package Alire.Projects.Collections with Preelaborate is

   package Crate_Maps is new Ada.Containers.Indefinite_Ordered_Maps
     (Alire.Project, Crate);

   type Crate_Map is new Crate_Maps.Map with null record;

   procedure Register (This : Crate);
   --  Store a loaded crate for future reference.

   --  Accessors to a collection of crates, that simplify querying inherited
   --  fields from parent crates. These assume crates that have been properly
   --  loaded, hence all required fields must exist at least in root crates.

   function Get_Multiple (Map  : Crate_Map;
                          Name : Alire.Project;
                          Key  : Properties.Labeled.Labels)
                          return Utils.String_Vector;

   function Get_Unique (Map  : Crate_Map;
                        Name : Alire.Project;
                        Key  : Properties.Labeled.Labels)
                        return String;

   Crates : aliased Crate_Map;
   --  Global store of loaded crates.
   --  TODO: Remove this global during Index, Projects globals refactoring

end Alire.Projects.Collections;
