
$items = Get-Content "$(Get-Location)\UniqueLinks.log" -delimiter "`r`n" -encoding utf8;
foreach ( $item in $items)
{
	Write-Host "Searching For:$item"
	$packageItems = Get-Content "$(Get-Location)\packages.log" -delimiter "`r`n" -encoding utf8 ;
	foreach ( $packageItem in $packageItems ){
		if($packageItem -match "$item"){
			$foundRequired=$false;
			$foundRecommended=$false;
			$foundOptional=$false;
			$required=[System.Collections.ArrayList]::new();
			$recommended=[System.Collections.ArrayList]::new();
			$optional=[System.Collections.ArrayList]::new();
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
							if($section -ilike "*dependencies*") { Write-Host "Found Dependencies"
								$h4 = $hh.Parent.QuerySelectorAll("H4")
								$h4.Count
								foreach ( $hhh in $h4 )
								{
									
									$sectiontitle=$hhh.TextContent.Trim().ToLower().Replace("`r","").Replace("`n","") -replace " +"," "
									if( $sectiontitle -eq "required")
									{
										Write-Host "Found Required"
										$foundRequired = $true;
										$externalLinks= $hhh.NextElementSibling.QuerySelectorAll("A")
										foreach ( $externalLink in $externalLinks){
											Write-Host $externalLink.href
											$required.Add($externalLink.href)
										}
									}
									elseif ( $sectiontitle -eq "recommended" )
									{
										Write-Host "Found Recommended"
										$foundRecommended = $true;
										$externalLinks= $hhh.NextElementSibling.QuerySelectorAll("A")
										foreach ( $externalLink in $externalLinks){
											Write-Host $externalLink.href
											$recommended.Add($externalLink.href)
										}
									} 
									elseif ( $sectiontitle -eq "optional" )
									{
										Write-Host "Found Optional"
										$foundOptional = $true;
										$externalLinks= $hhh.NextElementSibling.QuerySelectorAll("A")
										foreach ( $externalLink in $externalLinks){
											Write-Host $externalLink.href
											$optional.Add($externalLink.href)
										}
									} 
								}
							}
							else
							{
								Write-Host "Section: $section";
							}
						}
					}else{
						Write-Host "Failed to find the Main H tag: $file"
					}
				}
			}else{
				Write-Host "Failed to find Cache: $file"
			}

			if ( $foundRequired ){
				if([System.IO.File]::Exists("$(Get-Location)\TagsToDownload.log") -eq $false)
				{
					[System.IO.File]::Create("$(Get-Location)\dependencies\$($object.Name.Replace('`"','')).log");
				}
				foreach ( $reqLink in $required)
				{
					
					$uri = [uri]$reqLink;
					if( $reqLink.StartsWith("http"))
					{
						$linktext = $reqLink;
					}
					else
					{
						$linktext = "https://www.linuxfromscratch.org/blfs/view/stable-systemd$($uri.AbsolutePath)"
					}
					
					"`"$($object.Name.Replace('`"',''))-Required`" $linktext" |
					Out-File -FilePath "$(Get-Location)\dependencies\$($object.Name.Replace('`"','')).log" -Encoding utf8 -Append
				}
			}
			if ( $foundRecommeded ){
				if([System.IO.File]::Exists("$(Get-Location)\TagsToDownload.log") -eq $false)
				{
					[System.IO.File]::Create("$(Get-Location)\dependencies\$($object.Name.Replace('`"','')).log");
				}
				foreach ( $recLink in $recommended)
				{
					$uri = [uri]$recLink;
					if( $recLink.StartsWith("http"))
					{
						$linktext = $recLink;
					}
					else
					{
						$linktext = "https://www.linuxfromscratch.org/blfs/view/stable-systemd$($uri.AbsolutePath)"
					}
					"`"$($object.Name.Replace('`"',''))-Recommended`" $linktext" |
					Out-File -FilePath "$(Get-Location)\dependencies\$($object.Name.Replace('`"','')).log" -Encoding utf8 -Append
				}
			}
			if ( $foundOptional ){
				if([System.IO.File]::Exists("$(Get-Location)\TagsToDownload.log") -eq $false)
				{
					[System.IO.File]::Create("$(Get-Location)\dependencies\$($object.Name.Replace('`"','')).log");
				}
				foreach ( $optLink in $recommended)
				{
					$uri = [uri]$optLink;
					if( $optLink.StartsWith("http"))
					{
						$linktext = $optLink;
					}
					else
					{
						$linktext = "https://www.linuxfromscratch.org/blfs/view/stable-systemd$($uri.AbsolutePath)"
					}
					"`"$($object.Name.Replace('`"',''))-Optional`" $linktext" |
					Out-File -FilePath "$(Get-Location)\dependencies\$($object.Name.Replace('`"','')).log" -Encoding utf8 -Append
				}
			}
		}
	}
}