Function LogWrite  {

Param ([string]$logstring)

Add-content $Logfile -value $logstring
# 
if ((Test-Path $Path) -AND $NoClobber) 
    {       
            LogWrite "Log file $Path already exists" 
            LogWrite "Creating new log file"
            $NewLogFile = New-Item $Path -Force -ItemType File 
            Return 
            } 
elseif (!(Test-Path $Path)) { 
            LogWrite "Creating $Path." 
            $NewLogFile = New-Item $Path -Force -ItemType File 
            }   
    }