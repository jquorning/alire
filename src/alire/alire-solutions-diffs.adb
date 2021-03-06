with Alire.Containers;
with Alire.Utils.Tables;

package body Alire.Solutions.Diffs is

   use type Semantic_Versioning.Version;

   ------------------
   -- Best_Version --
   ------------------

   function Best_Version (Status : Crate_Status) return String is
     (case Status.Status is
         when Needed   => Semantic_Versioning.Image (Status.Version),
         when Hinted   => Status.Versions.Image,
         when Unneeded => "unneeded",
         when Unsolved => "unsolved");

   -------------
   -- Between --
   -------------

   function Between (Former, Latter : Solution) return Diff is

      use type Containers.Crate_Name_Sets.Set;

      -----------------
      -- Make_Status --
      -----------------

      function Make_Status (Crate : Crate_Name;
                            Sol   : Solution) return Crate_Status is
      begin
         if not Sol.Valid then
            return (Status => Unsolved);

         elsif Sol.Releases.Contains (Crate) then
            return (Status  => Needed,
                    Version => Sol.Releases (Crate).Version);

         elsif Sol.Hints.Contains (Crate) then
            return (Status   => Hinted,
                    Versions => Sol.Hints (Crate).Versions);

         else
            return (Status => Unneeded);

         end if;
      end Make_Status;

      --  Get all involved crates, before and after

      Crates : constant Containers.Crate_Name_Sets.Set :=
                 Former.Required or Latter.Required;
   begin
      return This : Diff do

         --  Solution validities

         This.Former_Valid := Former.Valid;
         This.Latter_Valid := Latter.Valid;

         --  Store changes for each crate

         for Crate of Crates loop
            This.Changes.Insert (Crate,
                                 Crate_Changes'
                                   (Former => Make_Status (Crate, Former),
                                    Latter => Make_Status (Crate, Latter)));
         end loop;

      end return;
   end Between;

   ------------
   -- Change --
   ------------

   function Change (This : Diff; Crate : Crate_Name) return Changes is
      Former : Crate_Status renames This.Changes (Crate).Former;
      Latter : Crate_Status renames This.Changes (Crate).Latter;
   begin
      if Former.Status = Latter.Status then
         return Unchanged;
      end if;

      return
        (case Latter.Status is
            when Needed =>
              (if Former.Status = Needed then
                 (if Former.Version < Latter.Version then Upgraded
                  elsif Former.Version = Latter.Version then Unchanged
                  else Downgraded)
               else Added),
            when Hinted   => External,
            when Unneeded => Removed,
            when Unsolved => Unsolved);
   end Change;

   ----------------------
   -- Contains_Changes --
   ----------------------

   function Contains_Changes (This : Diff) return Boolean is
     (This.Former_Valid /= This.Latter_Valid or else
      (for some Change of This.Changes => Change.Former /= Change.Latter));

   -----------
   -- Print --
   -----------

   procedure Print (This         : Diff;
                    Changed_Only : Boolean;
                    Prefix       : String       := "   ";
                    Level        : Trace.Levels := Trace.Info)
   is
      use Change_Maps;

      package Semver renames Semantic_Versioning;

      Table : Utils.Tables.Table;
   begin

      --  Start with an empty line to separate from previous output

      Trace.Log ("", Level);

      if not This.Latter_Valid then
         Trace.Log (Prefix & "New solution is invalid.", Level);
      elsif This.Latter_Valid and then not This.Former_Valid then
         Trace.Log (Prefix & "New solution is valid.", Level);
      end if;

      --  Early exit if no changes

      if not This.Contains_Changes then
         Trace.Log (Prefix & "No changes between former an new solution.",
                    Level);
         return;
      end if;

      --  Detailed changes otherwise

      for I in This.Changes.Iterate loop
         declare
            Former : Crate_Status renames This.Changes (I).Former;
            Latter : Crate_Status renames This.Changes (I).Latter;
         begin
            if not Changed_Only or else Former /= Latter then

               --  Show icon of change

               Table.Append
                 (Prefix
                  & (case This.Change (Key (I)) is
                       when Added      => "✓",
                       when Removed    => "✗",
                       when External   => "↪",
                       when Upgraded   => "⭧",
                       when Downgraded => "⭨",
                       when Unchanged  => "=",
                       when Unsolved   => "⚠"));

               --  Always show crate name

               Table.Append (+Key (I));

               --  Show most precise version available

               if Latter.Status in Hinted | Needed then
                  Table.Append (Best_Version (Latter));
               else
                  Table.Append (Best_Version (Former));
               end if;

               --  Finally show an explanation of the change depending on
               --  status changes.

               Table.Append
                 ("("
                  & (case This.Change (Key (I)) is
                       when Added      => "new",
                       when Removed    => "removed",
                       when External   => "external",
                       when Upgraded   => "upgraded from "
                                          & Semver.Image (Former.Version),
                       when Downgraded => "downgraded from "
                                          & Semver.Image (Former.Version),
                       when Unchanged  => "unchanged",
                       when Unsolved   => "missing")
                  & ")");

               Table.New_Row;
            end if;
         end;
      end loop;

      Table.Print (Level);
   end Print;

end Alire.Solutions.Diffs;
