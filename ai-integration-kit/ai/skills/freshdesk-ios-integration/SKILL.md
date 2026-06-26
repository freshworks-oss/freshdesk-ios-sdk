---
name: freshdesk-ios-integration
description: Integrate, debug, and verify the Freshdesk iOS SDK (FreshdeskSDK / Freshchat) in a host iOS app. Runs Freshdesk.runDiagnostics, reads the structured FDDiagnosticReport, and applies each check's fixHint. Consults official Freshdesk setup and JWT documentation when the diagnostics signal alone is insufficient. Use when the user mentions FreshdeskSDK, Freshchat, Freshdesk.initialize, FreshdeskSDKConfig, JWT authentication for Freshdesk chat, push notifications for Freshdesk, customising or localising the Freshdesk widget's static text (ContentConfiguration / setContentConfiguration), or asks to diagnose why the Freshdesk widget, support chat, or notifications are not working.
---

# Freshdesk iOS SDK Integration

This skill teaches an AI agent how to integrate, debug, and verify the Freshdesk iOS SDK in a host app. It supports two modes:

- **Mode A — Greenfield integration**: the SDK is not yet in the app. The agent adds the dependency, asks the developer structured questions about where to wire support entry points, push, and JWT, then writes the code in the right places.
- **Mode B — Diagnostics-driven debugging**: the SDK is already integrated. The agent treats `Freshdesk.runDiagnostics` as the source of truth, reads the structured report, and applies each check's `fixHint`.

In either mode, fall back to the public Freshdesk documentation only when the in-codebase or in-report signal does not resolve the issue.

## When to use

Apply this skill when:

- The user is integrating FreshdeskSDK into an iOS app for the first time, or asks to add Freshdesk support to their app.
- The user reports a Freshdesk-specific symptom: widget does not open, push notifications do not arrive, JWT authentication fails, build errors after adding the SDK, etc.
- The user asks to verify or audit an existing FreshdeskSDK integration.
- The user mentions `Freshdesk.initialize`, `Freshchat`, `FreshdeskSDKConfig`, `FreshdeskJWTDelegate`, `setUserDetails`, `setTicketProperties`, `runDiagnostics`, `setPushRegistrationToken`, `handleRemoteNotification`, `authenticateAndUpdate`, `openSupport`, `openTopic`, `openKnowledgeBase`, `Configuration`, `ContentConfiguration`, or `setContentConfiguration`.
- The user wants to customise or localise the widget's static text (chat header, FAQ labels, placeholders, ticket form, privacy policy, response-time messages).

Do NOT use this skill for:

- Freshdesk web/dashboard configuration questions unrelated to the iOS SDK.
- Generic chat SDKs (Intercom, Zendesk, etc.).
- Pure iOS questions with no Freshdesk involvement.

## Inputs

Before acting, decide which mode applies (see Step 0) and collect:

### Common inputs

| Input | Where to get it |
|---|---|
| Account token | Admin Settings → Mobile Chat SDK → select SDK → App Keys |
| Host URL | Admin Settings → Mobile Chat SDK → select SDK → App Keys |
| SDK ID | Admin Settings → Mobile Chat SDK → select SDK → App Keys |
| JWT (if widget enforces it) | Generated server-side using the encryption key under the SDK widget |
| iOS deployment target | Host app's Xcode project / Package.swift (must be ≥ iOS 17) |

### Mode A only — Greenfield integration

Ask the developer (one question at a time, do not assume):

| Question | Why it matters |
|---|---|
| Where in the app should users open Freshdesk support? (screen + control) | Decides where `Freshdesk.openSupport(_:)` is called from |
| Do you want to deep-link to a specific topic or the knowledge base? | Picks `openTopic` / `openKnowledgeBase` over `openSupport` |
| Do you want push notifications for replies? | Decides whether to wire APNs and request the Push Notifications capability |
| Does your widget enforce JWT authentication? (yes / no / unknown) | Decides whether to wire `FreshdeskJWTDelegate` and `authenticateAndUpdate` |
| Are users identified (logged in)? Do you want to send user properties or ticket properties? | Decides whether to call `setUserDetails` / `setTicketProperties` (skip these if JWT is enforced — see Step A5) |
| Do you want to forward custom user events for context? | Decides whether to wire `Freshdesk.trackUserEvents` |
| What is the target locale, if any? | Passed as `locale:` to `FreshdeskSDKConfig` (set only at init) |
| Do you need to customise or localise the widget's static text (chat header, FAQ labels, placeholders, ticket form, privacy policy, response-time messages)? | Decides whether to build a `ContentConfiguration` and pass it via `config:` at init and/or call `Freshdesk.setContentConfiguration(_:)` — see Step A8 |

`locale` and content configuration are independent: `locale` selects the widget's server-side localisation for a supported language, while `ContentConfiguration` overrides individual default strings regardless of locale.

If "unknown" appears for JWT enforcement, proceed without JWT and let `runDiagnostics` (after first build) reveal `remoteConfig.jwtEnforced`.

### Mode B only — Debug existing integration

| Input | Where to get it |
|---|---|
| Symptom | What is failing (widget, push, JWT, build, runtime) |
| Logs / report | Output of `Freshdesk.runDiagnostics` if already run |

## Steps

### Step 0: Detect the mode

Before doing anything else, decide which mode applies by inspecting the host app workspace:

1. Search for an existing FreshdeskSDK dependency:
   - `Package.swift` / `Package.resolved` containing `freshdesk-ios-sdk`.
   - `*.xcodeproj/project.pbxproj` referencing `FreshdeskSDK`.
   - Any source file with `import FreshdeskSDK`.
   - Any call to `Freshdesk.initialize(`.

2. Decide:
   - **No dependency AND no `Freshdesk.initialize` call** → **Mode A (Greenfield)**. Proceed to Step A1.
   - **Dependency present OR initialize present** → **Mode B (Debug)**. Proceed to Step B1.

If unsure, ask the user: "Is FreshdeskSDK already added to your app, or are we integrating it for the first time?"

---

## Mode A — Greenfield integration

Use this mode when the SDK is not yet in the app. `Freshdesk.runDiagnostics` cannot return useful data until the SDK is initialized and the app has run at least once, so the agent must Q&A its way to a working integration.

### Step A1: Confirm prerequisites and ask the right questions first

Before writing any code, gather the inputs from the **Mode A only** table in the Inputs section. Ask one question at a time and wait for an answer; do not assume defaults for things the user has not stated. Confirm:

- Host app deployment target is iOS 17 or newer (raise it if lower; SwiftPM blocks iOS 16).
- The user has access to Admin Settings → Mobile Chat SDK to retrieve token / host / sdkId.
- For push, the user can add the Push Notifications capability and (for production) upload a `.p8` Auth Key in the Freshdesk admin portal.

If any answer is missing, ask before proceeding.

### Step A2: Add the SwiftPM dependency

Add the SDK to the host app's package graph:

- **Package.swift project**: add to dependencies and to the relevant target's `dependencies`:

```swift
.package(url: "https://github.com/freshworks/freshdesk-ios-sdk", from: "1.0.0"), // use the latest release tag from GitHub
// ...
.product(name: "FreshdeskSDK", package: "freshdesk-ios-sdk"),
```

- **Xcode project (no Package.swift)**: instruct the user to add via File → Add Package Dependencies, paste the URL, and link `FreshdeskSDK` to the app target.

For the canonical setup steps and screenshots, refer the user to:
https://support.freshdesk.com/en/support/solutions/articles/50000011673-mobile-sdk-ios-setup-guide

### Step A3: Initialize the SDK in AppDelegate

Place initialization in `AppDelegate.application(_:didFinishLaunchingWithOptions:)`. For SwiftUI apps without an explicit AppDelegate, create one and bridge it via `@UIApplicationDelegateAdaptor`.

```swift
import UIKit
import FreshdeskSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let sdkConfig = FreshdeskSDKConfig(
            token: "<account-token>",
            host: "<host-url>",
            sdkId: "<sdk-id>",
            jwtToken: "<jwt-token-or-nil>",
            locale: "<locale-or-nil>"
            // Optional: customise/localise widget static text. Defaults to Configuration().
            // config: Configuration(content: <ContentConfiguration>)  // see Step A8
        )
        Freshdesk.initialize(with: sdkConfig)
        // Optional during integration; remove for release:
        Freshdesk.enableDebugLogs(true)
        return true
    }
}
```

Replace the placeholders with values the user provided. Never invent values. If a value is missing, ask.

### Step A4: Add the support entry point where the user said

Use the user's answer from the Inputs Q&A. Insert ONE of:

```swift
// Generic support home
Freshdesk.openSupport(self)              // self = the presenting UIViewController

// Specific topic
Freshdesk.openTopic(self, topicId: <id>, topicName: "<name>")

// Knowledge base
Freshdesk.openKnowledgeBase(self)
```

Place the call inside the action handler the user pointed at (button tap, menu row, etc.). For SwiftUI views that do not own a UIViewController, route through a `UIViewControllerRepresentable` or capture the topmost view controller from the app's window scene.

### Step A5: Wire user identification (only if applicable)

Only do this if the user said users are identified AND the widget does **not** enforce JWT.

```swift
Freshdesk.setUserDetails(with: [
    "name": "<full-name>",
    "email": "<email>",
])

// Optional, if the user wants prefilled ticket fields:
Freshdesk.setTicketProperties(with: [
    "subject": "<default-subject>",
    "priority": <int>,
])
```

If the widget enforces JWT (`remoteConfig.jwtEnforced == Enabled`), DO NOT call `setUserDetails`; pass user identity through JWT claims instead. See Step A6.

If the user wants custom event tracking:

```swift
Freshdesk.trackUserEvents(name: "<event-name>", payload: ["key": "value"])
```

### Step A6: Wire JWT (only if widget enforces it)

If the user said JWT is enforced (or unknown — proceed defensively):

1. Pass the JWT at init via `jwtToken:` in `FreshdeskSDKConfig`.
2. Set the delegate so the app reacts to expiry / rejection:

```swift
extension AppDelegate: FreshdeskJWTDelegate {
    func userStateChanged(_ userState: UserState) {
        switch userState {
        case .authExpired, .notAuthenticated:
            // Refresh the JWT server-side, then:
            // Freshdesk.authenticateAndUpdate(jwt: <new-token>)
            break
        case .authenticated, .identifierUpdated, .jwtNotPresent, .undefined:
            break
        @unknown default:
            break
        }
    }
}

// in didFinishLaunchingWithOptions, after Freshdesk.initialize:
Freshdesk.setJWTDelegate(self)
```

If the user does not have a JWT yet or is unsure how to generate one, point them to the official guide before writing more code:
https://support.freshdesk.com/en/support/solutions/articles/50000011580-enable-jwt-authentication

Common JWT mistakes to call out proactively:

- Pasting an opaque API key, OAuth access token, or Freshdesk personal access token instead of a signed JWT.
- Pasting only the payload or only the signed value without the three dot-separated segments.
- Pasting with surrounding quotes or whitespace.
- Signing key on the server does not match the encryption key configured under the SDK widget settings.

### Step A7: Wire push notifications (only if the user wants them)

Surface the required Xcode capabilities and Freshdesk portal setup BEFORE writing code:

1. In Xcode → Signing & Capabilities → add **Push Notifications**.
2. (Optional) Add **Background Modes** → check **Remote notifications** if the app needs `content-available` pushes.
3. In the Freshdesk admin portal → Mobile Chat SDK → select SDK → Push Notification → upload `.p8` Auth Key, set Auth Key ID and Team ID.

Then add the code:

```swift
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    func registerNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Freshdesk.setPushRegistrationToken(deviceToken)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        let appState = UIApplication.shared.applicationState
        if Freshdesk.isFreshdeskNotification(userInfo) {
            Freshdesk.handleRemoteNotification(userInfo, appState: appState)
        } else {
            completionHandler([.banner, .badge, .sound])
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let appState = UIApplication.shared.applicationState
        if Freshdesk.isFreshdeskNotification(userInfo) {
            Freshdesk.handleRemoteNotification(userInfo, appState: appState)
        }
        completionHandler()
    }
}

// Call after Freshdesk.initialize:
registerNotifications()
```

### Step A8: Content configuration / localisation (only if the user wants custom text)

Skip this step unless the user asked to customise or localise the widget's static text. Any field left unset falls back to the widget default, so build a `ContentConfiguration` with only the strings the user wants to override.

Apply it at init by passing a `Configuration` through `config:` in `FreshdeskSDKConfig`:

```swift
let content = ContentConfiguration(
    headers: HeaderContent(
        chat: "Talk to our team",
        faq: "Help Centre",
        channelResponse: ChannelResponseContent(
            offline: "We are away right now",
            online: ChannelResponseOnlineContent(
                defaultMessage: "We typically reply in a few minutes"
            )
        ),
        ticketForm: TicketFormContent(title: "Raise a ticket", submitBtnTitle: "Submit")
    ),
    placeholders: PlaceholderContent(
        replyField: "Type your reply...",
        searchField: "Search articles..."
    ),
    privacyPolicySetting: PrivacyPolicyContent(
        privacyPolicyMessage: "We respect your privacy",
        privacyPolicyLinkText: "Privacy Policy",
        privacyPolicyLink: "https://example.com/privacy"
    ),
    actions: ActionContent(tabChat: "Chat")
)

let sdkConfig = FreshdeskSDKConfig(
    token: "<account-token>",
    host: "<host-url>",
    sdkId: "<sdk-id>",
    jwtToken: "<jwt-token-or-nil>",
    locale: "<locale-or-nil>",
    config: Configuration(content: content)
)
Freshdesk.initialize(with: sdkConfig)
```

To change the text after initialization (for example when the user switches language at runtime):

```swift
Freshdesk.setContentConfiguration(
    ContentConfiguration(
        headers: HeaderContent(chat: "Chat now"),
        placeholders: PlaceholderContent(replyField: "Your message...")
    )
)
```

To reset all overrides back to the widget defaults:

```swift
Freshdesk.setContentConfiguration(ContentConfiguration())
```

`setContentConfiguration` persists the values and refreshes the widget so changes take effect immediately. For the full field list, consult the **Content Configuration / Localisation** section of the SDK README:
https://github.com/freshworks/freshdesk-ios-sdk/blob/main/README.md

### Step A9: First-run validation (hand off to Mode B)

After the code is in place, instruct the user to:

1. Build and run the app.
2. Open the support entry point at least once (so the widget loads).
3. Run diagnostics from a debug action or the entry-point handler:

```swift
Freshdesk.enableDebugLogs(true)
Freshdesk.runDiagnostics { report in
    print(report.prettyPrinted())
}
```

4. Share the report. From this point on, switch to **Mode B** to triage anything that is not `pass`.

---

## Mode B — Diagnose existing integration

Use this mode when the SDK is already integrated. Treat `Freshdesk.runDiagnostics` as the source of truth.

### Step B1: Run diagnostics first

Do not introduce code changes without a diagnostic signal.

```swift
Freshdesk.enableDebugLogs(true)
Freshdesk.runDiagnostics { report in
    print(report.prettyPrinted())
    // or use report.toJSON() to capture structured logs
}
```

Diagnostics return an `FDDiagnosticReport`. Each check has:

- `id` (e.g., `network.configEndpoint`)
- `status`: `pass | warn | fail | skipped`
- `details`: human-readable
- `fixHint`: the recommended remediation (use this verbatim when proposing fixes)

Check groups:

| Prefix | What it verifies |
|---|---|
| `config.*` | token, host, sdkId, bundle id, app version, iOS version, debug logs |
| `network.*` | reachability, config endpoint reachability + HTTP status |
| `remoteConfig.*` | cached remote config, webchat ID, JWT enforcement, localisation |
| `jwt.*` | presence, decode, expiry, current `UserState`, enforcement mismatch |
| `push.*` | OS permission, APNs registration, SDK token forwarded, device registered with Freshdesk |
| `widget.*` | webview controller, widget loaded |
| `runtime.*` | SDK version, device, OS, unread count |

Tokens, JWTs, APNs tokens, and device tokens are masked in `details` — safe to share.

### Step B2: Triage the report

Process checks in priority order:

1. Any `fail` — must be fixed first; integration cannot work otherwise.
2. Any `warn` — likely cause of the reported symptom; fix next.
3. `skipped` — informational only.

Map common failures to actions:

- `config.token` empty → ask the user to copy the token from Admin Settings → App Keys.
- `config.host` invalid URL → ask for a fully qualified `https://` host.
- `network.configEndpoint` HTTP 401 → token is wrong or revoked.
- `network.configEndpoint` HTTP 404 → wrong sdkId or host.
- `network.configEndpoint` HTTP 403 → account suspended or token invalid.
- `push.permission` denied → ask the user to re-enable in Settings.
- `push.sdkToken` not set → integrator has not called `Freshdesk.setPushRegistrationToken(deviceToken)`. See Mode A Step A7.
- `push.deviceRegistered` warn → token will re-register on next widget open; not a bug if `push.sdkToken` is pass.
- `widget.webViewControllerInitialised` no → config fetch failed; chase `network.*` checks.
- `jwt.*` failures → see Step B3.
- Custom or localised widget text not appearing → this is **not** a diagnostics failure (there is no `content.*` check). Verify a `ContentConfiguration` was passed via `config:` at init or applied with `Freshdesk.setContentConfiguration(_:)`, and that the overridden field names match. See Mode A Step A8.

Always cite the exact `fixHint` from the report when proposing a fix, so the recommendation matches what the SDK itself reports.

### Step B3: JWT troubleshooting

If `jwt.*` checks fail or `UserState` is not `authenticated`/`identifierUpdated`, walk through this checklist before guessing:

1. **Is JWT enforced?** Check `remoteConfig.jwtEnforced` in the report. If `Enabled`, the SDK needs `jwtAuthToken` either at init or via `Freshdesk.authenticateAndUpdate(jwt:)`.
2. **Is the token decodable?** `jwt.decodable` failing means malformed format. A valid JWT has three base64url segments separated by `.` (header.payload.signature). Common mistakes are listed in Mode A Step A6.
3. **Is it expired?** `jwt.expiry` reports remaining seconds. Negative means expired — refresh server-side.
4. **Is the signature valid?** The SDK does not verify the signature locally; if `jwt.userState` is `notAuthenticated`, the server rejected the token. Verify the signing key matches the encryption key configured in the SDK widget settings.
5. **Is the delegate wired?** See Mode A Step A6 for the delegate snippet.

If the diagnostics signal is unclear, consult the official JWT enablement guide for the canonical setup:
https://support.freshdesk.com/en/support/solutions/articles/50000011580-enable-jwt-authentication

### Step B4: Validate the fix

After applying any change, re-run `Freshdesk.runDiagnostics`. Confirm:

- The previously failing check now reports `pass`.
- No new `fail` was introduced elsewhere.
- The reported symptom is resolved end-to-end (widget opens, push arrives, user authenticated).

Do not declare the integration fixed until the report meets all three.

## Output

The shape of the response depends on the mode.

### Mode A (Greenfield integration)

When responding to the user, always include:

1. **Mode confirmation**: state that the SDK is being added for the first time.
2. **Outstanding questions**: any input from the Mode A inputs table that the user has not answered yet, asked one at a time when possible.
3. **List of files modified or created**, grouped by purpose:
   - Dependency: `Package.swift` or Xcode package dependencies.
   - Init: `AppDelegate` (or bridged via `@UIApplicationDelegateAdaptor` for SwiftUI apps).
   - Entry point: the screen + control where `openSupport` / `openTopic` / `openKnowledgeBase` is wired.
   - Push (if requested): APNs delegates and `Info.plist` / capabilities checklist.
   - JWT (if enforced): `FreshdeskJWTDelegate` conformance.
   - Content configuration (if requested): where the `ContentConfiguration` is built and passed via `config:` / `Freshdesk.setContentConfiguration(_:)`.
4. **Capabilities and permissions checklist** the developer must add manually in Xcode and the Freshdesk admin portal:
   - iOS deployment target ≥ 17.
   - Push Notifications capability (only if push is wired).
   - `.p8` Auth Key + Auth Key ID + Team ID uploaded to Freshdesk admin portal (only if push is wired).
5. **Most relevant official link**:
   - Setup: https://support.freshdesk.com/en/support/solutions/articles/50000011673-mobile-sdk-ios-setup-guide
   - JWT: https://support.freshdesk.com/en/support/solutions/articles/50000011580-enable-jwt-authentication
   - README API surface: https://github.com/freshworks/freshdesk-ios-sdk/blob/main/README.md
6. **Hand-off to Mode B**: instruct the user to build, run, open the support entry once, and call `Freshdesk.runDiagnostics` to confirm everything is wired correctly. Share the report back.

Never invent a token, host, sdkId, JWT, or push key. If a value is missing, ask.

### Mode B (Diagnose existing integration)

When responding to the user, always include:

1. **Diagnostics summary**: overall status + first non-pass check (id, details, fixHint).
2. **For each non-pass check**: the `id`, `details`, and the recommended fix using the report's `fixHint` verbatim.
3. **Minimal Swift code change** to apply the fix — drop-in, ready to paste.
4. **Most relevant official link** for context (same set as Mode A).
5. **Verification step**: instruct the user to re-run `Freshdesk.runDiagnostics` and share the new report.

Never present a diagnostic conclusion without first running `Freshdesk.runDiagnostics` (or asking the user to share its output).

## Examples

For worked integration and debugging scenarios, see [examples.md](examples.md).

## Advanced APIs

This skill focuses on integrate-and-debug workflows. For APIs not covered here — `resetUser`, unread-count observers (`FDEvents`), custom link handling, dismissing SDK views, and the full `ContentConfiguration` field list — see the [SDK README](https://github.com/freshworks/freshdesk-ios-sdk/blob/main/README.md).

## Reference links

- Mobile SDK iOS setup guide:
  https://support.freshdesk.com/en/support/solutions/articles/50000011673-mobile-sdk-ios-setup-guide
- README and API surface (includes Content Configuration / Localisation):
  https://github.com/freshworks/freshdesk-ios-sdk/blob/main/README.md
- Enable JWT authentication:
  https://support.freshdesk.com/en/support/solutions/articles/50000011580-enable-jwt-authentication
