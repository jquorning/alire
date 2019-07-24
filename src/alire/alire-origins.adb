with Alire.Requisites.Platform;
with Alire.TOML_Keys;

package body Alire.Origins is

   function Ends_With (S : String; Suffix : String) return Boolean is
     (S'Length >= Suffix'Length
      and then S (S'Last - Suffix'Length + 1 .. S'Last) = Suffix);
   --  Return whether the S string ends with the given Suffix sub-string

   function URL_Basename (URL : Alire.URL) return String;
   --  Try to get a basename for the given URL. Return an empty string on
   --  failure.

   function Archive_Format (Name : String) return Source_Archive_Format;
   --  Guess the format of a source archive from its file name

   ------------------
   -- URL_Basename --
   ------------------

   function URL_Basename (URL : Alire.URL) return String is
      Separator : Positive := URL'Last + 1;
      --  Index of the first URL separator we can find ('#' or '?') in URL, or
      --  URL'Last + 1 if we haven't found any.

      Last_Slash : Natural := URL'First - 1;
      --  Index of the last slash character in URL before the first URL
      --  separator or URL'First - 1 if we haven't found any.
   begin
      for I in URL'Range loop
         case URL (I) is
            when '?' | '#' =>
               Separator := I;
               exit;

            when '/' =>
               Last_Slash := I;

            when others =>
               null;
         end case;
      end loop;

      return URL (Last_Slash + 1 .. Separator - 1);
   end URL_Basename;

   --------------------
   -- Archive_Format --
   --------------------

   function Archive_Format (Name : String) return Source_Archive_Format is
   begin
      if Ends_With (Name, ".zip") then
         return Zip_Archive;

      elsif Ends_With (Name, ".tar")
        or else Ends_With (Name, ".tar.gz")
        or else Ends_With (Name, ".tgz")
        or else Ends_With (Name, ".tar.bz2")
        or else Ends_With (Name, ".tbz2")
        or else Ends_With (Name, ".tar.xz")
      then
         return Tarball;

      else
         return Unknown;
      end if;
   end Archive_Format;

   ------------------------
   -- New_Source_Archive --
   ------------------------

   function New_Source_Archive
     (URL : Alire.URL; Name : String := "") return Origin
   is
      Archive_Name : constant String :=
        (if Name'Length = 0 then URL_Basename (URL) else Name);
      Format       : Source_Archive_Format;
   begin
      if Archive_Name'Length = 0 then
         raise Unknown_Source_Archive_Name_Error with
           "Unable to determine archive name: please specify one";
      end if;

      Format := Archive_Format (Archive_Name);
      if Format not in Known_Source_Archive_Format then
         raise Unknown_Source_Archive_Format_Error with
           "Unable to determine archive format from file extension";
      end if;

      return (Data => (Source_Archive, +URL, +Archive_Name, Format));
   end New_Source_Archive;

   -----------------
   -- From_String --
   -----------------

   function From_String
     (This   : out Origin;
      From   : String;
      Parent : TOML_Adapters.Key_Queue := TOML_Adapters.Empty_Queue)
      return Outcome
   is
      use Utils;
      Commit : constant String := Tail (From, '@');
      URL    : constant String := Tail (Head (From, '@'), '+');
      Pkg    : constant String := Tail (From, ':');
      Path   : constant String :=
                 From (From'First + Prefixes (Filesystem)'Length ..
                         From'Last);
   begin
      --  Check easy ones first (unique prefixes):
      for Kind in Prefixes'Range loop
         if Prefixes (Kind) /= null and then
           Utils.Starts_With (From, Prefixes (Kind).all)
         then
            case Kind is
               when Git            => This := New_Git (URL, Commit);
               when Hg             => This := New_Hg (URL, Commit);
               when SVN            => This := New_SVN (URL, Commit);
               when Filesystem     => This := New_Filesystem (Path);
               when Native         =>
                  This := New_Native ((others => Packaged_As (Pkg)));
               when Source_Archive =>
                  raise Program_Error with "can't happen";
            end case;
            return Outcome_Success;
         end if;
      end loop;

      --  It must be a source archive
      if not (Starts_With (From, "http://") or else
              Starts_With (From, "https://"))
      then
         return Parent.Failure ("unknown origin: " & From);
      else
         declare
            Archive : TOML.TOML_Value;
         begin
            if not Parent.Pop (TOML_Keys.Origin_Source, Archive) then
               return Parent.Failure ("missing mandatory "
                                      & TOML_Keys.Origin_Source);
            elsif Archive.Kind /= TOML.TOML_String then
               return Parent.Failure ("archive name must be a string");
            end if;
            This := New_Source_Archive (From, Archive.As_String);
            return Outcome_Success;
         end;
      end if;
   end From_String;

   ---------------
   -- From_TOML --
   ---------------

   overriding
   function From_TOML (This : in out Origin;
                       From :        TOML_Adapters.Key_Queue)
                       return Outcome
   is

      -------------------------
      -- Package_From_String --
      -------------------------

      function Package_From_String (Val : TOML.TOML_Value;
                                    Pkg : out Package_Names) return Outcome is
      begin
         if Val.Kind /= TOML.TOML_String then
            return From.Failure ("expected ""native:name"" string for origin");
         end if;

         declare
            Str : constant String := Val.As_String;
         begin
            if Str = "" then
               Pkg := Unavailable;
            elsif not Utils.Starts_With (Str, Prefix_Native) then
               return From.Failure ("native origin string must start with """
                                    & Prefix_Native
                                    & """ but found: " & Str);
            else
               Pkg := Packaged_As (Utils.Tail (Str, ':'));
            end if;

            return Outcome_Success;
         end;
      end Package_From_String;

      ---------------
      -- From_Case --
      ---------------

      function From_Case (Case_From : TOML.TOML_Value) return Outcome is
         Cases  : TOML.TOML_Value;
         Var    : Requisites.Platform.Case_Loader_Keys;
         use all type Requisites.Platform.Case_Loader_Keys;
         Loader : Interfaces.TOML_Loader;
         Result : constant Outcome := Requisites.Platform.Get_Case
           (Parent   => Case_From,
            Context  => From.Descend ("conditional"),
            Cases    => Cases,
            Variable => Var,
            Loader   => Loader);
      begin
         if not Result.Success then
            return Result;
         end if;

         --  Origins are (currently) special in that the only accepted var
         --  is a distribution, so check that:
         if Var /= Distribution then
            return From.Failure
              ("origins can only be distribution-specific");
         end if;

         --  Get an array of values that will be turned into origins:
         declare
            Distro_Origins : Requisites.Platform.Distro_Cases.TOML_Array;
            Result         : constant Outcome :=
                Requisites.Platform.Distro_Cases.Load_Cases
                  (From  => TOML_Adapters.From (Cases, "distribution", From),
                   Cases => Distro_Origins);
         begin
            if not Result.Success then
               return Result;
            end if;

            --  LOAD EACH ORIGIN
            This := New_Native ((others => Unavailable));

            for Distro in Distro_Origins'Range loop
               declare
                  Result : constant Outcome :=
                             Package_From_String
                               (Distro_Origins (Distro),
                                This.Data.Packages (Distro));
               begin
                  if not Result.Success then
                     return Result;
                  end if;
               end;
            end loop;

            return Outcome_Success;
         end;
      end From_Case;

      Value : TOML.TOML_Value;
   begin
      if not From.Pop (TOML_Keys.Origin, Value) then
         return From.Failure ("mandatory origin missing");
      elsif Value.Kind = TOML.TOML_Table then
         --  A table: a case origin.
         return From_Case (Value);
      elsif Value.Kind = TOML.TOML_String then
         --  Plain string: regular origin
         return From_String (This,
                             Value.As_String,
                             From);
      else
         return From.Failure ("expected string description or case table");
      end if;
   end From_TOML;

   -------------
   -- To_TOML --
   -------------

   overriding function To_TOML (This : Origin) return TOML.TOML_Value is
      use TOML_Adapters;
      Table : constant TOML.TOML_Value := TOML.Create_Table;
   begin
      case This.Kind is
         when Filesystem =>
            Table.Set (TOML_Keys.Origin, +("file://" & This.Path));
         when VCS_Kinds =>
            Table.Set (TOML_Keys.Origin, +(Prefixes (This.Kind).all &
                         This.URL & "@" & This.Commit));
         when Native =>
            raise Program_Error
              with "native packages do not need to be exported";
         when Source_Archive =>
            Table.Set (TOML_Keys.Origin, +This.Archive_URL);
            if This.Archive_Name /= "" then
               Table.Set (TOML_Keys.Archive_Name, +This.Archive_Name);
            end if;
      end case;

      return Table;
   end To_TOML;

end Alire.Origins;
