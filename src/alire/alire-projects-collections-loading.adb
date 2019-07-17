package body Alire.Projects.Collections.Loading is

   ------------------
   -- Get_Multiple --
   ------------------

   function Get_Multiple (Name : Alire.Project;
                          Key  : Properties.Labeled.Labels;
                          Val  : in out Utils.UString_Vectors.Vector)
                          return Boolean
   is
   begin
      Trace.Always ("XXX " & (+Name) & Val.Length'Img);
      if not Val.Is_Empty then
         Trace.Always ("ZZZ");
         return True;
      end if;

      Val := Utils.To_UString_Vector
        (Crates.Get_Multiple (Name, Key));

      return True;
   exception
      when E : others =>
         Log_Exception (E);
         return False;
   end Get_Multiple;

   ----------------
   -- Get_Unique --
   ----------------

   function Get_Unique (Name : Alire.Project;
                        Key  : Properties.Labeled.Labels;
                        Val  : in out UString)
                        return Boolean is
   begin
      if UStrings.Length (Val) > 0 then
         return True;
      end if;

      Val := +Crates.Get_Unique (Name, Key);

      return True;
   exception
      when E : others =>
         Log_Exception (E);
         return False;
   end Get_Unique;

end Alire.Projects.Collections.Loading;
