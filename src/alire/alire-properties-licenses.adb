package body Alire.Properties.Licenses is

   ---------------
   -- From_TOML --
   ---------------

   function From_TOML (Key    : String;
                       Value  : TOML.TOML_Value;
                       Result : out Outcome)
                       return Conditional.Properties
   is
      pragma Unreferenced (Key);
      use TOML;
      Props : Conditional.Properties;
      use all type Conditional.Properties;
   begin
      Result := Outcome_Success;

      if Value.Kind /= TOML_Array then
         Result := Outcome_Failure ("license expects an array");
      else
         for I in 1 .. Value.Length loop
            if Value.Item (I).Kind = TOML_String then
               Props := Props and
                 Conditional.For_Properties.New_Value
                   (New_License (Value.Item (I).As_String));
            else
               Result := Outcome_Failure ("licenses must be strings");
               return Props;
            end if;
         end loop;
      end if;

      return Props;
   end From_TOML;

end Alire.Properties.Licenses;
