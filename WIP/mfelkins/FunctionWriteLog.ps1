#############################################################################
##
## runBuildoutScripts
##   
## 10/2015, RelayHealth
## Mike Felkins
##
##############################################################################

<#
.SYNOPSIS
    Write-Log writes a message to a specified log file with the current time stamp.
        
.DESCRIPTION
    The Write-Log function is designed to add logging capability to other scripts.
    In addition to writing output and/or verbose you can write to a log file for
    later debugging.

    By default the function will create the path and file if it does not 
    exist.

.INPUTS
	sample input
	
.OUTPUTS
	sample output

.EXAMPLE
    Write-Log -Message "Log message" 
    Writes the message to c:\Logs\PowerShellLog.log
	
.EXAMPLE
    Write-Log -Message "Restarting Server" -Path c:\Logs\Scriptoutput.log
    Writes the content to the specified log file and creates the path and file specified. 
	
.EXAMPLE
    Write-Log -Message "Does not exist" -Path c:\Logs\Script.log -Level Error
    Writes the message to the specified log file as an error message, and writes the message to the error pipeline.
#>


function Write-Log
{
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
        [string]$Path="C:\Logs\PowerShellLog.log",

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
        elseif (!(Test-Path $Path)) 
            {
            Write-Verbose "Creating $Path."
            $NewLogFile = New-Item $Path -Force -ItemType File
            }

        else 
            {
            # Nothing to see here yet.
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