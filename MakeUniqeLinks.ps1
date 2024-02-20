
if([System.IO.File]::Exists("$(Get-Location)\UniqueLinks.log"))
{
	Remove-Item("$(Get-Location)\UniqueLinks.log")
}
[System.IO.File]::Create("$(Get-Location)\UniqueLinks.log");
Get-Content "$(Get-Location)\packages.log" -delimiter "`r`n" | 
Select-String -Pattern "^(`"[^`"]*`"|[^ ]*) (.*)$"|
foreach-Object{ [PSCustomObject]@{ Name=$_.Matches[0].Groups[1].Value; Link=$_.Matches[0].Groups[2].Value }} |
Foreach-Object{"$($_.Link)"} | 
Sort-Object -Unique|
Out-File -FilePath "$(Get-Location)\UniqueLinks.log" -Append