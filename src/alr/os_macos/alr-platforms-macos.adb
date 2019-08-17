with Alire.Origins.Deployers;
with Alire.Platform;

with Alr.OS_Lib;
with Alr.Utils;

with Interfaces.C;

package body Alr.Platforms.MacOS is

   use Alr.OS_Lib.Paths;
   use Alr.Utils;

   ------------------
   -- Cache_Folder --
   ------------------

   overriding function Cache_Folder (This : MacOS_Variant) return String is
     (OS_Lib.Getenv ("XDG_CACHE_HOME",
                     Default => OS_Lib.Getenv ("HOME") / ".cache" / "alire"));

   -------------------
   -- Config_Folder --
   -------------------

   overriding function Config_Folder (This : MacOS_Variant) return String is
     (OS_Lib.Getenv ("XDG_CONFIG_HOME",
                     Default => OS_Lib.Getenv ("HOME") / ".config" / "alire"));

   ------------------
   -- Distribution --
   ------------------

   overriding function Distribution (This : MacOS_Variant)
                                     return Alire.Platforms.Distributions
   is (Alire.Platform.Distribution);

   --------------------
   -- Distro_Version --
   --------------------

   Cached_Version : Alire.Platforms.Versions;
   Version_Cached : Boolean := False;

   overriding function Distro_Version (This : MacOS_Variant)
                                       return Alire.Platforms.Versions
   is
      pragma Unreferenced (This);

      use Alire.Platforms;

      subtype MacOS_Version is Alire.Platforms.Versions
        range MacOS_10_12_Sierra .. MacOS_10_15_Catalina;

      Version_Names : constant array (MacOS_Version) of String (1 .. 5) :=
        (MacOS_10_12_Sierra      => "10.12",
         MacOS_10_13_High_Sierra => "10.13",
         MacOS_10_14_Mojave      => "10.14",
         MacOS_10_15_Catalina    => "10.15");

   begin
      if Version_Cached then
         return Cached_Version;
      else
         declare
            Release : String_Vector;
         begin
            OS_Lib.Spawn_And_Capture (Release, "sw_vers", "-productVersion");

            for Known in Version_Names'Range loop
               for Line of Release loop
                  if
                    Line'Length >= Version_Names (Known)'Length and then
                    Line (Version_Names (Known)'Range) = Version_Names (Known)
                  then
                     Version_Cached := True;
                     Cached_Version := Known;
                     return Known;
                  end if;
               end loop;
            end loop;

            Trace.Debug ("Found unsupported version: " & Release (1));

            Version_Cached := True;
            Cached_Version := Distro_Version_Unknown;
            return Distro_Version_Unknown;
         end;
      end if;
   end Distro_Version;

   --------------------
   -- Own_Executable --
   --------------------

   overriding
   function Own_Executable (This : MacOS_Variant) return String is
      pragma Unreferenced (This);
      use Interfaces;

      --------------------------
      -- _NSGetExecutablePath --
      --------------------------

      function NS_Get_Executable_Path (Buffer :    out C.char_array;
                                       Buflen : in out Interfaces.Unsigned_32)
                                      return C.int;
      pragma Import (C, NS_Get_Executable_Path, "_NSGetExecutablePath");

      --------------
      -- Realpath --
      --------------

      function Realpath (File_Name     :     C.char_array;
                         Absolute_Path : out C.char_array)
                        return C.int;
      pragma Import (C, Realpath, "realpath");

      NS_Get_Buffer : aliased C.char_array (1 .. 1024);
      NS_Get_Length : Unsigned_32 := NS_Get_Buffer'Length;
      NS_Get_Status : C.int;  pragma Unreferenced (NS_Get_Status);

      Realpath_Buffer : aliased C.char_array (1 .. 1024);
      Realpath_Status : C.int; pragma Unreferenced (Realpath_Status);
   begin

      NS_Get_Status   := NS_Get_Executable_Path (NS_Get_Buffer, NS_Get_Length);
      Realpath_Status := Realpath (NS_Get_Buffer, Realpath_Buffer);

      return C.To_Ada (Realpath_Buffer);
   end Own_Executable;

   ---------------------
   -- Package_Version --
   ---------------------

   function Package_Version (This   : MacOS_Variant;
                             Origin : Alire.Origins.Origin)
                             return String
   is (Alire.Origins.Deployers.New_Deployer (Origin).Native_Version);

end Alr.Platforms.MacOS;
