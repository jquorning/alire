with Ada.Containers.Indefinite_Ordered_Maps;

with Alire.Properties.Labeled;
private with Alire.Requisites;
with Alire.Utils;

package Alire.Projects with Preelaborate is

   --  TODO: rename this to crates.

   --  Utilities on crate names:

   function Is_Child (Name : Project) return Boolean;
   --  A Project is a Child if it contains dots.

   function Parent (Name : Project) return Project
     with Pre => Is_Child (Name);
   --  Removes last portion after a dot.

   --  Old description storage, to be refactored out in the future.

   package Project_Description_Maps
   is new Ada.Containers.Indefinite_Ordered_Maps
     (Alire.Project, Description_String);

   --  TODO: combine Index, Descriptions in a single data structure
   Descriptions : Project_Description_Maps.Map;
   --  Master list of known projects & descriptions

   type Named is limited interface;

   function Project (N : Named) return Alire.Project is abstract;

   -------------
   --  Crate  --
   -------------
   --  A crate contains some mandatory and optional info that can be overriden
   --  by releases in the crate, or by child crates.

   type Crate is tagged private;

   --  Chainable crate building:

   function New_Crate (Name : Alire.Project) return Crate;
   --  Returns Crate with no further information.

   --  The following With_ functions return the same Crate with the extra
   --  property, unless the given values are empty, in which case they're not
   --  added.

   function With_Unique_Property (This : Crate;
                                  Key  : Properties.Labeled.Labels;
                                  Val  : String)
                                  return Crate;

   function With_Multiple_Property (This : Crate;
                                    Key  : Properties.Labeled.Labels;
                                    Val  : Utils.String_Vector)
                                    return Crate;

   --  Other crate functions:

   function Is_Child (This : Crate) return Boolean;
   --  Child crates may miss mandatory fields, which default to parent's ones.

   function Name (This : Crate) return Alire.Project;

   function "<" (L, R : Crate) return Boolean;
   --  Ordered by name

private

   use all type Properties.Labeled.Labels;

   package Property_Unique_Maps is new Ada.Containers.Indefinite_Ordered_Maps
     (Properties.Labeled.Labels, String);

   use all type Utils.String_Vector;

   package Property_Multiple_Maps is new Ada.Containers.Indefinite_Ordered_Maps
     (Properties.Labeled.Labels, Utils.String_Vector);

   type Crate is tagged record
      Name     : UString;

      Unique   : Property_Unique_Maps.Map;
      Multiple : Property_Multiple_Maps.Map;
   end record;

   function "<" (L, R : Crate) return Boolean is (+L.Name < +R.Name);

   function Is_Child (Name : Alire.Project) return Boolean is
     (for some C of Name => C = Child_Separator);

   function Is_Child (This : Crate) return Boolean is
     (Is_Child (+(+This.Name)));

   function Name (This : Crate) return Alire.Project is (+(+This.Name));

end Alire.Projects;
