# Protection

This covers Conditional Access from the "Protect devices" part of MD-102. Compliance, BitLocker and LAPS are in [device management](../device-management/); this is where a non-compliant device actually gets blocked.

## Before the policies

I made `GRP-CA-Exclude` with only the break-glass account in it. Every policy excludes this group, so a broken policy can't lock everyone out.

The tenant still had security defaults on, which can't be used together with Conditional Access. I built the first two policies in report-only, checked them with the What If tool, then turned security defaults off and both policies on straight after.

Screenshot: [exclusion group](screenshots/p3-A-ca-exclude-group.png)

## CA01 - Require MFA for all users

All users, all resources, require MFA, break-glass excluded. I left my own admin account in it on purpose, since that's the account that most needs MFA.

What If showed CA01 applying to Sarah and nothing applying to the break-glass account. After turning it on, Sarah's sign-in log shows CA01 as Success. She had already registered Authenticator under security defaults, so nothing changed for her except that the MFA now comes from my policy.

Screenshots: [CA01 settings](screenshots/p3-B-ca01-settings.png), [What If for Sarah](screenshots/p3-B-whatif-sarah.png), [What If for break-glass](screenshots/p3-B-whatif-breakglass.png), [sign-in log](screenshots/p3-B-ca01-success-signin-log.png)

## CA02 - Block legacy authentication

All users, all resources, client apps limited to Exchange ActiveSync and other clients, block access. Old protocols like POP and IMAP can't do MFA, so without this they would be a way around CA01. A normal browser sign-in shows CA02 as Not applied (see the same [sign-in log](screenshots/p3-B-ca01-success-signin-log.png)).

Screenshot: [CA02 details](screenshots/p3-C-ca02-details.png)

## CA03 - Require compliant device for staff

`GRP-All-Staff`, Office 365, require the device to be marked as compliant.

- It's scoped to staff, not all users, so admins can still manage the tenant from unmanaged machines.
- It targets Office 365 instead of all resources, so a new device can still reach Intune to enroll and become compliant.

My first save had four device platforms excluded, which would have let macOS skip the policy completely. I set device platforms back to not configured before testing.

In report-only, Sarah's sign-in from my Mac showed CA03 as "Report-only: Failure" and her sign-in from `NHC-LABWIN01` as "Report-only: Success". After turning it on, the Mac got "Set up your device to get access" (error 530003, device unregistered) and the VM went straight into Microsoft 365.

Screenshots: [report-only on the Mac](screenshots/p3-D-reportonly-mac-failure.png), [report-only on the VM](screenshots/p3-D-reportonly-vm-success.png), [Mac blocked](screenshots/p3-D-mac-blocked.png), [VM allowed](screenshots/p3-D-vm-allowed.png)

## Breaking compliance on purpose

To test the whole chain, I turned off Windows Firewall on the VM as `nhcadmin` with `netsh advfirewall set allprofiles state off`.

- Intune marked the device Not compliant with only Firewall failing.
- Sarah got "Device must comply with your organization's compliance requirements" on the company device.
- The web Company Portal told her the device must have the firewall enabled.

I turned the firewall back on, the device went Compliant again, and Sarah could sign in to Microsoft 365 again within about 15 minutes of the firewall first going off.

Screenshots: [firewall off](screenshots/p3-E-firewall-off.png), [firewall not compliant](screenshots/p3-E-firewall-not-compliant.png), [VM blocked](screenshots/p3-E-vm-blocked.png), [Company Portal reason](screenshots/p3-E-company-portal-reason.png), [compliant again](screenshots/p3-E-compliant-again.png), [access restored](screenshots/p3-E-access-restored.png)
