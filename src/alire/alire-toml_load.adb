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
      pragma Unreferenced (Deps, Avail);

      Unused : TOML.TOML_Value;
      Ignore : Boolean;
   begin
      --  Process Dependencies
      --  TODO: we eat them for now
      Ignore := From.Pop ("depends-on", Unused);

      --  TODO: Process Forbidden

      --  Process Available
      --  TODO: we eat them for now
      Ignore := From.Pop ("available", Unused);

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
