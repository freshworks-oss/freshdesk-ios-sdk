# Freshdesk iOS SDK Integration — Examples

Worked scenarios for the [Freshdesk iOS SDK integration skill](SKILL.md).

## Example 0: Greenfield SwiftUI integration (Mode A)

User: "I want to add Freshdesk support to my SwiftUI iOS app. There's a 'Help' button on the Settings screen that should open it."

1. Detect mode: search the workspace; no `Freshdesk.initialize`, no `import FreshdeskSDK`, no SwiftPM dependency. Use Mode A.
2. Q&A loop (one at a time):
   - "Is your SDK widget JWT-enforced? (yes / no / unknown)" → user answers "no".
   - "Do you want push notifications for replies?" → user answers "yes".
   - "Are users identified (logged in)? Should we set name/email?" → user answers "no, anonymous".
   - "Provide your token, host, sdkId from Admin Settings → Mobile Chat SDK → App Keys." → user pastes values.
3. Add SwiftPM dependency to `Package.swift` (or Xcode package dependencies).
4. Create or edit AppDelegate (bridged via `@UIApplicationDelegateAdaptor`). Add `Freshdesk.initialize(with:)` and `registerNotifications()`.
5. Wire APNs delegates per Step A7.
6. In `SettingsView.swift`, on the "Help" button action, route to a UIViewController and call `Freshdesk.openSupport(viewController)`.
7. Capabilities checklist for the user:
   - Add **Push Notifications** capability in Xcode.
   - Upload `.p8` Auth Key + Team ID to Freshdesk admin → Mobile Chat SDK → Push Notification.
   - Confirm host app deployment target is iOS 15+.
8. Hand off to Mode B: "Build, run, tap Help once, then run `Freshdesk.runDiagnostics { print($0.prettyPrinted()) }` and share the report."

## Example 1: Widget does not open

User: "I call `Freshdesk.openSupport(self)` but nothing happens."

1. Ask the user to enable debug logs and run diagnostics:

```swift
Freshdesk.enableDebugLogs(true)
Freshdesk.runDiagnostics { report in print(report.prettyPrinted()) }
```

2. Suppose the report shows:

```
Overall: FAIL
[FAIL] network.configEndpoint  HTTP 404 -> Not found. Check the sdkId and host values.
[WARN] widget.webViewControllerInitialised  no -> WebView is created after the first successful config fetch.
```

3. Diagnosis: invalid sdkId or host; the WebView never gets created because the config fetch fails.
4. Action: ask the user to copy the exact host and sdkId from Admin Settings → Mobile Chat SDK → App Keys and re-initialize. Cite https://support.freshdesk.com/en/support/solutions/articles/50000011673-mobile-sdk-ios-setup-guide for where these values live.
5. After fix, re-run diagnostics and confirm `network.configEndpoint` is `pass` and `widget.webViewControllerInitialised` is `pass`.

## Example 2: Push notifications never arrive for Freshdesk

User: "Other notifications work but Freshdesk pushes never arrive."

1. Run diagnostics. Suppose the report shows:

```
[PASS] push.permission        authorized
[PASS] push.registeredWithAPNs yes
[WARN] push.sdkToken          not set -> Call Freshdesk.setPushRegistrationToken(deviceToken) in didRegisterForRemoteNotificationsWithDeviceToken.
[SKIP] push.deviceRegistered  no deviceId stored
```

2. Diagnosis: the APNs token was never forwarded to FreshdeskSDK, so the server cannot target this device.
3. Fix:

```swift
func application(_ application: UIApplication,
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Freshdesk.setPushRegistrationToken(deviceToken)
}
```

4. Re-run diagnostics; confirm `push.sdkToken` now reports `pass` and `push.deviceRegistered` reports `pass` after the next widget open.

## Example 3: JWT-enforced widget rejects the token

User: "I keep getting `notAuthenticated` even though I'm passing a JWT."

1. Run diagnostics. Suppose the report shows:

```
[PASS] remoteConfig.jwtEnforced   Enabled
[PASS] jwt.present                eyJh****Sd0R
[FAIL] jwt.decodable             failed to parse header/payload -> Ensure the JWT has three base64url segments separated by '.'
[FAIL] jwt.userState             not_authenticated -> JWT was rejected. Verify the token signature and claims.
```

2. Diagnosis: the value being passed is not a valid JWT structure (it parses base64 but does not have three dot-separated segments, or the segments are not valid base64url JSON).
3. Action:
   - Confirm the token has the shape `xxx.yyy.zzz`.
   - Check the user has not pasted an opaque Freshdesk API key or OAuth token by mistake.
   - Verify the signing key matches the encryption key set under the SDK widget settings; see https://support.freshdesk.com/en/support/solutions/articles/50000011580-enable-jwt-authentication
   - Once a valid JWT is generated server-side, call:

```swift
Freshdesk.authenticateAndUpdate(jwt: "<valid-JWT>")
```

4. Re-run diagnostics and confirm `jwt.decodable` is `pass`, `jwt.userState` is `authenticated` or `identifierUpdated`.

## Example 4: SPM cannot add the SDK

User: "Xcode says the package requires iOS 15 but my app is iOS 14."

1. No diagnostics needed — this is a build-time / SPM-resolution issue.
2. Action: raise the host app's deployment target to iOS 15 in Xcode (Project → Target → Minimum Deployments → iOS 15.0). FreshdeskSDK declares `.iOS(.v15)` in `Package.swift` and SPM blocks lower targets at resolution.
3. After raising the target, re-add the SDK and run `Freshdesk.runDiagnostics` to confirm a clean baseline.

## Example 5: Customise / localise the widget's static text

User: "I want the chat header to say 'Talk to Acme Support' and the reply box placeholder to say 'Write a message…'."

1. This is a content configuration request (Mode A Step A8), not a diagnostics issue. Build a `ContentConfiguration` overriding only those two fields; everything else keeps the widget default.
2. If integrating for the first time, pass it at init via `config:`:

```swift
let content = ContentConfiguration(
    headers: HeaderContent(chat: "Talk to Acme Support"),
    placeholders: PlaceholderContent(replyField: "Write a message…")
)

let sdkConfig = FreshdeskSDKConfig(
    token: "<account-token>",
    host: "<host-url>",
    sdkId: "<sdk-id>",
    config: Configuration(content: content)
)
Freshdesk.initialize(with: sdkConfig)
```

3. If the SDK is already initialised, or the text must change at runtime (e.g. the user switched language), apply it directly:

```swift
Freshdesk.setContentConfiguration(
    ContentConfiguration(
        headers: HeaderContent(chat: "Talk to Acme Support"),
        placeholders: PlaceholderContent(replyField: "Write a message…")
    )
)
```

4. To revert to the widget defaults, call `Freshdesk.setContentConfiguration(ContentConfiguration())`.
5. If the new text does not appear, confirm the configuration was actually passed/applied and the field names match — there is no diagnostics check for content, so this must be verified in code. See the README's Content Configuration / Localisation section for the full field list.
