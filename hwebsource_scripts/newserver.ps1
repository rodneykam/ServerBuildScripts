param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)

.\permtest.ps1 -EnvironmentConfig $EnvironmentConfig -MachineConfig $MachineConfig

.\metascan.ps1 -MachineConfig $MachineConfig

###### Deleting Files #######
write-host -ForegroundColor yellow "`n`n`n Removing old Directory Structure  `n"

$check = ("E:\InteropApplications","E:\RelayHealth","E:\Corpsite","E:\Config","E:\build","E:\healthvault" )

foreach ($c in $check)
{
	$c1 = test-path "$c"
	if ( $c1 -eq "True") 
	{
		Remove-Item $c -recurse -force 
	}
}	


$source=@("c:\hwebsource\dirstruct")
$dest =@("e:\")
$exclude =@("")

$server = [String]$EnvironmentConfig.PatientEducation

function createcopy($source,$dest,$exclude)
{	
	$items = Get-ChildItem $source -Recurse -Exclude $exclude
	foreach($item in $items)
		{ 
	      $target = Join-Path $dest $item.FullName.Substring($source.length)
	      if( -not( $item.PSIsContainer -and (Test-Path($target)))) 
  		    {
	         Copy-Item -Path $item.FullName -Destination $target
    	    }
		}
}

for($i=1; $i -le $source.count; $i++)
{
 createcopy $source[$i-1] $dest[$i-1] $exclude[$i-1]
}


if (test-path "E:\config\tools_encryption")
{
pushd E:\config\tools_encryption
.\RelayHealth.EncryptDecryptConfig.exe e
popd
}




