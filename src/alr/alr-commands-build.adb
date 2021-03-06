with Alire.Actions;
with Alire.Paths;

with Alr.Actions;
with Alr.Root;
with Alr.Spawn;
with Alr.Platform;
with Alr.Build_Env;

with GNAT.OS_Lib;

package body Alr.Commands.Build is

   ----------------
   -- Do_Compile --
   ----------------

   function Do_Compile return Boolean is
   begin
      Requires_Full_Index;

      Requires_Valid_Session;

      Alr.Build_Env.Set (Alr.Root.Current);

      --  COMPILATION
      begin

         --  Build all the project files
         for Gpr_File of Root.Current.Release.Project_Files
           (Platform.Properties, With_Path => True)
         loop

            Spawn.Gprbuild (Gpr_File,
                            Extra_Args    => Scenario.As_Command_Line);
         end loop;

      exception
         when others =>
            return False;
      end;

      --  POST-COMPILE ACTIONS
      begin
         Actions.Execute_Actions
           (Root.Current.Release, Alire.Actions.Post_Compile);
      exception
         when others =>
            Trace.Warning ("A post-compile action failed, " &
                             "re-run with -vv -d for details");
            return False;
      end;

      Trace.Detail ("Compilation finished successfully");
      Trace.Detail ("Use alr run --list to check available executables");

      return True;
   end Do_Compile;

   -------------
   -- Execute --
   -------------

   overriding procedure Execute (Cmd : in out Command) is
      pragma Unreferenced (Cmd);
   begin
      if not Do_Compile then
         Reportaise_Command_Failed ("Compilation failed.");
      end if;
   end Execute;

   -------------
   -- Execute --
   -------------

   function Execute return Boolean is (Do_Compile);

   ----------------------
   -- Long_Description --
   ----------------------

   overriding
   function Long_Description (Cmd : Command)
                              return Alire.Utils.String_Vector is
     (Alire.Utils.Empty_Vector
      .Append ("Invokes gprbuild to compile all targets in the current"
               & " crate. The project file in use is located at <crate>"
               & GNAT.OS_Lib.Directory_Separator
               & Alire.Paths.Working_Folder_Inside_Root & "."
               & " The build is performed out-of-tree at <crate>"
               & GNAT.OS_Lib.Directory_Separator
               & Alire.Paths.Build_Folder));

   --------------------
   -- Setup_Switches --
   --------------------

   overriding procedure Setup_Switches
     (Cmd    : in out Command;
      Config : in out GNAT.Command_Line.Command_Line_Configuration)
   is
      pragma Unreferenced (Cmd);
      use GNAT.Command_Line;
   begin
      Define_Switch (Config,
                     "-X!",
                     Help => "Scenario variable for gprbuild",
                     Argument => "Var=Arg");
   end Setup_Switches;

end Alr.Commands.Build;
