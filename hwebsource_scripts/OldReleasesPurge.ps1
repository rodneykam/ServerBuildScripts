param($retain=3)


function OldReleasesPurger($targetFolder,$retain) 
{
	$folders=Get-ChildItem $targetFolder | where {$_.name -match ("^ci\d+.\d+.\d+.\d+$") }
	$buildreleases=@{}
	foreach($folder in $folders)
	{
		$buildnumber=$folder.name.Substring(2).split(".")
		[decimal]$buildyear=$buildnumber[0]
		[decimal]$buildmonth=$buildnumber[1]
		[decimal]$buildweek=$buildnumber[2]
		$buildlength=($buildnumber[3]).length
		[decimal]$buildversion=$buildnumber[3]
		
		for ($i=0;$i -lt $buildlength;$i++)
		{
			
			$buildversion = $buildversion/10
		}
		
		$build=$buildyear*1000 + $buildmonth*10 + $buildweek+$buildversion
		$buildreleases.add($folder.name,$build)
	}

	$buildfolders=$buildreleases.GetEnumerator() | Sort-Object Value -descending
	$count=1
	foreach($buildfolder in $buildfolders)
	{
		
		
		if($count -gt $retain)
		{
			$count
			$buildfolder.name
			$foldertodelete=$targetFolder+"\"+$buildfolder.name
			Add-Content $checkpurgelog "$foldertodelete and it contents are going to be deleted "
			Remove-Item "$foldertodelete" -Force -Recurse
			Add-Content $checkpurgelog "$foldertodelete and it contents have been deleted "
			
		}
		$count++
	}

}


		$LogPath = "E:\RelayHealth\Logs\LoggingPush"
		
		$checkpurgelog = "$LogPath\buildpurge.txt"
		
		
		if (Test-Path $checkpurgelog)
		{
			Remove-Item $checkpurgelog
		}
		
		new-item  $checkpurgelog -type file -force
		
OldReleasesPurger "E:\RelayHealth\Releases" $retain
OldReleasesPurger "E:\InteropApplications\Releases" $retain
