
$uri = [System.uri]"https://www.linuxfromscratch.org/blfs/view/stable-systemd/longindex.html"
if([System.IO.File]::Exists("$(Get-Location)\cache\$($uri.Segments[-1])"))
{
	Write-Host "Using Cache"
	 $uri = [System.Uri]::new("file:\\\$(Get-Location)\cache\$($uri.Segments[-1])")
	$subrequest = invoke-webrequest -uri $uri
}
else
{
	Write-Host "Downloading $uri to $(Get-Location)\cache\$($uri.Segments[-1])"
	$request = invoke-webrequest -uri $uri
	$request.Content|Out-file -FilePath "$(Get-Location)\cache\$($uri.Segments[-1])"

}

$links = $result.links
$count=0;
foreach ( $link in $result.links )
{
	$count++;
	$progress= @{
		Activity ="Updating $count of $($result.links.Count)"
		Status = "Progress"
		PercentComplete = ($count/$result.links.Count)*100
		CurrentOperation = "Main List"
	}
	Write-Progress @progress
	Start-Sleep -Milliseconds 250
	if ( $link.innerText -eq "description" -or $link.innerText -eq "Home" )
	{
	}
	elseif ( $link.innerText -eq "Prev" -or $link.innerTxt -eq "Next")
	{
	}
	else
	{
		$uri = [System.uri]"https://www.linuxfromscratch.org/blfs/view/stable-systemd/$($link.href)";
		if([System.IO.File]::Exists("$(Get-Location)\cache\$($uri.Segments[-1])"))
		{
			Write-Host "Using Cache"
			$uri = [System.Uri]::new("file:\\\$(Get-Location)\cache\$($uri.Segments[-1])")
			$subrequest = invoke-webrequest -uri $uri
		}
		else
		{
			Write-Host "Downloading $uri to $(Get-Location)\cache\$($uri.Segments[-1])"
			$request = invoke-webrequest -uri $uri
			$request.Content|Out-file -FilePath "$(Get-Location)\cache\$($uri.Segments[-1])"

		}

		$patches = New-Object System.Collections.Generic.List[string]
		$downloadLinks= New-Object System.Collections.Generic.List[string];
		$innerCount=0;
		foreach ( $sublink in $subrequest.links )
		{
			$innerCount++;
			$Innerprogress= @{
				ID=1
				Activity ="Updating $innerCount of $($subrequest.links.Count)"
				Status = "Sub Page Progress"
				PercentComplete = ($innerCount/$subrequest.links.Count)*100
				CurrentOperation = "Sub List - $($link.innerText)"
			}
			Write-Progress @Innerprogress
			Start-Sleep -Milliseconds 50
			if ( $sublink.tagName -eq "A" -and 
				( $sublink.href.ToString().StartsWith("http://" ) -or
				 $sublink.href.ToString().StartsWith("https://"))
			)
			{ 
				if ( $sublink.href.ToString().EndsWith(".patch"))
				{ 
					$patches.Add($sublink.href)
				}
				elseif ( 
					( $sublink.href.ToString().EndsWith(".tar.xz") -or
					$sublink.href.ToString().EndsWith(".tar.gz") -or
					$sublink.href.ToString().EndsWith(".tar.bz2") -or
					$sublink.href.ToString().EndsWith(".zip") ) -and
					$sublink.href.ToString().Contains($link.href)
				)
				{
					$downloadLinks.Add($sublink.href);
				}
			}
			else
			{
			
			}
	
		}

		"$($link.innerText) https://www.linuxfromscratch.org/blfs/view/stable-systemd/$($link.href) $([string]::Join(",",$downloadLinks)) $([string]::Join(",",$patches))" |Out-File -literalpath packages.log -append
		$downloadLinks=$null
		$patches=$null
	}
}
