<#

.SYNOPSIS
 
    Export-MsolGroupMembers.ps1 - Creates a CSV on the desktop of groups and members
 
.DESCRIPTION

    Author: csatswo

    This script will output a list of the groups and members in the terminal and will save a CSV on the desktop.
    
.LINK

    Github: https://github.com/csatswo/Export-MsolGroupMembers.ps1
 
.EXAMPLE 
    
    .\Export-MsolGroupMembers.ps1 -Path C:\Temp\members.csv -Filter "*sales*"

#>

# Script setup

Param(
    [Parameter(mandatory=$true)][String]$Path,
    [Parameter(mandatory=$true)][String]$Filter
)

$groups = @()
$group = @()
$members = @()
$member = @()

# Check for MSOnline module and install if missing

if (Get-Module -ListAvailable -Name MSOnline) {
    
    Write-Host "`nMSOnline module is installed" -ForegroundColor Cyan
    Import-Module MSOnline

} else {

    Write-Host "`nMSOnline module is not installed" -ForegroundColor Red
    Write-Host "`nInstalling module..." -ForegroundColor Cyan
    Install-Module MSOnline

}

# Connect to MSOnline

Import-Module MSOnline
Connect-MsolService
Add-Content -Path $path -Value "GroupName,MemberName,MemberEmailAddress"
$groups = Get-MsolGroup -All | Where-Object {$_.DisplayName -like $filter}
foreach ($group in $groups) {
    $groupId = $group.ObjectId
    $groupName = $group.DisplayName
    $members = Get-MsolGroupMember -GroupObjectId $groupId
    foreach ($member in $members) {
        $memberName = $member.DisplayName
        $memberNameQuotes = "`"$memberName`""
        $memberEmail = $member.EmailAddress
        Write-Host ($groupName,$memberNameQuotes,$memberEmail) -Separator ","
        Add-Content -Path $path -Value "$groupName,$memberNameQuotes,$memberEmail"
        }
    }

Write-Host ""`nExport saved at" $path" -ForegroundColor Cyan
