with Alire.Conditional;
with Alire.Platforms;
with Alire.Properties.Platform;

with Alire.Requisites.Cases;
with Alire.Requisites.Comparables;

with TOML;

package Alire.Requisites.Platform with Preelaborate is

   package Ps   renames Platforms;
   package PrPl renames Properties.Platform;

   use all type Ps.Compilers;
   use all type Tree;

   --  Packages used in new index, purely case-based.

   package Compiler_TOML_Cases is new Cases
     (Enum      => Ps.Compilers,
      Property  => PrPl.Compilers.Property,
      Element   => PrPl.Compilers.Element,
      Name      => "Compiler",
      TOML_Name => "compiler");

   package Distro_Cases is new Cases
     (Enum      => Ps.Distributions,
      Property  => PrPl.Distributions.Property,
      Element   => PrPl.Distributions.Element,
      Name      => "Distribution",
      TOML_Name => "distribution");

   package OS_Cases is new Cases
     (Enum      => Ps.Operating_Systems,
      Property  => PrPl.Operating_Systems.Property,
      Element   => PrPl.Operating_Systems.Element,
      Name      => "OS",
      TOML_Name => "os");

   package Word_Size_Cases is new Cases
     (Enum      => Ps.Word_Sizes,
      Property  => PrPl.Word_Sizes.Property,
      Element   => PrPl.Word_Sizes.Element,
      Name      => "Word Size",
      TOML_Name => "word-size");
   --  TODO: add word size to index documentation

   --  Make loaders available

   type Case_Loader_Keys is (Compiler,
                             Distribution,
                             OS,
                             Word_Size);
   --  The variables that can be used in index cases. Must match the toml text.

   function Get_Case (Parent   :     TOML.TOML_Value;
                      Context  :     String;
                      Cases    : out TOML.TOML_Value;
                      Variable : out Case_Loader_Keys;
                      Loader   : out Interfaces.TOML_Loader)
                      return Outcome;
   --  Checks if Parent is table with a single 'case(xx)' child, that in turn
   --  will contain the case keys. If so, Cases is set to the table containing
   --  the case keys, Variable contains the enum value for 'xx', and Loader is
   --  a function that knows how to load the specific enumeration.

   Loaders : constant array (Case_Loader_Keys) of Interfaces.TOML_Loader :=
               (Compiler     => Compiler_TOML_Cases.From_TOML'Access,
                Distribution => Distro_Cases       .From_TOML'Access,
                OS           => OS_Cases           .From_TOML'Access,
                Word_Size    => Word_Size_Cases    .From_TOML'Access);

   --  Packages used in Alire.Index, e.g., old more general expressions.
   --  TODO: remove during the old index Alire.Index dead code removal

   package Op_Systems is new Comparables
     (Ps.Operating_Systems, Ps."<", Ps.Operating_Systems'Image,
      PrPl.Operating_Systems.Property,
      PrPl.Operating_Systems.Element,
      "OS");

   package Op_System_Cases is new Conditional.For_Properties.Case_Statements
     (Ps.Operating_Systems, Op_Systems.Is_Equal_To);

   package Compilers is new Comparables
     (Ps.Compilers, Ps."<", Ps.Compilers'Image,
      PrPl.Compilers.Property,
      PrPl.Compilers.Element,
      "Compiler");

   use all type Compilers.Comparable;
   function Compiler is new Compilers.Factory;

   function Compiler_Is_Native return Tree is
     (Compiler >= GNAT_FSF_Old and Compiler < GNAT_GPL_Old);

   package Compiler_Cases is new Conditional.For_Properties.Case_Statements
     (Ps.Compilers, Compilers.Is_Equal_To);

   package Distributions is new Comparables
     (Ps.Distributions, Ps."<", Ps.Distributions'Image,
      PrPl.Distributions.Property,
      PrPl.Distributions.Element,
      "Distribution");

   package Distribution_Cases_Deps
   is new Conditional.For_Dependencies.Case_Statements
     (Ps.Distributions, Distributions.Is_Equal_To);

   package Distribution_Cases_Props
   is new Conditional.For_Properties.Case_Statements
     (Ps.Distributions, Distributions.Is_Equal_To);

   package Targets is new Comparables
     (Ps.Targets, Ps."<", Ps.Targets'Image,
      PrPl.Targets.Property,
      PrPl.Targets.Element,
      "Target");

   package Word_Sizes is new Comparables
     (Ps.Word_Sizes, Ps."<", Ps.Word_Sizes'Image,
      PrPl.Word_Sizes.Property,
      PrPl.Word_Sizes.Element,
      "Word_Size");

end Alire.Requisites.Platform;
