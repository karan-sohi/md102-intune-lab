# Protection

This covers Conditional Access, Defender Antivirus and Windows Firewall. Compliance, BitLocker and LAPS are in [device management](../device-management/); I made non-compliant devices to get blocked from accessing company resources.

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

## CA04 - Admin sign-in frequency

The admin roles (Global Administrator, Intune Administrator, Privileged Role Administrator, Conditional Access Administrator and Security Administrator) have to sign in again with MFA every 4 hours, and the browser session doesn't persist. It targets directory roles instead of people, so anyone given one of those roles is covered. Tom's Intune Administrator role is PIM-eligible, so the policy only applies to him while the role is active.

What If showed CA01 and CA04 for my admin account, and CA01 and CA03 but not CA04 for Sarah. After turning it on, going back to the portal gave "Interaction required" with AADSTS70044 (session expired because of sign-in frequency). The rejected session shows as Failure 70044 in the sign-in log, and the fresh sign-in after it shows CA04 as Success.

Screenshots: [What If for admin](screenshots/p3-F-whatif-admin.png), [What If for Sarah](screenshots/p3-F-whatif-sarah-no-ca04.png), [session expired](screenshots/p3-F-ca04-session-expired.png), [70044 in the sign-in log](screenshots/p3-F-ca04-reauth-70044.png), [CA04 success](screenshots/p3-F-ca04-success.png)

## Defender Antivirus

`Clinic - Defender Antivirus` is an Endpoint security antivirus policy. Defender for Endpoint isn't in my licence, so this configures the built-in Defender Antivirus:

- Real-time, behavior and cloud protection on, with cloud block level High and a 50 second extended timeout
- Safe samples sent automatically, and potentially unwanted apps blocked
- Downloads, scripts, email and removable drives scanned
- A quick scan every day at noon, and definitions checked every 4 hours

`Get-MpPreference` didn't show every setting, so I checked `HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Defender` instead. It lists each setting Intune delivered and which MDM provider set it.

To test it, I saved the EICAR test file on Sarah's desktop. The first try didn't trigger because I typed a zero instead of the letter O. With the right string, Notepad couldn't save the file, Windows Security showed "Threats found", and Protection history shows it as a severe virus, quarantined.

Screenshots: [settings delivered to the device](screenshots/p3-G-defender-policy-registry.png), [EICAR blocked](screenshots/p3-G-eicar-blocked.png), [EICAR quarantined](screenshots/p3-G-eicar-quarantined.png)

## Windows Firewall

`Clinic - Windows Firewall` turns the firewall on for the domain, private and public profiles, blocks inbound and allows outbound by default, and doesn't let local rules merge on the public profile.

To test it, I turned the firewall off as `nhcadmin` again. The next day `netsh` still said OFF, but `Get-NetFirewallProfile -PolicyStore ActiveStore` showed all three profiles enabled. The Intune policy overrides the local setting, so the firewall never actually went off.

The compliance policy showed the Firewall setting as Error (2016345612, SyncML 500) instead of Not compliant while the local and policy settings disagreed, and Intune counts an error as not compliant. After I turned the local setting back on and synced, it went back to Compliant.

Screenshots: [local off, effective on](screenshots/p3-H-firewall-local-off-effective-on.png), [compliance error](screenshots/p3-H-firewall-compliance-error.png), [compliant again](screenshots/p3-H-compliant-final.png)
