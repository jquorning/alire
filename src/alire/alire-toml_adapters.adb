package body Alire.TOML_Adapters is

   ----------
   -- From --
   ----------

   function From (Value : TOML.TOML_Value) return Key_Queue is
     (Value.Clone with null record);
   --  TODO: check if without deep copy it works properly.

   ---------
   -- Pop --
   ---------

   function Pop (Queue :        Key_Queue;
                 Value :    out TOML.TOML_Value) return String is
   begin
      --  Use first of remaining keys
      for Key of Queue.Keys loop
         Value := TOML.TOML_Value (Queue.Get (Key));
         Queue.Unset (Key);
         return +Key;
      end loop;

      --  If no keys left...
      return "";
   end Pop;

   ---------
   -- Pop --
   ---------

   function Pop (Queue : Key_Queue;
                 Key   : String;
                 Value : out TOML.TOML_Value) return Boolean
   is
      use TOML;
   begin
      Value := TOML_Value (Queue).Get_Or_Null (Key);
      if Value /= No_TOML_Value then
         Queue.Unset (Key);
      end if;
      return Value /= TOML.No_TOML_Value;
   end Pop;

   -----------------------
   -- Report_Extra_Keys --
   -----------------------

   function Report_Extra_Keys (Queue : Key_Queue) return Outcome
   is
      Message  : UString := +"forbidden extra entries: ";
      Is_First : Boolean := True;
      Errored  : Boolean := False;
   begin
      for Key of Queue.Keys loop
         Errored := True;
         if Is_First then
            Is_First := False;
         else
            UStrings.Append (Message, ", ");
         end if;
         UStrings.Append (Message, Key);
      end loop;

      if Errored then
         return Outcome_Failure (+Message);
      else
         return Outcome_Success;
      end if;
   end Report_Extra_Keys;

   --------------
   -- To_Array --
   --------------

   function To_Array (V : TOML.TOML_Value) return TOML.TOML_Value is
      use TOML;
   begin
      if V.Kind = TOML_Array then
         return V;
      else
         declare
            Arr : constant TOML_Value := Create_Array (V.Kind);
         begin
            Arr.Append (V);
            return Arr;
         end;
      end if;
   end To_Array;

   --------------
   -- To_Table --
   --------------

   function To_Table (Key : String;
                      Val : TOML.TOML_Value) return TOML.TOML_Value is
      use TOML;
   begin
      return Table : constant TOML_Value := Create_Table do
         Table.Set (Key, Val);
      end return;
   end To_Table;

end Alire.TOML_Adapters;
