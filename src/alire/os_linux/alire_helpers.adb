with Alire.OS_Lib.Subprocess;

package body Alire_Helpers is

   function Download_Archive (Archive_URL  : String;
                              Archive_File : String) return Integer
   is
      --  Download URL resource using wget
   begin
      return Alire.OS_Lib.Subprocess.Spawn
        ("wget", Archive_URL & " -q -O " & Archive_File);
   end Download_Archive;

end Alire_Helpers;
