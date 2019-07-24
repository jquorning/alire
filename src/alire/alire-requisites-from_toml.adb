with Alire.Requisites.Booleans;
with Alire.Requisites.Platform;
with Alire.TOML_Adapters;

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
   begin
      if From.Kind = TOML_Boolean then
         This := Requisites.Booleans.New_Requisite (From.As_Boolean);
      elsif From.Kind = TOML_Table then
         declare
            Cases  : TOML.TOML_Value;
            Key    : Requisites.Platform.Case_Loader_Keys;
            Loader : Interfaces.TOML_Loader;
            Result : constant Outcome :=
                       Platform.Get_Case (Parent   => From,
                                          Context  => Ctxt,
                                          Cases    => Cases,
                                          Variable => Key,
                                          Loader   => Loader);
         begin
            if not Result.Success then
               return Result;
            else
               declare
                  Queue  : constant TOML_Adapters.Key_Queue :=
                             TOML_Adapters.From
                               (Cases,
                                Ctxt & ": " & TOML_Adapters.Adafy (Key'Img));
                  Result : Outcome;
                  Enum   : constant Requisite'Class :=
                             Requisite'Class (Loader (Queue, Result));
               begin
                  if not Result.Success then
                     return Result;
                  end if;

                  This := Requisites.Trees.Leaf (Enum);
                  return Outcome_Success;
               end;
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
