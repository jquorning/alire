with Alr.Selftest;

with Alire.Requisites;
with Alire.Requisites.Booleans;

package body Alr.Commands.Dev is

   ------------
   -- Custom --
   ------------

   procedure Custom is
      use Alire.Requisites;
      use all type Tree;
      E  : Tree;
      ET : constant Tree := E and Booleans.Always_True;
      TE : constant Tree := Booleans.Always_True and E;
   begin
      ET.Print;
      TE.Print;
   end Custom;

   -------------
   -- Execute --
   -------------

   overriding procedure Execute (Cmd : in out Command) is
   begin
      if Cmd.Custom then
         Custom;
      end if;

      if Cmd.Raise_Except then
         raise Program_Error with "Raising forcibly";
      end if;

      if Cmd.Self_Test then
         Selftest.Run;
      end if;
   end Execute;

   --------------------
   -- Setup_Switches --
   --------------------

   overriding procedure Setup_Switches
     (Cmd    : in out Command;
      Config : in out GNAT.Command_Line.Command_Line_Configuration)
   is
      use GNAT.Command_Line;
   begin
      Define_Switch (Config,
                     Cmd.Custom'Access,
                     "", "--custom",
                     "Execute current custom code");

      Define_Switch (Config,
                     Cmd.Raise_Except'Access,
                     "", "--raise",
                     "Raise an exception");

      Define_Switch (Config,
                     Cmd.Self_Test'Access,
                     "", "--test",
                     "Run self-tests");
   end Setup_Switches;

end Alr.Commands.Dev;
