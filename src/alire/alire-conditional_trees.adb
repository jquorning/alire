with GNAT.IO;

package body Alire.Conditional_Trees is

   ---------------------
   -- Image_Classwide --
   ---------------------

   function Image_Classwide (This : Node'Class) return String is
     (This.Image);

   -------------
   -- Flatten --
   -------------

   procedure Flatten (Inner : in out Vector_Node; -- The resulting vector
                      This  : Node'Class;    -- The next node to flatten
                      Conj  : Conjunctions);       -- To prevent mixing

   -----------
   -- Image --
   -----------

   overriding function Image (V : Leaf_Node) return String is
     (Image (V.Value.Constant_Reference));

   -----------------
   -- Conjunction --
   -----------------

   function Conjunction (This : Vector_Node) return Conjunctions is
     (This.Conjunction);

   -----------
   -- Image --
   -----------

   overriding function Image (V : Vector_Node) return String is
     ("(" & (if V.Conjunction = Anded
             then Non_Primitive.One_Liner_And (V.Values)
             else Non_Primitive.One_Liner_Or (V.Values)) & ")");

   -----------
   -- Image --
   -----------

   overriding function Image (V : Conditional_Node) return String is
     ("if " & V.Condition.Image &
        " then " & V.Then_Value.Image_One_Line &
        " else " & V.Else_Value.Image_One_Line);

   -----------------
   -- Conjunction --
   -----------------

   function Conjunction (This : Tree) return Conjunctions is
     (Vector_Node'Class (This.Element).Conjunction);

   -----------------
   -- First_Child --
   -----------------

   function First_Child (This : Tree) return Tree is
      (To_Tree (Vector_Node (This.Root).Values.First_Element));

   ---------------------
   -- New_Conditional --
   ---------------------

   function New_Conditional (If_X   : Requisites.Tree;
                             Then_X : Tree;
                             Else_X : Tree) return Tree is
     (To_Holder (Conditional_Node'(Condition  => If_X,
                                    Then_Value => Then_X,
                                    Else_Value => Else_X)));

   --------------
   -- New_Leaf --
   --------------

   function New_Leaf (V : Values) return Tree is
     (To_Holder (Leaf_Node'(Value => Definite_Values.To_Holder (V))));

   ---------------
   -- Condition --
   ---------------

   function Condition (This : Tree) return Requisites.Tree is
     (Conditional_Node (This.Root).Condition);

   ----------------
   -- True_Value --
   ----------------

   function True_Value (This : Tree) return Tree is
      (Conditional_Node (This.Root).Then_Value);

   -----------------
   -- False_Value --
   -----------------

   function False_Value (This : Tree) return Tree is
      (Conditional_Node (This.Root).Else_Value);

   -----------
   -- Empty --
   -----------

   function Empty return Tree is
      (Holders.Empty_Holder with null record);

   --------------
   -- Is_Empty --
   --------------

   overriding function Is_Empty (This : Tree) return Boolean is
     (Holders.Holder (This).Is_Empty);

   --------------------
   -- Image_One_Line --
   --------------------

   function Image_One_Line (This : Tree) return String is
     (if This.Is_Empty
      then "(empty condition)"
      else This.Constant_Reference.Image);

   ----------------------------
   -- All_But_First_Children --
   ----------------------------

   function All_But_First_Children (This : Tree) return Tree is
      Children : Vectors.Vector := Vector_Node (This.Root).Values;
   begin
      Children.Delete_First;
      return To_Holder (Vector_Node'(This.Conjunction, Children));
   end All_But_First_Children;

   -------------
   -- Flatten --
   -------------
   --  Remove redundant and/or subtrees by merging upwards in a matching vector
   procedure Flatten (Inner : in out Vector_Node;
                      This  : Node'Class;
                      Conj  : Conjunctions)
   is
   begin
      if This in Leaf_Node then
         Inner.Values.Append (This);
      elsif This in Vector_Node then
         --  Flatten ofly if conjunction matches, otherwise just append
         --  subtree.
         if Vector_Node (This).Conjunction = Conj then
            for Child of Vector_Node (This).Values loop
               Flatten (Inner, Child, Conj);
            end loop;
         else
            Inner.Values.Append (This);
         end if;
      else
         --  Unknown node class, just append subtree:
         Inner.Values.Append (This);
      end if;
   end Flatten;

   -----------
   -- "and" --
   -----------

   function "and" (L, R : Tree) return Tree is
      Inner : Vector_Node := (Conjunction => Anded, Values => <>);

   begin
      if not L.Is_Empty then
         Flatten (Inner, L.Constant_Reference, Anded);
      end if;

      if not R.Is_Empty then
         Flatten (Inner, R.Constant_Reference, Anded);
      end if;

      if Inner.Values.Is_Empty then
         return Empty;
      else
         return (To_Holder (Inner));
      end if;
   end "and";

   ----------
   -- "or" --
   ----------

   function "or" (L, R : Tree) return Tree is
      Inner : Vector_Node := (Conjunction => Ored, Values => <>);

   begin
      if not L.Is_Empty then
         Flatten (Inner, L.Constant_Reference, Ored);
      end if;

      if not R.Is_Empty then
         Flatten (Inner, R.Constant_Reference, Ored);
      end if;

      if Inner.Values.Is_Empty then
         return Empty;
      else
         return (To_Holder (Inner));
      end if;
   end "or";

      ----------------
   -- Leaf_Count --
   ----------------

   overriding
   function Leaf_Count (This : Vector_Node) return Positive is
      Count : Natural := 0;
   begin
      for Child of This.Values loop
         Count := Count + Child.Leaf_Count;
      end loop;
      return Count;
   end Leaf_Count;

   -----------------
   -- Materialize --
   -----------------

   function Materialize (This : Tree;
                         Against : Properties.Vector)
                         return Collection
   is
      Col : Collection;
      Pre : constant Tree := This.Evaluate (Against);

      procedure Visit (Inner : Node'Class) is
      begin
         case Inner.Kind is
            when Value =>
               Append (Col, Leaf_Node (Inner).Value.Constant_Reference);
            when Condition =>
               raise Program_Error with "Should not appear in evaluated CV";
            when Vector =>
               if Vector_Node (Inner).Conjunction = Anded then
                  for Child of Vector_Node (Inner).Values loop
                     Visit (Child);
                  end loop;
               else
                  raise Constraint_Error
                    with "OR trees cannot be materialized as list";
               end if;
         end case;
      end Visit;

   begin
      if not Pre.Is_Empty then
         Visit (Pre.Constant_Reference);
      end if;
      return Col;
   end Materialize;

   ---------------
   -- Enumerate --
   ---------------

   function Enumerate (This : Tree) return Collection is
      Col : Collection with Warnings => Off;

      procedure Visit (Inner : Node'Class) is
      begin
         case Inner.Kind is
            when Value =>
               Append (Col, Leaf_Node (Inner).Value.Constant_Reference);
            when Condition =>
               Visit (Conditional_Node (Inner).Then_Value.Constant_Reference);
               if not Conditional_Node (Inner).Else_Value.Is_Empty then
                  Visit
                    (Conditional_Node (Inner).Else_Value.Constant_Reference);
               end if;
            when Vector =>
               for Child of Vector_Node (Inner).Values loop
                  Visit (Child);
               end loop;
         end case;
      end Visit;

   begin
      if not This.Is_Empty then
         Visit (This.Constant_Reference);
      end if;
      return Col;
   end Enumerate;

   --------------
   -- Evaluate --
   --------------

   overriding
   function Evaluate (This    : Vector_Node;
                      Against : Properties.Vector)
                      return Tree'Class
   is
      Result : Vector_Node;
   begin
      Result.Conjunction := This.Conjunction;
      for Child of This.Values loop
         Result.Values.Append (Child.Evaluate (Against).Root);
      end loop;

      return Result.To_Tree;
   end Evaluate;

   --------------
   -- Evaluate --
   --------------

   function Evaluate (This : Tree; Against : Properties.Vector) return Tree is
   begin
      if This.Is_Empty then
         return This;
      else
         return Tree (This.Root.Evaluate (Against));
      end if;
   end Evaluate;

   ------------------
   -- Contains_ORs --
   ------------------

   function Contains_ORs (This : Tree) return Boolean is

      function Verify (This : Tree) return Boolean is
         Contains : Boolean := False;
      begin
         case This.Kind is
            when Value =>
               return False;
            when Condition =>
               return
                 This.True_Value.Contains_ORs or else
                 This.False_Value.Contains_ORs;
            when Vector =>
               if This.Conjunction = Ored then
                  return True;
               else
                  for Child of This loop
                     Contains := Contains or else Verify (Child);
                  end loop;
                  return Contains;
               end if;
         end case;
      end Verify;

   begin
      if This.Is_Empty then
         return False;
      else
         return Verify (This);
      end if;
   end Contains_ORs;

   ----------------------
   -- Is_Unconditional --
   ----------------------

   function Is_Unconditional (This : Tree) return Boolean is

      function Verify (This : Tree) return Boolean is
         Pass : Boolean := True;
      begin
         case This.Kind is
            when Value =>
               return True;
            when Condition =>
               return False;
            when Vector =>
               for Child of This loop
                  Pass := Pass and then Verify (Child);
               end loop;
               return Pass;
         end case;
      end Verify;

   begin
      return This.Is_Empty or else Verify (This);
   end Is_Unconditional;

   ----------------------
   -- Iterate_Children --
   ----------------------

   procedure Iterate_Children (This    : Tree;
                               Visitor : access procedure (CV : Tree))
   is

      procedure Iterate (This : Node'Class) is
      begin
         case This.Kind is
            when Value | Condition =>
               raise Constraint_Error with "Conditional value is not a vector";
            when Vector =>
               for Inner of Vector_Node (This).Values loop
                  Visitor (Tree'(To_Holder (Inner)));
               end loop;
         end case;
      end Iterate;

   begin
      if not This.Is_Empty then
         Iterate (This.Constant_Reference);
      end if;
   end Iterate_Children;

   ---------------------
   -- Case_Statements --
   ---------------------

   package body Case_Statements is

      function Case_Is (Arr : Arrays) return Tree is
         Case_Is : Tree := Arr (Arr'Last);
         --  Since we get the whole array,
         --    by exhaustion at worst the last must be true
      begin
         for I in reverse Arr'First .. Enum'Pred (Arr'Last) loop
            Case_Is := New_Conditional (If_X   => Requisite_Equal (I),
                                        Then_X => Arr (I),
                                        Else_X => Case_Is);
         end loop;

         return Case_Is;
      end Case_Is;

   end Case_Statements;

   -----------
   -- Print --
   -----------

   procedure Print (This   : Tree;
                    Prefix : String := "";
                    And_Or : Boolean := True) is
      use GNAT.IO;
      Tab : constant String := "   ";

--        function Image (C : Conjunctions) return String is
--          (case C is
--              when Anded => "and",
--              when Ored  => "or");

   begin
      if This.Is_Empty then
         Put_Line (Prefix & "(empty)");
         return;
      end if;

      case This.Kind is
         when Value =>
            Put_Line (Prefix & Image (This.Value));
         when Condition =>
            Put_Line (Prefix & "when " & This.Condition.Image & ":");
            Print (This.True_Value, Prefix & Tab);
            if not This.False_Value.Is_Empty then
               Put_Line (Prefix & "else:");
               Print (This.False_Value, Prefix & Tab);
            end if;
         when Vector =>
            if And_Or then
               case This.Conjunction is
                  when Anded => Put_Line (Prefix & "All of:");
                  when Ored  => Put_Line (Prefix & "First available of:");
               end case;
            end if;

            for I in This.Iterate loop
               Print (This (I),
                      (if And_Or then Prefix else "") & "   ");
            end loop;
      end case;
   end Print;

   -------------
   -- To_TOML --
   -------------

   overriding
   function To_TOML (This : Tree) return TOML.TOML_Value is
      Root : TOML.TOML_Value;

      ---------
      -- Add --
      ---------

      procedure Add (Table : TOML.TOML_Value;
                     Key   : String;
                     Val   : TOML.TOML_Value)
      is
         --  Add one property to the parent table.
         --  Atomic values are automatically converted into arrays, if
         --    more than one for the same key appears (e.g., executables)
         --  Table values with same key are merged in a single table (e.g.,
         --  dependencies)
         --  Array values with same key are consolidated in a single array
         --    (e.g., actions, which are created as an array of tables).
      begin
         pragma Assert (Table.Kind = TOML.TOML_Table);
         if Table.Has (Key) then
            declare
               Current : constant TOML.TOML_Value := Table.Get (Key);
            begin
               case Current.Kind is
                  when TOML_Table =>
                     Table.Set (Key, TOML.Merge (Current, Val));
                  when TOML_Array =>
                     case Val.Kind is
                        when TOML.Atom_Value_Kind | TOML.TOML_Table =>
                           Current.Append (Val);
                        when TOML.TOML_Array =>
                           --  Consolidate the array into one
                           for I in 1 .. Val.Length loop
                              Current.Append (Val.Item (I));
                           end loop;
                     end case;
                  when TOML.Atom_Value_Kind => -- Convert to array
                     declare
                        Replace : constant TOML.TOML_Value :=
                          TOML.Create_Array;
                     begin
                        Replace.Append (Current);
                        Replace.Append (Val);
                        Table.Set (Key, Replace);
                     end;
               end case;
            end;
         else
            Table.Set (Key, Val);
         end if;
      end Add;

      ------------
      -- Tomify --
      ------------

      procedure Tomify (Parent : TOML.TOML_Value; This : Tree) is
      begin
         case This.Kind is
         when Value =>
            Add (Parent, This.Value.Key, This.Value.To_TOML);
         when Condition =>
            raise Unimplemented;
         when Vector =>
            case This.Conjunction is
               when Anded => null;
               when Ored  => raise Unimplemented;
            end case;

            for I in This.Iterate loop
               Tomify (Parent, This (I));
            end loop;
         end case;
      end Tomify;

   begin
      Root := TOML.Create_Table;
      if not This.Is_Empty then
         Tomify (Root, This);
      end if;
      return Root;
   end To_TOML;

   -------------
   -- To_Code --
   -------------

--     function To_Code (This : Tree) return Utils.String_Vector is
--     begin
--        case This.Kind is
--           when Value =>
--              return To_Code (This.Value);
--           when Vector =>
--              return V : Utils.String_Vector do
--                 for I in This.Iterate loop
--                    V.Append (This (I).To_Code);
--                    if Has_Element (Next (I)) then
--                       V.Append (Conj_To_Code (This (I).Conjunction));
--                    end if;
--                 end loop;
--              end return;
--           when Condition =>
--              raise Program_Error with "Unimplemented";
--        end case;
--     end To_Code;

   -----------------
   --  ITERATORS  --
   -----------------

   type Forward_Iterator is new Iterators.Forward_Iterator with record
      Children : Vectors.Vector;
   end record;

   -----------
   -- First --
   -----------

   overriding function First (Object : Forward_Iterator) return Cursor is
     (if Object.Children.Is_Empty
      then Cursor (Vectors.No_Element)
      else Cursor (Object.Children.First));

   ----------
   -- Next --
   ----------

   overriding function Next (This : Cursor) return Cursor is
      (Cursor (Vectors.Next (Vectors.Cursor (This))));

   ----------
   -- Next --
   ----------

   overriding function Next (Object   : Forward_Iterator;
                             Position : Cursor) return Cursor is
     (Next (Position));

   -----------------
   -- Has_Element --
   -----------------

   overriding function Has_Element (This : Cursor) return Boolean is
      (Vectors.Has_Element (Vectors.Cursor (This)));

   -------------
   -- Iterate --
   -------------

   function Iterate (Container : Tree)
                     return Iterators.Forward_Iterator'Class is
   begin
      if Container.Is_Empty then
         return Forward_Iterator'(others => <>);
      end if;

      if Container.Kind /= Vector then
         raise Constraint_Error
           with "Cannot iterate over non-vector conditional value";
      end if;

      return Forward_Iterator'
        (Children =>
           Vector_Node (Container.Constant_Reference.Element.all).Values);
   end Iterate;

   ---------------------
   -- Indexed_Element --
   ---------------------

   function Indexed_Element (Container : Tree;
                             Pos       : Cursor)
                             return Tree is
     (Tree'(To_Holder (Element (Pos))));

end Alire.Conditional_Trees;
