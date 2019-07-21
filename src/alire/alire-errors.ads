with Ada.Exceptions;

package Alire.Errors with Preelaborate is

   --  Supporting types to ensure an exception message doesn't get truncated.
   --  Intended usage is to raise with a Set:
   --    raise My_Exception with Errors.Set ("The sky is falling!");
   --  And later report it with Get:
   --    when E : My_Exception =>
   --       Put_Line (Errors.Get (E));

   subtype Unique_Id is String;

   function Set (Text : String) return Unique_Id;
   --  Stores an error and receives a unique code to later retrieve it.

   function Get (Id : Unique_Id) return String;
   --  Direct retrieval from Id. The stored error is cleared.

   function Get (Ex : Ada.Exceptions.Exception_Occurrence) return String;
   --  Returns the stored error if it exists, or defaults to Exception_Message.
   --  The stored error is cleared.

end Alire.Errors;
