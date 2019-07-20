with Alire.TOML_Adapters;

package body Alire.Properties.Labeled is

   ------------
   -- Filter --
   ------------

   function Filter (LV : Vector; Name : Labels) return Vector is
   begin
      return Result : Vector do
         for L of LV loop
            if L in Label and then
              Label'Class (L).Name = Name
            then
               Result.Append (L);
            end if;
         end loop;
      end return;
   end Filter;

   ---------------
   -- From_TOML --
   ---------------

   ---------------
   -- From_TOML --
   ---------------

   function From_TOML (Key    : String;
                       Value  : TOML.TOML_Value;
                       Result : out Outcome)
                       return Conditional.Properties
   is
      type TOML_Keys is -- Matching the TOML key. We could have saved a lot
      --  of back and forth by making the labels match their TOML key...
        (Authors,
         Comment,
         Description,
         Executables,
         Maintainers,
         Notes,
         Paths,
         Project_Files,
         Website);
      pragma Assert (TOML_Keys'Pos (TOML_Keys'Last) =
                     Labels'Pos (Labels'Last));
      function Key_To_Label (K : TOML_Keys) return Labels is
        (Labels'Val (TOML_Keys'Pos (K)));
   begin
      return Props : Conditional.Properties do
         declare
            Val : constant TOML.TOML_Value := TOML_Adapters.To_Array (Value);
         begin
            for I in 1 .. Val.Length loop
               declare
                  L : constant Label := New_Label
                    (Key_To_Label
                       (TOML_Keys'Value (TOML_Adapters.Adafy (Key))),
                     Val.Item (I).As_String);
                  use all type Conditional.Properties;
               begin
                  if Cardinality (L.Name) = Unique and then I > 1 then
                     Result := Outcome_Failure
                       ("Expected single value for " & Key);
                     return;
                  end if;

                  Props := Props and
                    Conditional.For_Properties.New_Value (L);
               end;
            end loop;
         end;

         Result := Outcome_Success;
      end return;
   exception
      when E : others =>
         Log_Exception (E);
         Result := Outcome_Failure ("Cannot read valid property from " & Key);
         return Conditional.For_Properties.Empty;
   end From_TOML;

   -------------------
   -- To_TOML_Array --
   -------------------

   function To_TOML_Array (LV   : Vector;
                           Name : Labels)
                           return TOML.TOML_Value
   is
      use TOML;
      Values : constant TOML_Value := Create_Array;
   begin
      for V of Filter (LV, Name) loop
         Values.Append (Create_String (Labeled.Label'Class (V).Value));
      end loop;

      return Values;
   end To_TOML_Array;

end Alire.Properties.Labeled;
