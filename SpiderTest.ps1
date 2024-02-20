If (-not (Get-Module -ErrorAction Ignore -ListAvailable PSParseHTML)) {
  Write-Verbose "Installing PSParseHTML module for the current user..."
  Install-Module -Scope CurrentUser PSParseHTML -ErrorAction Stop
}

$uri = [System.uri]"https://www.linuxfromscratch.org/blfs/view/stable-systemd/longindex.html"
if([System.IO.File]::Exists("$(Get-Location)\cache\$($uri.Segments[-1])"))
{
	Write-Host "Using Cache"
	$file = "$($(Get-Location).ToString())\cache\$($uri.Segments[-1])"
	$request = Get-Content $file -raw |ConvertFrom-HTML -Engine AngleSharp
} else {
	Write-Host "Downloading $uri to file:///$($(Get-Location).ToString().Replace('\','/'))/cache/$($uri.Segments[-1])"
	$request = ConvertFrom-HTMl -Engine AngleSharp -Url $uri
	$request.Content|Out-file -FilePath "$(Get-Location)\cache\$($uri.Segments[-1])"

}
if([System.IO.File]::Exists("$(Get-Location)\packages.log"))
{
	Remove-Item "$(Get-Location)\packages.log"
}
$file=[System.IO.File]::Create("$(Get-Location)\packages.log")
$file.Close();
$Tags=@{}
$count=0;

$h2 = $request.querySelector("H2")
foreach ( $h in $h2)
{
	if ( $h.TextContent.Trim() -eq "Packages")
	{
		if ( $h.NextElementSibling.TagName -eq "UL")
		{
			$links = $h.NextElementSibling.QuerySelectorAll("A")
		}

	}
}

foreach ( $link in $links )
{
	$count++;
	$progress= @{
		Activity ="Updating $count of $($links.Length)"
		Status = "Progress"
		PercentComplete = ($count/$links.Length)*100
		CurrentOperation = "Main List"
	}
	Write-Progress @progress
	Start-Sleep -Milliseconds 250
	if ( $link.Text -eq "description" -or $link.Text -eq "Home" )
	{
	}
	elseif ( $link.Text -eq "Prev" -or $link.Text -eq "Next")
	{
	}
	else
	{
		$tagName=$link.Text.Trim().ToLower().Replace("`r","").Replace("`n","") -replace " +", " "
		if($tagName -eq "" )
		{
			Write-Host "Skiping Null Link $($link.Text)"
			continue
		} elseif($Tags.Keys -contains $tagName){
			Write-Host "Skipping Duplicate: $tagName "
		} else{
			
			$linktext = "https://www.linuxfromscratch.org/blfs/view/stable-systemd$($([uri]$link.href).AbsolutePath)"
			$Tags.Add($tagName.ToLower(),$linktext)
			$tagName
			$finalLink=$link.Text.Trim().Replace("`r","").Replace("`n","") -replace " +", " "
			"`"$finalLink`" $($linktext)"|Out-File -literalpath "$(Get-Location)\packages.log" -append -Encoding utf8
		}
		$downloadLinks=$null
		$patches=$null
	}
}
