with Alire.Requisites.From_TOML;
with Alire.Utils;

package body Alire.Requisites.Cases is

   Dots : constant String := "...";

   use TOML;

   ----------------
   -- Is_Boolean --
   ----------------

   function Is_Boolean (This : Enumerable; I : Enum) return Boolean is
      (This.Cases (I).To_TOML.Kind = TOML_Boolean);

   ----------------
   -- As_Boolean --
   ----------------

   function As_Boolean (This : Enumerable; I : Enum) return Boolean is
      (This.Cases (I).To_TOML.As_Boolean);

   ---------------
   -- From_TOML --
   ---------------

   overriding
   function From_TOML (This : in out Enumerable;
                       From : TOML_Adapters.Key_Queue)
                       return Outcome
   is
      Seen : array (Enum) of Boolean := (others => False);
      --  Track values that have appeared

      -----------------
      -- Reduce_Seen --
      -----------------

      function Reduce_Seen (I : Enum := Enum'First; Comma : Boolean := False)
                            return String is
        ((if not Seen (I)
          then (if Comma
                then ", "
                else "") & TOML_Adapters.Tomify_As_String (I'Img)
          else "") &
         (if I = Enum'Last
          then ""
          else Reduce_Seen (Enum'Succ (I), Comma or not Seen (I))));

   begin
      --  Treat the "..." case first
      declare
         RHS : TOML.TOML_Value;
      begin
         if From.Pop (Dots, RHS) then
            Seen := (others => True);
            declare
               Val    : Trees.Tree;
               Result : constant Outcome :=
                          Requisites.From_TOML.From_TOML
                            (Val,
                             RHS,
                             From.Descend (Dots));
            begin
               if Result.Success then
                  This := New_Case ((others => Val));
               else
                  return Result;
               end if;
            end;
         else
            This := New_Case ((others => No_Requisites));
         end if;
      end;

      --  Treat explicit cases
      loop
         declare
            RHS : TOML_Value;
            LHS : constant String := From.Pop (RHS);
         begin
            exit when LHS = "";
            declare
               Val    : Trees.Tree;
               Result : constant Outcome :=
                          Requisites.From_TOML.From_TOML
                            (Val,
                             RHS,
                             From.Descend (LHS));
            begin
               if not Result.Success then
                  return Result;
               else
                  --  We have the Requisite, store it in all pertinent keys:
                  for E_Str of Utils.String_Vector'(Utils.Split (LHS, '|'))
                  loop
                     declare
                        E : Enum;
                     begin
                        E := Enum'Value (TOML_Adapters.Adafy (E_Str));
                        Seen (E) := True;
                        This.Cases (E) := Val;
                     exception
                        when others =>
                           return From.Failure
                             ("invalid enumeration value: " & E_Str);
                     end;
                  end loop;
               end if;
            end;
         end;
      end loop;

      if (for some E of Seen => E = False) then
         --  TODO: change to error once index is fixed
         Trace.Warning ("missing enumeration cases: " & Reduce_Seen);
      end if;

      return Outcome_Success;
   end From_TOML;

   ---------------
   -- From_TOML --
   ---------------

   function From_TOML (From   : TOML_Adapters.Key_Queue;
                       Result : out Outcome)
                       return Interfaces.Detomifiable'Class
   is
      E : Enumerable;
   begin
      Result := E.From_TOML (From);
      return E;
   end From_TOML;

   -------------
   -- To_TOML --
   -------------

   overriding
   function To_TOML (This : Enumerable) return TOML.TOML_Value is

      function Aggregate (Bool  : Boolean;
                          I     : Enum;
                          Prev  : String) return String is
        (if This.Is_Boolean (I) and then This.As_Boolean (I) = Bool then
             (if Prev /= ""
              then Prev & "|"
              else "") & TOML_Adapters.Tomify_As_String (I'Img)
         else Prev);

      ----------------------
      -- Set_If_Not_Empty --
      ----------------------

      procedure Set_If_Not_Empty (Table : TOML.TOML_Value;
                                  Key   : String;
                                  Value : TOML.TOML_Value) is
      begin
         if Key /= "" then
            Table.Set (Key, Value);
         end if;
      end Set_If_Not_Empty;

      Same   : Boolean :=
                 This.Is_Boolean (Enum'First) and then
                 This.As_Boolean (Enum'First);
      Master : constant TOML.TOML_Value := TOML.Create_Table;
      Cases  : constant TOML.TOML_Value := TOML.Create_Table;
   begin
      Master.Set ("case(" & TOML_Name & ")", Cases);

      --  Check that all are equal
      for I in This.Cases'Range loop
         Same := This.Is_Boolean (I) and then This.As_Boolean (I) = Same;
         exit when not Same;
      end loop;

      if Same then
         Cases.Set (Dots, TOML.Create_Boolean (Same));
      else
         Set_If_Not_Empty (Cases,
                           Aggregate (True,  Enum'First, ""),
                           TOML.Create_Boolean (True));
         Set_If_Not_Empty (Cases,
                           Aggregate (False, Enum'First, ""),
                           TOML.Create_Boolean (False));
         for I in This.Cases'Range loop
            if not This.Is_Boolean (I) then
               raise Unimplemented;
               --  TODO: convert tree to TOML, and get key from the first
               --  entry, which will be a case (see Master above). Use that
               --  case as key for the remainder of tree.
            end if;
         end loop;
      end if;

      return Master;
   end To_TOML;

end Alire.Requisites.Cases;
