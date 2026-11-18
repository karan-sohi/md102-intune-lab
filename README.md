# Microsoft Intune Endpoint Management Lab

Hands-on lab that builds endpoint management for a fictional 10-person health clinic, **Northshore Health Clinic**, using Microsoft Intune, Microsoft Entra ID and Windows Autopilot. Built while preparing for the **Microsoft 365 Certified: Endpoint Administrator Associate (MD-102)** exam.

> Status: in progress. Phase 1 underway.

## Scenario

Northshore Health Clinic is a made-up clinic with 10 staff across Clinical, Reception and IT. Everything runs in a Microsoft 365 trial tenant licensed with Intune Plan 1 and Enterprise Mobility + Security E5 (which includes Entra ID P1/P2). The devices are Windows 11 Enterprise VMs enrolled through Autopilot.

## Lab environment

- Admin workstation: macOS with PowerShell 7 and Microsoft Graph PowerShell
- Hypervisor: Oracle VirtualBox 7 on a Windows laptop
- Test device: `LAB-WIN-01`, a Windows 11 Enterprise VM (EFI, TPM 2.0, unique serial for Autopilot) with a clean OOBE snapshot to roll back to

## Phases

Each phase maps to a domain of the MD-102 exam.

| Phase | Focus | Status |
| --- | --- | --- |
| [1. Identity and enrollment](phase-1-identity/) | Users, groups, admin roles (RBAC), enrollment settings, Windows Hello, Autopilot profile | In progress |
| 2. Deploy and maintain | Autopilot deployment, configuration profiles, update rings | Planned |
| 3. Protect | Compliance policies, Conditional Access, BitLocker, Windows LAPS, Defender for Endpoint | Planned |
| 4. Apps | Win32 apps, Microsoft 365 Apps, Store/WinGet apps, app protection policies | Planned |
| 5. Automation and monitoring | Microsoft Graph PowerShell, remediation scripts, Endpoint Analytics, reporting | Planned |

## Scripts

- [`New-LabUsers.ps1`](phase-1-identity/scripts/New-LabUsers.ps1) creates the lab users in Entra ID from a CSV using Microsoft Graph. It skips users that already exist, so it's safe to re-run.

## Security notes

- No passwords, secrets, tenant IDs or personal information are stored in this repository.
- Screenshots are redacted before being committed.
- All users and the company are fictional.
