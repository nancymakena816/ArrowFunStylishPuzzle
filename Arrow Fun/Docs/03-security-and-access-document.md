# Security And Access Document

## Security Summary

The game should follow a privacy-light, local-first model. It should not require user accounts, should not collect unnecessary personal data, and should limit third-party SDK access. This lowers App Store review risk and improves user trust.

## Data Classification

### Public Data

- App name
- App icon
- Store screenshots
- Public support email
- Public privacy policy

### Game Data

- Level progress
- Stars
- Move counts
- Hints
- Coins
- Settings
- Daily streaks

### Analytics Data

- Anonymous gameplay events
- Device class
- App version
- Country or region if provided by analytics SDK
- Crash logs

### Restricted Data

Avoid collecting restricted data in version 1:

- Name
- Email
- Phone number
- Precise location
- Contacts
- Photos
- Microphone
- Camera
- Health data
- User-generated chat or messages

## Privacy Principles

- Collect the minimum data needed.
- Do not require login for gameplay.
- Do not request device permissions unless a feature truly needs them.
- Do not collect precise location.
- Do not sell user data.
- Do not track users across apps without App Tracking Transparency consent.
- Keep children and teen safety in mind even if the app is not submitted to the Kids Category.

## Permissions

Version 1 should require no sensitive iOS permissions.

Allowed only if needed:

- Network access for analytics, remote config, and daily puzzle.
- App Tracking Transparency prompt only if a future SDK performs tracking.

Not required:

- Camera
- Microphone
- Contacts
- Photos
- Location
- Bluetooth
- Health

## Authentication And Accounts

No account system is required for version 1.

Benefits:

- Lower privacy burden.
- Easier App Review.
- Better casual-player onboarding.
- Fewer security risks.

If cloud sync is added later, prefer Sign in with Apple and clearly explain why login is needed.

## Local Storage Security

Store locally:

- Progress
- Settings
- Stars
- Level unlocks
- Hint balance
- Coin balance

Protection requirements:

- Do not store secrets in plain text.
- Use basic integrity checks for locally saved progress.
- Keep local save migration versioned.

## Analytics Security

Allowed event data:

- Anonymous level events.
- Session events.
- Crash data.
- App version.
- Device class.

Avoid:

- Exact user identifiers unless necessary.
- Free-form user text.
- Precise location.
- Contact information.
- Any data from device sensors unrelated to gameplay.

Retention:

- Keep analytics data only as long as needed for product decisions.
- Document retention in the privacy policy if applicable.

## Access Control For Team Members

### Apple Developer Account

- Owner: business owner only.
- Admin: project lead or release manager.
- App Manager: producer/product owner.
- Developer: engineers who need certificates and builds.
- Marketing: metadata and screenshots only.
- Finance: payments and reports only.

Use least privilege access. Remove access when team members leave.

### Source Code Repository

- Main branch protected.
- Pull requests required for changes.
- At least one review before merge.
- CI checks required before release branches.
- No secrets committed.

### Third-Party Services

- Analytics dashboard: product and engineering leads.
- Crash reporting: engineering team.
- Remote config: restricted to release owners.

## Secrets Management

Do not commit:

- API keys
- Signing certificates
- Provisioning profiles
- Service account files

Use:

- CI secret storage.
- Environment-specific config.
- App Store Connect roles.
- Separate development and production keys.

## App Store Review Safety

Before submission:

- Privacy policy URL must be live.
- Support URL must be live.
- App Privacy labels must match SDK behavior.
- Review notes must explain offline behavior and any remote config.
- Demo mode must be available if any gated feature exists.

## Incident Response

Potential incidents:

- Crash spike after release.
- Privacy label mismatch.
- Lost progress after update.

Response plan:

1. Triage severity.
2. Disable risky feature through remote config if available.
3. Prepare hotfix build.
4. Update App Review notes if resubmitting.
5. Notify users if user-impacting privacy are affected.

## Security Checklist

- No unnecessary permissions.
- No required login.
- No secrets in source code.
- Save integrity checks implemented.
- ATT prompt implemented if tracking exists.
- Privacy labels verified.
- SDK list reviewed.
- Support contact available.
- Remote config access restricted.
