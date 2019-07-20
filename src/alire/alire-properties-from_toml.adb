package body Alire.Properties.From_TOML is

   ----------
   -- Load --
   ----------

   function Load (Properties : in out Conditional.Properties;
                  Loaders    :        Loader_Array;
                  From       :        TOML_Adapters.Key_Queue)
                  return Outcome
   is
      function Tomify is new TOML_Adapters.Tomify_As_String (Property_Keys);
   begin
      for I in Loaders'Range loop
         if Loaders (I) = null then
            goto Continue;
         end if;

         declare
            Key   : constant String := Tomify (I);
            Value : TOML.TOML_Value;
         begin
            if From.Pop (Key, Value) then
               declare
                  Result : Outcome;
                  Prop   : constant Conditional.Properties :=
                             Loaders (I) (Key, Value, Result);
                  use all type Conditional.Properties;
               begin
                  if Result.Success then
                     Properties := Properties and Prop;
                  else
                     return Result;
                  end if;
               end;
            end if;
         end;

         <<Continue>>
      end loop;

      return Outcome_Success;
   end Load;

end Alire.Properties.From_TOML;
