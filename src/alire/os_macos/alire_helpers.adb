with Alire.OS_Lib.Subprocess;

package body Alire_Helpers is

   function Download_Archive (Archive_URL  : String;
                              Archive_File : String) return Integer
   is
      --  Download URL resource using curl
   begin
      return Alire.OS_Lib.Subprocess.Spawn
        ("curl", "--silent --output " & Archive_File & " " & Archive_URL);
   end Download_Archive;

end Alire_Helpers;
