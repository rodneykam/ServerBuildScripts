Function LogWrite  {
Param ([string]$logstring)

Add-content $Logfile -value $logstring
}