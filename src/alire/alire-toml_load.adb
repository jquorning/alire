with Alire.Requisites.From_TOML;

with TOML;

package body Alire.TOML_Load is

   -----------------
   -- Load_Common --
   -----------------

   function Load_Common (From    : TOML_Adapters.Key_Queue;
                         Loaders : Properties.From_TOML.Loader_Array;
                         Props   : in out Conditional.Properties;
                         Deps    : in out Conditional.Dependencies;
                         Avail   : in out Requisites.Tree)
                         return Outcome is
      pragma Unreferenced (Deps);

      Unused : TOML.TOML_Value;
      Ignore : Boolean;

      TOML_Avail : TOML.TOML_Value;
   begin
      --  Process Dependencies
      --  TODO: we eat them for now
      Ignore := From.Pop ("depends-on", Unused);

      --  TODO: Process Forbidden

      --  Process Available
      if From.Pop ("available", TOML_Avail) then
         declare
            Result : constant Outcome :=
                       Alire.Requisites.From_TOML.From_TOML
                         (Avail,
                          From => TOML_Avail,
                          Ctxt => From.Descend ("available"));

         begin
            if not Result.Success then
               return Result;
            end if;
         end;
      end if;

      --  Process remaining keys, which must be fixed/conditional properties.
      declare
         Result : constant Outcome :=
                 Properties.From_TOML.Load
                   (Properties => Props,
                    Loaders    => Loaders,
                    From       => From);
      begin
         if not Result.Success then
            return Result;
         end if;
      end;

      return Outcome_Success;
   end Load_Common;

end Alire.TOML_Load;
