# Microsoft Intune Endpoint Management Lab

Hands-on lab that builds endpoint management for a fictional 10-person health clinic, **Northshore Health Clinic**, using Microsoft Intune, Microsoft Entra ID and Windows Autopilot. Built while preparing for the **Microsoft 365 Certified: Endpoint Administrator Associate (MD-102)** exam.

## Scenario

Northshore Health Clinic is a made-up clinic with 10 staff across Clinical, Reception and IT. Everything runs in a Microsoft 365 trial tenant licensed with Intune Plan 1 and Enterprise Mobility + Security E5 (which includes Entra ID P1/P2). The test device is a Windows 11 Enterprise VM.

## Lab environment

- Admin workstation: macOS with PowerShell 7 and Microsoft Graph PowerShell
- Hypervisor: Oracle VirtualBox 7 on a Windows laptop
- Test device: `LAB-WIN-01`, a Windows 11 Enterprise VM (EFI, TPM 2.0, unique serial for Autopilot) with a clean OOBE snapshot to roll back to

## Contents

- [Identity and enrollment](phase-1-identity/): tenant setup, users and groups, group-based licensing, admin roles with a custom Intune role, Entra device settings, Intune enrollment settings, Windows Hello for Business and Windows Autopilot
- [Device management](device-management/): configuration profile, compliance, BitLocker, Windows LAPS and update rings

## Scripts

- [`New-LabUsers.ps1`](phase-1-identity/scripts/New-LabUsers.ps1) creates the lab users in Entra ID from a CSV using Microsoft Graph. It skips users that already exist, so it's safe to re-run.

## Security notes

- No passwords, secrets, tenant IDs or personal information are stored in this repository.
- Screenshots are redacted before being committed.
- All users and the company are fictional.
