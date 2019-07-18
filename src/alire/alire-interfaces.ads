with Alire.TOML_Adapters;
with Alire.Utils;

with TOML;

package Alire.Interfaces with Preelaborate is

   -------------------
   -- Classificable --
   -------------------

   type Classificable is limited interface;
   --  Used to classify properties/dependencies when exporting to TOML

   function Key (This : Classificable) return String is abstract;

   ----------------
   -- Codifiable --
   ----------------

   type Codifiable is limited interface;

   function To_Code (This : Codifiable) return Utils.String_Vector is abstract;

   ----------------
   -- Imaginable --
   ----------------

   type Imaginable is limited interface;

   function Image (This : Imaginable) return String is abstract;

   ----------------
   -- Tomifiable --
   ----------------

   type Tomifiable is limited interface;
   --  Implemented by types that appear in the index
   --  This can be recursive (trees, arrays...)

   function To_TOML (This : Tomifiable) return TOML.TOML_Value is abstract;

   type Detomifiable_Object is limited interface;
   --  Implemented by types that can be loaded from a TOML crate file;
   --  in particular by complex objects stored as tables.

   function From_TOML (This : in out Detomifiable_Object;
                       From :        TOML_Adapters.Key_Queue)
                       return Outcome is abstract;
   --  To allow partial load this uses an in out object.
   --  Context is an arbitrary string used in error messages; refers to the
   --  calling scope.

   type Detomifiable_Value is limited interface;
   --  Implemented by objects that are obtained from a single TOML value.

   function From_TOML (This : in out Detomifiable_Value;
                       From :        TOML.TOML_Value)
                       return Outcome is abstract;

end Alire.Interfaces;
