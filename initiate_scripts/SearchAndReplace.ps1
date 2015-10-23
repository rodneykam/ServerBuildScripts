param	(
			[string]$file,
			[string]$oldValue,
			[string]$newValue = ""
		)
(Get-Content $file) | Foreach-Object {$_ -replace $oldValue, $newValue} | Set-Content $file