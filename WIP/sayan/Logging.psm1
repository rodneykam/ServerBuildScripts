function Write-Log
{
<#
  .SYNOPSIS
     Write a message to the Log file.
  .DESCRIPTION
    Logs a message to the logfile if the severity is higher than or equal to $LogLevel.
	Default severity level is information.
  .PARAMETER scriptName
     Name of the script/program to be used with logged messages.
     Use the $MSGTYPE_XXXX constants.
  .PARAMETER logName
     Full Name of the file where messages will be written.
  .PARAMETER severity
     The severity of the message.  Can be Information, Warning, or Error.
     Use the $MSGTYPE_XXXX constants.
  .PARAMETER message
     A string to be printed to the log.

  .EXAMPLE
     Write-Log $MSGTYPE_ERROR "Something has gone terribly wrong!"
#>

    [CmdletBinding()]
    #[Alias('wl')]
    [OutputType([int])]
    Param
    (
        # The string to be written to the log.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias("LogContent")]
        [string]$Message,

        # The path to the log file.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [Alias('LogPath')]
        [string]$Path="E:\Buildout\Logs",

        [Parameter(Mandatory=$false,
                    ValueFromPipelineByPropertyName=$true,
                    Position=3)]
        [ValidateSet("Error","Warn","Info")]
        [string]$Level="Info",

        [Parameter(Mandatory=$false)]
        [switch]$NoClobber
    )

    Begin
    {
    }
    Process
    {
        
        if ((Test-Path $Path) -AND $NoClobber) 
        {
            Write-Warning "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."
            Return
        }

        # If attempting to write to a log file in a folder/path that doesn't exist
        # to create the file include path.
        if (!(Test-Path $Path)) 
            {
            Write-Verbose "Creating $Path."
            $NewLogFile = New-Item $Path -Force -ItemType File
            }
       

        # Now do the logging and additional output based on $Level
        switch ($Level) 
            {
            'Error' 
                {
                Write-Error $Message
                Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") ERROR: $Message" | Out-File -FilePath $Path -Append
                }
            'Warn' 
                {
                Write-Warning $Message
                Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") WARNING: $Message" | Out-File -FilePath $Path -Append
                }
            'Info' 
                {
                Write-Host $Message
                Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") INFO: $Message" | Out-File -FilePath $Path -Append
                }
            }
    }
    End
    {}
}
Export-ModuleMember -function Write-Log