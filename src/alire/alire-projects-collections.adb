package body Alire.Projects.Collections is

   ------------------
   -- Get_Multiple --
   ------------------

   function Get_Multiple (Map  : Crate_Map;
                          Name : Alire.Project;
                          Key  : Properties.Labeled.Labels)
                          return Utils.String_Vector
   is
   begin
      return Map (Name).Multiple (Key);
   exception
      when others =>
         if Is_Child (Name) then
            return Map.Get_Multiple (Parent (Name), Key);
         else
            raise;
            --  Should not happen during normal operation; during loading this
            --  is managed in Collections.Loading.
         end if;
   end Get_Multiple;

   ----------------
   -- Get_Unique --
   ----------------

   function Get_Unique (Map  : Crate_Map;
                        Name : Alire.Project;
                        Key  : Properties.Labeled.Labels)
                        return String is
   begin
      return Map (Name).Unique (Key);
   exception
      when others =>
         if Is_Child (Name) then
            return Map.Get_Unique (Parent (Name), Key);
         else
            raise;
            --  Should not happen during normal operation; during loading this
            --  is managed in Collections.Loading.
         end if;
   end Get_Unique;

   --------------
   -- Register --
   --------------

   procedure Register (This : Crate) is
   begin
      Crates.Include (Name (This), This);
   end Register;

end Alire.Projects.Collections;
