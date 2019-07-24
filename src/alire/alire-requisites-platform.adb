with Alire.TOML_Adapters;
with Alire.Utils;

package body Alire.Requisites.Platform is

   --------------
   -- Get_Case --
   --------------

   function Get_Case (Parent   :     TOML.TOML_Value;
                      Context  :     String;
                      Cases    : out TOML.TOML_Value;
                      Variable : out Case_Loader_Keys;
                      Loader   : out Interfaces.TOML_Loader)
                      return Outcome
   is
      use Utils;
      Case_Is  : constant String := +Parent.Keys (1);
      Case_Var : constant String := Tail (Head (Case_Is, ')'), '(');
      Case_Key : Case_Loader_Keys renames Variable;
   begin
      if Utils.Starts_With (Case_Is, "case(") and then
         Case_Is (Case_Is'Last) = ')'
      then
         Case_Key := Case_Loader_Keys'Value (TOML_Adapters.Adafy (Case_Var));
         Cases    := Parent.Get (Case_Is);
         Loader   := Loaders (Case_Key);
         return Outcome_Success;
      else
         return
           Outcome_Failure (Context & ": case() expected; got: " & Case_Is);
      end if;
   exception
      when Constraint_Error =>
         return Outcome_Failure
           (Context & ": invalid case variable: " & Case_Var);
   end Get_Case;

end Alire.Requisites.Platform;
