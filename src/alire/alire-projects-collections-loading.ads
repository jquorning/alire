package Alire.Projects.Collections.Loading is

   --  Helpers for use during TOML loading, that return a success code.
   --  In addition, if the Val is already filled-in, they return immediately.

   function Get_Multiple (Name : Alire.Project;
                          Key  : Properties.Labeled.Labels;
                          Val  : in out Utils.UString_Vectors.Vector)
                          return Boolean;

   function Get_Unique (Name : Alire.Project;
                        Key  : Properties.Labeled.Labels;
                        Val  : in out UString)
                        return Boolean;

end Alire.Projects.Collections.Loading;
