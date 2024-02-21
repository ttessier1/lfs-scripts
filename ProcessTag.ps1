if([System.IO.File]::Exists("$(Get-Location)\TagsToDownload.log"))
{
	Remove-Item "$(Get-Location)\TagsToDownload.log"
}
[System.IO.File]::Create("$(Get-Location)\TagsToDownload.log");
$items = Get-Content "$(Get-Location)\UniqueLinks.log" -delimiter "`r`n" -encoding utf8 -head 1;
foreach ( $item in $items){
	Write-Host "Searching For:$item"
	$packageItems = Get-Content "$(Get-Location)\packages.log" -delimiter "`r`n" -encoding utf8 ;
	foreach ( $packageItem in $packageItems ){
		if($packageItem -match "$item"){
			Write-Host "Match";
			$lineitems = $packageItem| Select-String -Pattern "^(`"[^`"]*`"|[^ ]*) (.*)$";	
			$lineitems;
			$object = [PSCustomObject]@{ 
				Name=$lineitems.Matches[0].Groups[1].Value
				Link=$lineitems.Matches[0].Groups[2].Value
			}
			$object.Name
			$uri = [uri]$object.Link
			$file = "$(Get-Location)\cache\$($uri.Segments[-1])";
			if[System.IO.File]::Exists($file)){
				$request = $(Get-Content $file -raw |ConvertFrom-HTML -Engine AngleSharp);

			}
		}
	}
}
