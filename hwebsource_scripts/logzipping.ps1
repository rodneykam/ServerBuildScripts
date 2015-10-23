start-transcript -path E:\Scripts\transcript0.txt

#[System.Reflection.Assembly]::LoadFile("E:\scripts\Ionic.Zip.Reduced.dll") | Out-Null 
[System.Reflection.Assembly]::LoadFile("E:\Scripts\Ionic.Zip.dll") | Out-Null 
$root= "D:\W3SVC503"


$monthname=@{"1"="January";
			 "2"="February";
			 "3"="March";
			 "4"="April";
			 "5"="May";
			 "6"="June";
			 "7"="July";
			 "8"="August";
			 "9"="September";
			 "10"="October";
			 "11"="November";
			 "12"="December"
			}
			
Function RemovefilesoftheMonth
{
	param
	(
	$files= @(),
	$zipFile
	)
	
	foreach ($file in $files)
	{
		$finalfile =$root+"\"+$file
		try{
		
			$c=$zipFile.AddFile($finalfile,"")
			Write-Host " $finalfile has been added to the zip" 
		}
		catch
		{
			if (($_.Exception.ToString()) -match "same key has already been added")
			{
				Write-Host "$finalfile has been added to the zip, so it is going to deleted"
				
				Remove-Item $finalfile -Force
			}
			else
			{
				$_.Exception.ToString()
			}
	
		}
	}
}


Function Zip_FromRoot
{
	param($root)

	$Contents = gci $root |sort -property LastWriteTime |where {$_.extension -ne ".zip"}
	$monthyearcount
	$montharray=@()

	
	foreach ($content in $contents)
	{
	  if($content.extension -ne "")
		{	
			$month=$content.Lastwritetime.month
			$year=$content.Lastwritetime.year

			$write_month=$monthname."$month" +"_"+ $year

			if ($monthyearcount -ne $write_month)
			{	
				if($montharray.count -ge 1)
				{	
					$monthyearcountzip = $root+"\"+$monthyearcount+ ".zip"
				
					if (!(Test-Path $monthyearcountzip))
					{
						new-item $monthyearcountzip -ItemType file
						$zipFile = new-object Ionic.Zip.ZipFile
					}
					else
					{
					
						$zipFile=[Ionic.Zip.ZipFile]::Read($monthyearcountzip)
					}
					
					zipping_files $montharray	$zipFile
					
					try{
						$zipFile.save($monthyearcountzip)
						$monthyearcountzip
						RemovefilesoftheMonth $montharray $zipFile
						}
					catch
						{
							exit
						}
						
							
				}
				
				$monthyearcount=$write_month
				$montharray = @()	
				$montharray += $content
			}
			else
			{
				$montharray+=$content
			}				
		}

	}

}

function zipping_files()
{
	param
	(
	$files= @(),
	$zipFile
	)
	
	
	
	foreach ($file in $files)
	{
		$finalfile =$root+"\"+$file
		try{
		
			$c=$zipFile.AddFile($finalfile,"")
			Write-Host " $finalfile has been added to the zip" 
		}
		catch
		{
			if (($_.Exception.ToString()) -match "same key has already been added")
			{
				Write-Host "$finalfile already exists"
				
				#Remove-Item $finalfile -Force
			}
			else
			{
				$_.Exception.ToString()
			}
	
		}
	}


	

}

$folders= gci $root -recurse |where {$_.extension -eq ""}
if($folders.count -ge 1)
{
	foreach ($folder in $folders)
	{
	$subroot  = $folder.Fullname
	$subroot
	Zip_FromRoot $subroot 
#	ZipAllContentsofFolder $subroot 
	}
}
else
{
	Zip_FromRoot $root
#	ZipAllContentsofFolder  $root
}

#Zip_FromRoot $folder.Fullname
<#
$zipFilename = "E:\Logs\STAGWEB01\IIS\app.zip"
$zipFile = new-object Ionic.Zip.ZipFile;
$zipFile.AddDirectory("E:\Logs\STAGWEB01\IIS\app","app")
$zipFile.save($zipFilename)
#>

stop-transcript