with Alire.TOML_Keys;

with TOML;

package body Alire.Projects.With_Releases is

   ---------------
   -- From_TOML --
   ---------------

   overriding
   function From_TOML (This : in out Crate;
                       From :        TOML_Adapters.Key_Queue)
                       return Outcome
   is
   begin
      --  Process the general key
      declare
         Val : TOML.TOML_Value;
      begin
         if not From.Pop (TOML_Keys.General, Val) then
            return Outcome_Failure ("Missing general section in crate");
         end if;

         declare
            Result : constant Outcome :=
                       General (This).From_TOML (TOML_Adapters.From (Val));
         begin
            if not Result.Success then
               return Result;
            end if;
         end;
      end;

      --  Process remaining keys, that must be releases
      loop
         declare
            Val : TOML.TOML_Value;
            Key : constant String := From.Pop (Val);
         begin
            exit when Key = "";

            raise Unimplemented;
         end;
      end loop;

      --  There cannot be any remaining keys at this level, as any unknown key
      --  has been processed as a version or already reported as invalid.

      return Outcome_Success;
   end From_TOML;

   -----------------
   -- Description --
   -----------------

   function Description (This : Crate) return Description_String is
      (raise Unimplemented);

   ----------
   -- Name --
   ----------

   function Name (This : Crate) return Alire.Project is (+(+This.Name));

   ---------------
   -- New_Crate --
   ---------------

   function New_Crate (Name : Alire.Project) return Crate is
     (Crate'(General with
             Len      => Name'Length,
             Name     => Name,
             Releases => <>));

   --------------
   -- Releases --
   --------------

   function Releases (This : Crate) return Containers.Release_Set is
      (This.Releases);

end Alire.Projects.With_Releases;
