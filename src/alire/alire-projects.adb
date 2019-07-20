with Alire.Properties.From_TOML;
with Alire.TOML_Load;

package body Alire.Projects is

   ---------------
   -- From_TOML --
   ---------------

   overriding
   function From_TOML (This : in out General;
                       From :        TOML_Adapters.Key_Queue)
                       return Outcome
   is
      Result : constant Outcome :=
                 TOML_Load.Load_Common
                   (From,
                    Properties.From_TOML.General_Loaders,
                    This.Properties,
                    This.Dependencies,
                    This.Available);
   begin
      if not Result.Success then
         return Result;
      end if;

      --  Check for remaining keys, which must be erroneous
      return From.Report_Extra_Keys;
   end From_TOML;

end Alire.Projects;
