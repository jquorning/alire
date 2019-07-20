with Alire.TOML_Adapters;

package body Alire.Actions is

   -------------
   -- Execute --
   -------------

   procedure Execute (This : Action;
                      Implementer : access procedure (This : Action'Class))
   is
   begin
      Implementer (This);
   end Execute;

   -------------
   -- To_TOML --
   -------------

   overriding function To_TOML (This : Run) return TOML.TOML_Value is

      use TOML_Adapters;

      function Tomify is new TOML_Adapters.Tomify (Moments);

      Arr : constant TOML.TOML_Value := TOML.Create_Array;
      --  Actions are output as an array of tables, so we return an array
      --    containing the single table of this action.
      Table : constant TOML.TOML_Value := TOML.Create_Table;
   begin
      Table.Set (TOML_Keys.Action_Type,    Tomify (This.Moment));
      Table.Set (TOML_Keys.Action_Command, +This.Command_Line);
      if This.Working_Folder /= "" then
         Table.Set (TOML_Keys.Action_Folder,  +This.Working_Folder);
      end if;
      Arr.Append (Table);
      return Arr;
   end To_TOML;

   ---------------
   -- From_TOML --
   ---------------

   function From_TOML (Key    : String;
                       Value  : TOML.TOML_Value;
                       Result : out Outcome)
                       return Conditional.Properties is

      use Conditional.For_Properties;
      use TOML;

      ----------------
      -- Create_One --
      ----------------

      function Create_One return Conditional.Properties is
         Table   : constant TOML_Adapters.Key_Queue :=
                     TOML_Adapters.From (Value, Key);
         Kind    : TOML_Value;
         Command : TOML_Value;
         Path    : TOML_Value;
         Used    : Boolean;
      begin
         if not Table.Pop (TOML_Keys.Action_Type, Kind) then
            Result := Table.Failure ("action type missing");
            return Empty;
         elsif not Table.Pop (TOML_Keys.Action_Command, Command) then
            Result := Table.Failure ("action command missing");
            return Empty;
         end if;

         Used := Table.Pop (TOML_Keys.Action_Folder, Path);

         if Kind.Kind /= TOML_String
           or else Command.Kind /= TOML_String
           or else (Used and then Path.Kind /= TOML_String)
         then
            Result := Table.Failure ("actions fields must be strings");
            return Empty;
         end if;

         return New_Value
           (New_Run
              (Moment                =>
                 Moments'Value (TOML_Adapters.Adafy (Kind.As_String)),
               Relative_Command_Line =>
                 Command.As_String,
               Working_Folder        =>
                 (if Used then Path.As_String else ".")));
      end Create_One;
   begin
      Result := Outcome_Success;

      if Value.Kind = TOML_Table then
         return Create_One;
      end if;

      return Props : Conditional.Properties do
         for I in 1 .. Value.Length loop
            Props := Props and From_TOML (Key, Value.Item (I), Result);
            if not Result.Success then
               return;
            end if;
         end loop;
      end return;
   end From_TOML;

end Alire.Actions;
