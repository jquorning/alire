with Alire.Requisites.Booleans;
with Alire.Requisites.Platform;
with Alire.TOML_Adapters;
with Alire.Utils;

package body Alire.Requisites.From_TOML is

   ---------------
   -- From_TOML --
   ---------------

   function From_TOML (This : out Tree;
                       From :        TOML.TOML_Value;
                       Ctxt :        String)
                       return Outcome
   is
      use TOML;

      ---------------
      -- From_Case --
      ---------------

      function From_Case (Case_Is, Case_Var : String) return Outcome is
         Cases  : constant TOML.TOML_Value := From.Get (From.Keys (1));
         Result : Outcome;
         Queue  : constant TOML_Adapters.Key_Queue :=
                    TOML_Adapters.From (Cases, Ctxt & ": " & Case_Is);
         Loader : Interfaces.TOML_Loader;
      begin
         begin
            Loader :=
              Platform.Loaders
                (Platform.Case_Loader_Keys'Value
                   (TOML_Adapters.Adafy (Case_Var)));
         exception
            when Constraint_Error =>
               return Outcome_Failure
                 (Ctxt & ": invalid case variable: " & Case_Var);
         end;

         declare
            Enum   : constant Requisite'Class :=
                       Requisite'Class (Loader (Queue, Result));
         begin
            if not Result.Success then
               return Result;
            end if;

            This := Requisites.Trees.Leaf (Enum);
            return Outcome_Success;
         end;
      end From_Case;

   begin
      if From.Kind = TOML_Boolean then
         This := Requisites.Booleans.New_Requisite (From.As_Boolean);
      elsif From.Kind = TOML_Table then
         declare
            use Utils;
            Case_Is  : constant String := +From.Keys (1);
            Case_Var : constant String := Tail (Head (Case_Is, ')'), '(');
         begin
            if Utils.Starts_With (Case_Is, "case(") then
               return From_Case (Case_Is, Case_Var);
            else
               return
                 Outcome_Failure (Ctxt & ": case expected; got: " & Case_Is);
            end if;
         end;
      else
         return
           Outcome_Failure (Ctxt & ": requisites must be boolean or case: "
                            & From.Kind'Img);
      end if;

      return Outcome_Success;
   end From_TOML;

end Alire.Requisites.From_TOML;
