<#
.SYNOPSIS
    Bulk-creates lab users in Microsoft Entra ID from a CSV file using Microsoft Graph PowerShell.

.DESCRIPTION
    Part of the Northshore Health Clinic Intune lab.
    Reads users.csv, skips any user that already exists, and creates the rest with
    department, job title and usage location set. Department drives the dynamic groups,
    and usage location is required before a licence can be assigned.

.PARAMETER CsvPath
    Path to the CSV file. Defaults to users.csv in the same folder as this script.

.PARAMETER ForcePasswordChange
    If set, users must change their password at first sign-in (real-world default).
    Leave it off in the lab so test sign-ins are quicker.

.EXAMPLE
    ./New-LabUsers.ps1

.EXAMPLE
    ./New-LabUsers.ps1 -CsvPath ./test.csv -ForcePasswordChange

.NOTES
    Requires: PowerShell 7+, modules Microsoft.Graph.Authentication and Microsoft.Graph.Users
    Permissions: User.ReadWrite.All (delegated, signed in as an admin)
#>

[CmdletBinding()]
param(
    [string]$CsvPath = (Join-Path $PSScriptRoot 'users.csv'),
    [switch]$ForcePasswordChange
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $CsvPath)) {
    throw "CSV file not found: $CsvPath"
}
$users = Import-Csv -Path $CsvPath
Write-Host "Loaded $($users.Count) users from $CsvPath" -ForegroundColor Cyan

# Same initial password for every lab user, typed in at runtime
$securePassword = Read-Host -Prompt 'Enter the initial password for all lab users' -AsSecureString
$plainPassword  = [System.Net.NetworkCredential]::new('', $securePassword).Password

Connect-MgGraph -Scopes 'User.ReadWrite.All' -NoWelcome
$context = Get-MgContext
Write-Host "Connected to tenant $($context.TenantId) as $($context.Account)" -ForegroundColor Cyan

$results = foreach ($u in $users) {
    $upn = $u.UserPrincipalName.Trim()

    $existing = Get-MgUser -Filter "userPrincipalName eq '$upn'" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "SKIP    $upn (already exists)" -ForegroundColor Yellow
        [pscustomobject]@{ User = $upn; Department = $u.Department; Result = 'Skipped (exists)' }
        continue
    }

    $params = @{
        AccountEnabled    = $true
        DisplayName       = $u.DisplayName
        GivenName         = $u.FirstName
        Surname           = $u.LastName
        UserPrincipalName = $upn
        MailNickname      = ($upn -split '@')[0] -replace '[^a-zA-Z0-9]', ''
        Department        = $u.Department
        JobTitle          = $u.JobTitle
        UsageLocation     = $u.UsageLocation
        PasswordProfile   = @{
            Password                      = $plainPassword
            ForceChangePasswordNextSignIn = [bool]$ForcePasswordChange
        }
    }

    try {
        New-MgUser -BodyParameter $params | Out-Null
        Write-Host "CREATED $upn ($($u.Department) - $($u.JobTitle))" -ForegroundColor Green
        [pscustomobject]@{ User = $upn; Department = $u.Department; Result = 'Created' }
    }
    catch {
        Write-Host "FAILED  $upn : $($_.Exception.Message)" -ForegroundColor Red
        [pscustomobject]@{ User = $upn; Department = $u.Department; Result = "Failed: $($_.Exception.Message)" }
    }
}

Write-Host ''
$results | Format-Table -AutoSize
$created = ($results | Where-Object Result -eq 'Created').Count
Write-Host "Done: $created created, $($results.Count - $created) skipped or failed." -ForegroundColor Cyan

Disconnect-MgGraph | Out-Null
