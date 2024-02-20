if([System.IO.File]::Exists("$(Get-Location)\UniqueTags.log"))
{
	Remove-Item "$(Get-Location)\UniqueTags.Log"
}
[System.IO.File]::Create("$(Get-Location)\UniqueTags.Log");
$items = Get-Content "$(Get-Location)\UniqueLinks.log" -delimiter "`r`n" ;
foreach ( $item in $items)
{
	Write-Host "Searching For:$item"
	$packageItems = Get-Content .\packages.log -delimiter "`r`n" ;
	foreach ( $packageItem in $packageItems )
	{
		if($packageItem -match "$item")
		{
			Write-Host "Match";
			$lineitems = $packageItem| Select-String -Pattern "^(`"[^`"]*`"|[^ ]*) (.*)$";	
			$lineitems;
			$object = [PSCustomObject]@{ 
				Name=$lineitems.Matches[0].Groups[1].Value
				Link=$lineitems.Matches[0].Groups[2].Value
			}
			$object.Name|Out-File -FilePath "UniqueTags.Log" -append
		}
	}
}
