# Phase 1: Identity and enrollment

This phase covers the "Prepare infrastructure for devices" part of MD-102 (20-25% of the exam). The goal is to get the tenant ready for devices to enroll: users, groups, admin roles, enrollment settings, Windows Hello for Business and an Autopilot profile.

So far tenant basics are done and users and groups are in progress. Still to do: admin roles (scope tags, a custom Intune role), Entra device settings, enrollment (automatic enrollment, restrictions, Enrollment Status Page), Windows Hello for Business, and the Autopilot profile and device registration.

## Tenant basics

I set the organization name to Northshore Health Clinic. Microsoft keeps the name separately for each billing account and for the Entra tenant, so the tenant name has to be changed in Entra ID > Overview > Properties.

I created a break-glass account with Global Administrator assigned permanently and active, not PIM-eligible, since PIM activation could be the thing that's broken in an emergency. It's cloud-only, the password is long and kept offline, and it will be excluded from every Conditional Access policy in Phase 3.

![Break-glass account role assignment](screenshots/p1-A-breakglass-global-admin.png)

I also set up company branding (Entra ID > Custom branding) with a logo, a sign-in background and an "authorized staff only" message.

![Branded sign-in page](screenshots/p1-A-branded-sign-in.png)

## Users and groups

There are 10 fictional staff. I created 2 in the portal to learn the interface and the other 8 with [New-LabUsers.ps1](scripts/New-LabUsers.ps1) from [users.csv](scripts/users.csv). Every user has a department, which the dynamic groups use, and a usage location, which is needed before a licence can be assigned.

The groups:

- `GRP-Clinical-Users`, `GRP-Reception-Users` and `GRP-IT-Users` are dynamic, one per department, e.g. `(user.department -eq "Clinical")`
- `GRP-All-Staff` is dynamic with `(user.department -in ["Clinical","Reception","IT"])`. Matching on department keeps admin and break-glass accounts out of it.
- `GRP-Pilot-Users` is assigned, with 2 users for trying changes out first

EMS E5 is assigned to `GRP-All-Staff` through group-based licensing, so a new staff member gets licensed as soon as their department is set.

To run the script you need PowerShell 7 and the Graph modules:

```powershell
cd phase-1-identity/scripts
Install-PSResource Microsoft.Graph.Authentication, Microsoft.Graph.Users -Scope CurrentUser -TrustRepository
./New-LabUsers.ps1
```
