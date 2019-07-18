package body Alire.Properties is

   ------------
   -- Filter --
   ------------

   function Filter (V : Vector; Ancestor : Ada.Tags.Tag) return Vector is
      Result : Vector := No_Properties;
   begin
      for Prop of V loop
         if Ada.Tags.Is_Descendant_At_Same_Level (Prop'Tag, Ancestor) then
            Result.Append (Prop);
         end if;
      end loop;

      return Result;
   end Filter;

   -------------
   -- To_TOML --
   -------------

   overriding function To_TOML (V : Vector) return TOML.TOML_Value is
      use TOML;
   begin
      raise Unimplemented;
      return To_TOML (V);
   end To_TOML;

end Alire.Properties;
