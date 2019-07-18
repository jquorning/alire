with Alire.Properties.From_TOML;

package body Alire.Projects is

   ---------------
   -- From_TOML --
   ---------------

   overriding
   function From_TOML (This : in out General;
                       From :        TOML_Adapters.Key_Queue)
                       return Outcome is
   begin

      --  Process Dependencies

      --  TODO: Process Forbidden

      --  Process Available

      --  Process remaining keys, which must be fixed/conditional properties.
      declare
         Result : constant Outcome :=
                    Properties.From_TOML.Load
                      (Properties => This.Properties,
                       Loaders    => Properties.From_TOML.General_Loaders,
                       From       => From);
      begin
         if not Result.Success then
            return Result;
         end if;
      end;

      --  Check for remaining keys, which must be erroneous
      return From.Report_Extra_Keys;
   end From_TOML;

end Alire.Projects;
