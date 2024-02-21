if([System.IO.File]::Exists("$(Get-Location)\TagsToDownload.log"))
{
	Remove-Item "$(Get-Location)\TagsToDownload.log"
}
[System.IO.File]::Create("$(Get-Location)\TagsToDownload.log");
$items = Get-Content "$(Get-Location)\UniqueLinks.log" -delimiter "`r`n" -encoding utf8;
foreach ( $item in $items)
{
	Write-Host "Searching For:$item"
	$packageItems = Get-Content "$(Get-Location)\packages.log" -delimiter "`r`n" -encoding utf8 ;
	foreach ( $packageItem in $packageItems ){
		if($packageItem -match "$item"){
			$foundPackageLink=$false;
			$foundPatch=$false;
			$downloads=[System.Collections.ArrayList]::new();
			$patches=[System.Collections.ArrayList]::new();
			Write-Host "Match";
			$lineitems = $packageItem| Select-String -Pattern "^(`"[^`"]*`"|[^ ]*) (.*)$";
			$lineitems;
			$object = [PSCustomObject]@{
				Name=$lineitems.Matches[0].Groups[1].Value
				Link=$lineitems.Matches[0].Groups[2].Value
			}
			$object.Name
			$uri = [uri]$object.Link
			$segment = $uri.Segments[-1];
			$file = "$(Get-Location)\cache\$($segment)";
			if([System.IO.File]::Exists($file)){
				Write-Host "Found Cache: $file"
				$request = $(Get-Content $file -raw |ConvertFrom-HTML -Engine AngleSharp);
				$h1=$request.QuerySelector("H1")
				foreach( $h in $h1 )
				{
					$title=$h.TextContent.Trim().ToLower().Replace("`r","").Replace("`n","") -replace " +"," "
					$title
					$search = $object.Name.Replace("`"","").Trim().ToLower()
					$search
					if($title -eq $search ){
						Write-Host "FOUND Main H tag: $file"
						$h3 = $h.NextElementSibling.QuerySelectorAll("H3")
						foreach($hh in $h3)
						{
							$section = $hh.TextContent.Trim().ToLower().Replace("`r","").Replace("`n","") -replace " +"," "
							if($section -eq "Package Information") { Write-Host "Found Package Information"
								$externalLinks= $hh.NextElementSibling.QuerySelectorAll("A")
								foreach ( $externalLink in $externalLinks){
									Write-Host $externalLink.href
									$foundPackageLink=$true;
									$downloads.Add($externalLink.href)
								}
							}elseif($section -eq "Additional Downloads"){
								Write-Host "Found Additional Downloads"
								$externalLinks=$hh.NextElementSibling.QuerySelectorAll("A")
								foreach($externalLink in $externalLinks){
									Write-Host $externalLink.href
									$foundPatch=$true;
									$patches.Add($externalLink.href)
								}
							}else{ Write-Host "Other: $section" }
						}
					}else{
						Write-Host "Failed to find the Main H tag: $file"
					}
				}
			}else{
				Write-Host "Failed to find Cache: $file"
			}

			if ( $foundPackageLink ){
				if ( $foundPatch ){
					"`$($object.Name)` $item $(Join-String -InputObject $downloads -Separator ',') $(Join-String -InputObject $patches -Separator ',')" |Out-File -FilePath "$(Get-Location)\TagsToDownload.log" -Encoding utf8 -Append
				}
				else
				{
					"`$($object.Name)` $item $(Join-String -InputObject $downloads -Separator ",")"|Out-File -FilePath "$(Get-Location)\TagsToDownload.log" -Encoding utf8 -Append
				}
			}
			else
			{
				Write-Host "Failed to find the download link"
			}
		}
	}
}