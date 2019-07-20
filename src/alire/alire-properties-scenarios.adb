with Alire.TOML_Adapters;

package body Alire.Properties.Scenarios is

   ---------------
   -- From_TOML --
   ---------------

   function From_TOML (Key    : String;
                       Value  : TOML.TOML_Value;
                       Result : out Outcome)
                       return Conditional.Properties
   is
      use Conditional.For_Properties;
      use TOML;

      -----------------------
      -- Process_Externals --
      -----------------------

      function Process_Externals return Conditional.Properties is
         Table : constant TOML_Adapters.Key_Queue := TOML_Adapters.From
           (Value, TOML_Keys.GPR_Ext);
      begin
         return Props : Conditional.Properties do
            --  TODO: check for conditionals here
            --  Do it reversing the order in which they appear in the current
            --  index format descr, since that leads to uncomfortable pairings.
            loop
               declare
                  Val : TOML.TOML_Value;
                  Key : constant String := Table.Pop (Val);
               begin
                  exit when Key = "";

                  if Val.Kind = TOML_String then
                     if Val.As_String = "" then
                        Props := Props and
                          (New_Property (GPR.Free_Variable (Key)));
                     else
                        Result := Table.Failure
                          ("free scenario variable must be given as """"");
                        return;
                     end if;
                  elsif Val.Kind = TOML_Array then
                     if Val.Length < 2 then
                        Result := Table.Failure
                          ("At least two values required in scenario");
                     end if;
                     if Val.Item_Kind = TOML_String then
                        declare
                           use GPR;
                           Values : GPR.Value_Vector;
                        begin
                           for I in 1 .. Val.Length loop
                              Values := Values or Val.Item (I).As_String;
                           end loop;
                           Props := Props and New_Property
                             (GPR.Enum_Variable (Key, Values));
                        end;
                     else
                        Result := Table.Failure
                          ("scenario values must be a string array");
                     end if;
                  end if;
               end;
            end loop;

            if Props.Is_Empty then
               Result := Table.Failure ("empty table");
            end if;
         end return;
      end Process_Externals;

      ---------------------------
      -- Process_Set_Externals --
      ---------------------------

      function Process_Set_Externals return Conditional.Properties is
         Table : constant TOML_Adapters.Key_Queue := TOML_Adapters.From
           (Value, TOML_Keys.GPR_Set_Ext);
      begin
         --  TODO: same things about conditionals
         return Props : Conditional.Properties do
            loop
               declare
                  Val : TOML.TOML_Value;
                  Key : constant String := Table.Pop (Val);
               begin
                  exit when Key = "" or else Val.Kind = TOML_Table;
                  --  TODO: the above condition is to pass on 'case' for now

                  if Val.Kind /= TOML_String then
                     Result := Table.Failure
                       ("externals must be given as strings");
                     return;
                  end if;

                  Props := Props and New_Property
                    (GPR.External_Value (Key, Val.As_String));
               end;

               if Props.Is_Empty then
                  Result := Table.Failure ("scenario sets no externals");
               end if;
            end loop;
         end return;
      end Process_Set_Externals;

   begin
      Result := Outcome_Success;

      if Value.Kind /= TOML_Table then
         Result := Outcome_Failure ("scenarios require a table");
         return Conditional.For_Properties.Empty;
      end if;

      if Key = TOML_Keys.GPR_Ext then
         return Process_Externals;
      else
         return Process_Set_Externals;
      end if;
   end From_TOML;

   -------------
   -- To_TOML --
   -------------

   overriding function To_TOML (V : Property) return TOML.TOML_Value is
      Table : constant TOML.TOML_Value := TOML.Create_Table;
      use all type GPR.Variable_Kinds;
      use TOML_Adapters;
   begin
      case V.Var.Element.Kind is
         when Enumeration =>
            declare
               Arr : constant TOML.TOML_Value :=
                 TOML.Create_Array (TOML.TOML_String);
            begin
               for Val of V.Var.Element.Values loop
                  Arr.Append (+Val);
               end loop;

               Table.Set (V.Var.Element.Name, Arr);
            end;
         when Free_String =>
            Table.Set (V.Var.Element.Name, +"");
         when External =>
            Table.Set (V.Var.Element.Name, +V.Var.Element.External_Value);
      end case;

      return Table;
   end To_TOML;

end Alire.Properties.Scenarios;
