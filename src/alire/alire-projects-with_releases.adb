with Alire.Properties.Labeled;
with Alire.Releases;
with Alire.TOML_Keys;

with Semantic_Versioning;

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
      package Semver renames Semantic_Versioning;
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
                       General (This)
                       .From_TOML
                         (TOML_Adapters.From
                            (Val,
                             Context => "general",
                             Parent  => From));
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
            Ver : Semver.Version;
         begin
            exit when Key = "";

            Ver := Semver.Parse (Key, Relaxed => False);

            declare
               Release : Alire.Releases.Release :=
                           Alire.Releases
                             .New_Working_Release (Project => This.Name)
                             .Retagging (Ver)
                             .Replacing (Properties   => This.Properties)
                             .Replacing (Dependencies => This.Dependencies)
                             .Replacing (Available    => This.Available);
               Result  : constant Outcome :=
                           Release
                             .From_TOML
                               (TOML_Adapters.From
                                  (Val,
                                   Context => Key,
                                   Parent  => From));
            begin
               if not Result.Success then
                  return Result;
               end if;

               This.Releases.Insert (Release);
            end;

         exception
            when Semver.Malformed_Input =>
               return Outcome_Failure ("Bad crate version: " & Key);
         end;
      end loop;

      --  There cannot be any remaining keys at this level, as any unknown key
      --  has been processed as a version or already reported as invalid.

      if This.Releases.Is_Empty then
         Trace.Warning ("Crate contains no releases: " & (+This.Name));
      end if;

      return Outcome_Success;
   end From_TOML;

   -----------------
   -- Description --
   -----------------

   function Description (This : Crate) return Description_String is
      Descr : constant Properties.Vector :=
                Properties.Labeled.Filter
                  (Conditional.Enumerate (This.Properties),
                   Properties.Labeled.Description);
   begin
      if Natural (Descr.Length) > 1 then
         raise Program_Error with "Multiple descriptions!";
         --  Shouldn't happen because the loader checks for multiplicity.
      else
         return Properties.Labeled.Label (Descr.First_Element).Value;
      end if;
   end Description;

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
