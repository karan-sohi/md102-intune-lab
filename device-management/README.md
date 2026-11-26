# Device management

This covers pushing settings to the enrolled device, deciding what a compliant clinic device is, and turning on BitLocker, Windows LAPS and update rings. Everything was tested on `NHC-LABWIN01`, the VM enrolled through Autopilot as Sarah Chen.

All policies are assigned to `GRP-Autopilot-Devices` unless noted, and tagged Default and Clinical.

## Configuration profile

`Clinic - Workstation baseline` is a Settings catalog profile with a few settings every clinic PC needs:

- Screen locks after 15 minutes of inactivity
- A sign-in notice: "Authorized staff only. Activity on this device may be monitored."
- Consumer features (suggested apps and games) blocked
- All removable storage denied, so patient data can't be copied to USB

I picked the user-scoped version of the consumer features setting at first, which sits under Windows Spotlight (User). I swapped it for the device-scoped one since this is a device policy.

When I checked the next day, the profile showed 0 devices in every column. I had added the group under Excluded instead of Included. After moving it, the profile applied, and the sign-in notice showed up on the VM.

Screenshots: [profile succeeded](screenshots/p2-A-profile-succeeded.png), [sign-in notice on the VM](screenshots/p2-A-signin-notice.png)

## Compliance

I changed the tenant setting "Mark devices with no compliance policy assigned as" from Compliant to Not compliant. Until then the device showed Compliant only because nothing was checking it.

`Clinic - Windows compliance` requires BitLocker, Windows 11 24H2 (10.0.26100) or later, firewall, TPM, antivirus, Defender antimalware and real-time protection. Noncompliant devices are marked immediately. I left Secure Boot out because it's turned off on the VM so it can boot on my laptop.

The device went Not compliant with BitLocker as the only failing setting, which was expected before BitLocker was set up.

Screenshots: [compliance policy](screenshots/p2-B-compliance-policy.png), [tenant setting](screenshots/p2-B-no-policy-not-compliant.png), [not compliant because of BitLocker](screenshots/p2-B-not-compliant-bitlocker.png)

## BitLocker

`Clinic - BitLocker silent encryption` is an Endpoint security disk encryption policy. It encrypts the OS drive in the background without asking the user anything:

- Device encryption required, the warning about other encryption turned off, and standard users allowed to encrypt
- XTS-AES 128, used space only
- TPM only at startup, with startup PIN and startup key not allowed (anything else stops silent encryption)
- Recovery password saved to Entra ID, and BitLocker doesn't start until it's saved
- Recovery password rotates after it's used

The drive encrypted while Sarah was signed in, with no prompts. Running `manage-bde -status C:` showed 100% encrypted, protection on, and TPM plus a recovery password as protectors. After a restart and sync, the device turned Compliant.

The recovery key shows up in Intune under the device. Signed in as Ryan, the help desk account, the recovery key page returns "You don't have access".

Screenshots: [encrypting on the VM](screenshots/p2-C-bitlocker-encrypting.png), [manage-bde output](screenshots/p2-C-manage-bde-as-nhcadmin.png), [recovery key in Intune](screenshots/p2-C-recovery-key-escrowed.png), [help desk blocked from the key](screenshots/p2-C-helpdesk-no-key-access.png)

## Windows LAPS

`Clinic - Windows LAPS` is an Endpoint security account protection policy. The built-in Administrator account is disabled on Autopilot devices, so I let LAPS create and manage its own local admin account, `nhcadmin`:

- Password backed up to Entra ID, rotated every 7 days
- 14 characters with upper and lower case, numbers and special characters
- After it's used, the password is reset and the account signed out 8 hours later

The password shows up in Intune with the next rotation date. I used it to open an admin command prompt on the VM as `.\nhcadmin` while signed in as Sarah. The help desk role can't see the password.

Screenshots: [LAPS password in Intune](screenshots/p2-D-laps-password.png), [admin prompt as nhcadmin](screenshots/p2-C-manage-bde-as-nhcadmin.png)

## Windows updates

Two update rings, so a small group gets updates first:

- `Ring 1 - Pilot` goes to `GRP-Pilot-Users`. Quality updates install with no delay.
- `Ring 2 - Broad` goes to `GRP-All-Staff`, with `GRP-Pilot-Users` excluded. Quality updates are delayed 7 days.

Both rings install outside 8 AM to 6 PM, don't let staff pause updates, and force a restart 2 days after a quality update (7 for feature updates). Feature update deferral is 0 because a separate feature update policy keeps devices on the current Windows 11 version.

Sarah is a pilot user, so the VM only got Ring 1. On the VM, Windows Update shows that the settings are managed by the organization, and the configured update policies list shows the values from Intune.

Screenshots: [pilot ring succeeded](screenshots/p2-E-pilot-ring-succeeded.png), [Windows Update managed](screenshots/p2-E-updates-managed.png), [configured update policies](screenshots/p2-E-configured-update-policies.png)

## Remote actions

I ran the safe remote actions on the device and left the destructive ones (retire, wipe, Fresh start, Autopilot reset) alone so the VM stays enrolled.

- Quick malware scan and Defender intelligence update from the Secure menu. The definitions on the VM went from 1.463.411.0 to 1.463.428.0.
- Collect diagnostics, which uploaded a zip of event logs, registry and MDM logs to Intune in about 8 minutes.
- Restart, sent by Ryan from the help desk account. His menu only offers what his role allows: sync, restart, retire and wipe. Diagnostics, remediation, locate device and the local admin password are greyed out.

Device action status shows the result of each action, and the Intune audit log shows who sent it. The restart is logged as `rebootNow` initiated by Ryan.

Screenshots: [help desk remote actions](screenshots/p2-F-helpdesk-remote-actions.png), [device action status](screenshots/p2-F-device-action-status.png), [audit log](screenshots/p2-F-audit-log-ryan-restart.png), [diagnostics collected](screenshots/p2-F-diagnostics-complete.png), [Defender intelligence updated](screenshots/p2-F-defender-intelligence-updated.png)

## Result

All policies show Succeeded on the device, and it's Compliant, corporate-owned and tagged Clinical.

Screenshots: [all policies succeeded](screenshots/p2-all-policies-succeeded.png), [device compliant](screenshots/p2-device-compliant.png)
