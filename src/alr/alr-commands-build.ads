package Alr.Commands.Build is

   type Command is new Commands.Command with null record;

   overriding
   procedure Execute (Cmd : in out Command);

   function Execute return Boolean;
   --  Returns True if compilation succeeded

   overriding
   function Long_Description (Cmd : Command)
                              return Alire.Utils.String_Vector;

   overriding
   procedure Setup_Switches
     (Cmd    : in out Command;
      Config : in out GNAT.Command_Line.Command_Line_Configuration);

   overriding
   function Short_Description (Cmd : Command) return String
   is ("GPRbuild current working release");

   overriding
   function Usage_Custom_Parameters (Cmd : Command) return String
   is ("");

end Alr.Commands.Build;
