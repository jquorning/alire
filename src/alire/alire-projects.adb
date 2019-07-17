package body Alire.Projects is

   ---------------
   -- New_Crate --
   ---------------

   function New_Crate (Name : Alire.Project) return Crate is
     (Crate'(Name     => +String (Name),
             Unique   => <>,
             Multiple => <>));

   ------------
   -- Parent --
   ------------

   function Parent (Name : Alire.Project) return Alire.Project is
   begin
      for I in reverse Name'Range loop
         if Name (I) = Child_Separator then
            return Name (Name'First .. I - 1);
         end if;
      end loop;

      raise Internal_Error with "Unreachable due to precondition";
   end Parent;

   --------------------------
   -- With_Unique_Property --
   --------------------------

   function With_Unique_Property (This : Crate;
                                  Key  : Properties.Labeled.Labels;
                                  Val  : String)
                                  return Crate is
   begin
      return This : Crate := With_Unique_Property.This do
         This.Unique.Insert (Key, Val);
      end return;
   end With_Unique_Property;

   ----------------------------
   -- With_Multiple_Property --
   ----------------------------

   function With_Multiple_Property (This : Crate;
                                    Key  : Properties.Labeled.Labels;
                                    Val  : Utils.String_Vector)
                                    return Crate is
   begin
      return This : Crate := With_Multiple_Property.This do
         This.Multiple.Insert (Key, Val);
      end return;
   end With_Multiple_Property;

end Alire.Projects;
