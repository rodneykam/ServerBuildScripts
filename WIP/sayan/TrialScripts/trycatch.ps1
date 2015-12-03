try
{
    <#
        Add dangerous code here that might produce exceptions.
        Place as many code statements as needed here.
        Non-terminating errors must have error action preference set to Stop to be caught.
    #>
 
    write-host "Attempting dangerous operation"
    $content = get-content -Path "C:\SomeFolder\This_File_Might_Not_Exist.txt" -ErrorAction Stop
    write-host -ForegroundColor Green "Suck cess"
}
catch
{
    <#
        You can have multiple catch blocks (for different exceptions), or one single catch.
        The last error record is available inside the catch block under the $_ variable.
        Code inside this block is used for error handling. Examples include logging an error,
        sending an email, writing to the event log, performing a recovery action, etc.
        In this example I'm just printing the exception type and message to the screen.
    #>
 
    write-host "Caught an exception:" -ForegroundColor Red
    write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
    write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
    #write-host "Stack Trace: $($_.Exception.)"
}