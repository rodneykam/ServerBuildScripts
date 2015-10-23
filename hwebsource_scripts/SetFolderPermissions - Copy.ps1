param (
[string]$environment,

)

if ([string]::IsNullOrEmpty($Environment) )
{
	$environment=$Config.Environment
}

if ([string]::IsNullOrEmpty($Environment) )
{
	throw New-Object System.ArgumentNullException " $Environment Environment value is Null "
}
	
$Error.Clear()


Function EnvironmentParser
{
	param (
		$filepath= $(throw "You must specify a path."),
		$nodequalifier= $(throw "You must specify a xmltag in order to process the xml.")
        	)
	
	$configParams = [xml] (gc $filepath) 
	if ( $error ){
	write-host -Foregroundcolor Yellow " Config File Corrupted `r `n $($error[0])"
	exit
	}
	

	$configServerParams = $configParams.Environments.Environment | ?{[string]$_.name -eq $nodequalifier}
	if ( !$configServerParams ){
	write-host -Foregroundcolor Yellow " Paramater $configParams given doesnt not comply with the config `r `n $($error[0])"
	exit
	}

	return $configServerParams

}


$environmentconfig= EnvironmentParser -filepath "Environmentdomain.config" -nodequalifier $Environment
$environmentprefix= $environmentconfig.prefix
$environmentdomain= $environmentconfig.domain

$environmentprefix

$environmentdomain

