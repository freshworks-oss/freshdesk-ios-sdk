# Freshchat → Freshdesk iOS API mapping

Reference data for the [migration skill](SKILL.md)'s Step 5 loop. Look up the Freshchat symbol you found in the customer's code in the table below, then jump to the linked section for the exact before/after code and gotchas.

**Source of truth:** Freshchat iOS SDK `6.5.0` (`FreshchatSDK.h`, deployment target iOS 12.0) and Freshdesk iOS SDK `1.4.1` (`SDK_VERSION` in `FDConstants.swift`). Every Freshdesk-side signature below was verified directly against `Sources/FreshdeskSDK` in `freshworks/freshdesk_ios_sdk_dev` @ `main`, not only against README/portal docs (those have known errors — see the discrepancies noted inline). If you are running this skill against a newer SDK release, re-grep the symbol before trusting a signature verbatim; treat every code sample here as "verified as of 1.4.1", not as a live contract.

## Quick lookup — Freshchat symbol → action

Grep the customer's code for the left-hand column; the right-hand columns tell you what to do.

| Freshchat symbol | Action | Freshdesk replacement | Details |
|---|---|---|---|
| `pod 'FreshchatSDK'` | Replace (dependency) | SPM `https://github.com/freshworks/freshdesk-ios-sdk` | SKILL.md Step 2 |
| `import FreshchatSDK` | Replace (once file is clean) | `import FreshdeskSDK` | SKILL.md Step 3 |
| `Freshchat.sharedInstance()` | Replace | `Freshdesk` (global constant, not a type — cannot subclass/extend) | [§Entry point](#entry-point-and-initialization) |
| `FreshchatConfig(appID:andAppKey:)` + properties | Replace | `FreshdeskSDKConfig(token:host:sdkId:jwtToken:locale:config:shouldEnableLogs:hostPlatform:)` | [§Entry point](#entry-point-and-initialization) |
| `initWith(config)` | Replace | `initialize(with:)` | [§Entry point](#entry-point-and-initialization) |
| `Freshchat.sdkVersion()` | Replace | `getSDKVersion() -> String` (returns `"1.4.1"`) | Direct |
| `config.errorLogsEnabled` | Replace | `enableDebugLogs(_:)`, or `shouldEnableLogs` at init | Direct |
| — (no Freshchat equivalent) | New capability | `runDiagnostics(completion:)` → `FDDiagnosticReport` | [§Diagnostics](#diagnostics) |
| `FreshchatUser.sharedInstance()` + `setUser(_:)` | Replace | `setUserDetails(with: [String: Any])` | [§Identity](#identity-and-user-properties) |
| `setUserProperties(_:)` / `setUserPropertyforKey(_:withValue:)` | Replace | `setUserDetails(with:)` — merged, same call | [§Identity](#identity-and-user-properties) |
| `getFreshchatUserId()` | Replace | `getUser(onFailure:onSuccess:)` → `user["alias"]` | [§Identity](#identity-and-user-properties) |
| `identifyUser(withExternalID:restoreID:)` | **Gap** | none — use JWT | [§Identity](#identity-and-user-properties) |
| `resetUserWithCompletion:` | Replace | `resetUser(onSuccess:onFailure:)` | [§Session](#session-management-and-logout) |
| — (no ticketing in Freshchat) | New capability | `setTicketProperties(with: [String: Any])` | [§Identity](#identity-and-user-properties) |
| `setUserWithIdToken(_:)` | Replace | `jwtToken` at init, or `authenticateAndUpdate(jwt:)` | [§JWT](#jwt-authentication) |
| `restoreUserWithIdToken(_:)` | Replace | not required — `initialize`/`authenticateAndUpdate` handle it | [§JWT](#jwt-authentication) |
| `getUserIdTokenStatus()` | **Gap** | none (push-only) — cache `FreshdeskJWTDelegate` state yourself | [§JWT](#jwt-authentication) |
| `FCEventIdTokenStatusChange` | Replace | `FreshdeskJWTDelegate.userStateChanged(_:)` + `setJWTDelegate(_:)` | [§JWT](#jwt-authentication) |
| `showConversations(_:)` | Replace | `openSupport(_:)` — **not the same screen**, see notes | [§Opening the UI](#opening-the-sdk-ui) |
| `showFAQs(_:)` | Replace | `openKnowledgeBase(_:)` | [§Opening the UI](#opening-the-sdk-ui) |
| `FAQOptions` (grid/list, contact-us placement, tag filters) | **Gap** | none — `openKnowledgeBase` takes no options | [§Opening the UI](#opening-the-sdk-ui) |
| `ConversationOptions.filter(byTags:withTitle:)` | **Gap** | none | [§Opening the UI](#opening-the-sdk-ui) |
| `showConversation(_:withTopicName:withConversationReferenceID:)` | **Gap** (partial) | `openTopic(_:topicId:topicName:)` pre-selects a topic but is not a persisted per-reference thread | [§Opening the UI](#opening-the-sdk-ui) |
| `getFAQsControllerForEmbed` / `WithOptions:` | **Gap** | none — Freshdesk is presentation-only, no embeddable view controller | [§Opening the UI](#opening-the-sdk-ui) |
| `getConversationsControllerForEmbed` / `WithOptions:` | **Gap** | none — same as above | [§Opening the UI](#opening-the-sdk-ui) |
| `openFreshchatDeeplink(_:viewController:)` | **Gap** | none — route to `openSupport`/`openTopic` instead and accept the coarser landing point | [§Opening the UI](#opening-the-sdk-ui) |
| `dismissFreshchatViews()` | Replace | `dismissFreshdeskSDKViews()` | [§Opening the UI](#opening-the-sdk-ui) |
| `updateConversationBannerMessage(_:)` | **Gap** | none — static copy only via `ContentConfiguration.headers` | [§Opening the UI](#opening-the-sdk-ui) |
| `sendMessage(FreshchatMessage)` (tag or reference-ID form) | **Gap** | none — user must type; workaround via `setTicketProperties` + `openTopic` | [§Messaging and bots](#messaging-and-bots-with-no-equivalent) |
| `setBotVariables(_:withBotSpecificVariables:)` | **Gap** | none — workaround via `setUserDetails`/`setTicketProperties` | [§Messaging and bots](#messaging-and-bots-with-no-equivalent) |
| `unreadCount(completion:)` | Replace | `getUnreadCount() -> Int` — **now synchronous** | [§Unread count](#unread-count) |
| `FRESHCHAT_UNREAD_MESSAGE_COUNT_CHANGED` | Replace | `FDEvents.unreadCount`, `object` = `Int` | [§Unread count](#unread-count) |
| `unreadCount(forTags:completion:)` | **Gap** | none | [§Unread count](#unread-count) |
| `unreadCount(forTopic:forConversationReferenceID:completion:)` | **Gap** | none | [§Unread count](#unread-count) |
| `setPushRegistrationToken(_:)` | Replace | `setPushRegistrationToken(_:)` — same name, same shape | [§Push](#push-notifications) |
| `isFreshchatNotification(_:)` | Replace | `isFreshdeskNotification(_:)` | [§Push](#push-notifications) |
| `handleRemoteNotification(_:andAppstate:)` | Replace | `handleRemoteNotification(_:appState:)` | [§Push](#push-notifications) |
| `onNotificationClicked` block | **Gap** | none — cannot intercept/block/redirect the tap | [§Push](#push-notifications) |
| `config.notificationSoundEnabled` | **Gap** | none — governed by your `UNUserNotificationCenter` options + APNs payload | [§Push](#push-notifications) |
| `config.showNotificationBanner` | **Changed** | automatic, not configurable — no toggle to suppress it | [§Push](#push-notifications) |
| `trackEvent(_:withProperties:)` | Replace | `trackUserEvents(name:payload:)` — **payload values must be `String`**, not `Any` | [§Analytics](#analytics-and-event-tracking) |
| `FRESHCHAT_EVENTS` notification + `FreshchatEvent` (45 names) | Replace | six discrete `FDEvents` notifications | [§Events](#sdk-events) |
| `value(forEventProperty:)` / `FCEventProperty` | **Gap** | none — parse the `[String: Any]` payload yourself | [§Events](#sdk-events) |
| `customLinkHandler` block (`Bool` return) | Replace | `setCustomLinkHandler(handler:)` (`Void` return — **you handle every URL now**) | [§Listeners](#listeners-and-handlers) |
| — (native in-app attachment viewer) | **Changed** | attachments open in **Safari**, not configurable | [§Listeners](#listeners-and-handlers) |
| `config.themeName` + theme `.plist` | **Gap** in code | none — portal remote config on the linked Web Chat Widget | [§Theming](#theming-and-appearance) |
| `config.stringsBundle` | Replace | `ContentConfiguration` (§Content) + init-only `locale` | [§Localization](#localization-and-content-configuration) |
| Runtime locale change (swap `stringsBundle`) | **Gap** | none — `locale` is init-only; re-`initialize` to change it | [§Localization](#localization-and-content-configuration) |
| — (no Freshchat equivalent) | New capability | `ContentConfiguration` code-first string overrides | [§Content configuration](#content-configuration-field-reference) |

## Entry point and initialization

```swift
// Before
let config = FreshchatConfig(appID: "APP-ID", andAppKey: "APP-KEY")
config.domain = "YOUR-DOMAIN"
Freshchat.sharedInstance().initWith(config)

// After
let sdkConfig = FreshdeskSDKConfig(
    token: "<account-token>",   // required
    host: "<host-url>",         // required
    sdkId: "<sdk-id>",          // required
    jwtToken: nil,               // String?, default nil — required if JWT enforcement is on
    locale: "en",                 // String?, default nil — init-only
    config: Configuration(),      // wraps ContentConfiguration — NOT a String (README/older drafts show this wrong)
    shouldEnableLogs: true,       // Bool, default false
    hostPlatform: .iOS            // SDKHostPlatform, default .iOS — cases: .iOS, .phonegap, .flutter, .xamarin, .reactNative
)
Freshdesk.initialize(with: sdkConfig)
```

- `Freshdesk` is `public let Freshdesk = Freshworks.shared` — a **global constant**, not a type. You cannot subclass or extend it. The underlying type is `public final actor Freshworks`, but every public method is `nonisolated`, so no `await` is needed anywhere in this migration.
- `initialize(with:)` returns `Void` and internally runs `Task { @MainActor in ... fetchConfigurations() }` — remote config is fetched asynchronously. There is **no readiness callback** (no `initializedCallback` equivalent). Do not write code that waits on one.
- Sequencing gate (verified against `WidgetStateManager.swift`): most non-init calls go through `runWhenReady`/`requireInit`, which behaves as follows:
  - Config already initialized → runs immediately.
  - Config fetch in progress → the call is **queued** and replayed once the widget loads.
  - No config **and** no fetch in progress (i.e. you called something before `initialize`) → the call is **dropped** and, in one specific path, the SDK shows a **user-visible "This section is no longer available" alert**.
  - Practical rule: call `initialize` first, from `didFinishLaunchingWithOptions`, and never call another SDK API before it.

## Identity and user properties

```swift
// Before
let user = FreshchatUser.sharedInstance()
user?.firstName = "Jane"; user?.email = "jane@example.com"
Freshchat.sharedInstance().setUser(user)
Freshchat.sharedInstance().setUserProperties(["plan": "premium"])

// After — one free-form dictionary, standard and custom keys together
Freshdesk.setUserDetails(with: [
    "name": "Jane Doe",
    "email": "jane@example.com",
    "plan": "premium"   // custom property — must be pre-whitelisted as a Contact Field in the portal
])

// New capability — no Freshchat equivalent
Freshdesk.setTicketProperties(with: ["subject": "Product Enquiry", "priority": 3])

// Reading the user — was synchronous, is now callback-based
Freshdesk.getUser(
    onFailure: { error in },
    onSuccess: { user in print(user["alias"] ?? "") }   // [String: Any], "alias" is the identifier
)
```

**Two silent-failure modes, verified against source — call these out explicitly whenever you migrate a `setUser`/`setUserProperties`/`setUserPropertyforKey` call site:**

1. Both `setUserDetails` and `setTicketProperties` check `FDConfigManager.shared.currentConfig?.userAuthenticationEnforcedState == .enabled` and **return immediately** if JWT is enforced — no throw, no callback, no log visible to the end user (only an internal `Logger.error`). Under an enforced widget, put this data in the **JWT payload** instead ([§JWT](#jwt-authentication)).
2. Both also validate the dictionary with `JSONSerialization.data(withJSONObject:)` and return early if it fails — non-JSON-encodable values (`Date`, `UIImage`, custom classes) are dropped silently.

If the app's code relies on properties reaching the backend, migrate any assumption of success into a `getUser` verification instead.

`identifyUser(withExternalID:restoreID:)` has **no equivalent** — there is no `externalID`/`restoreID` API. Identity is JWT-only. Apply the Gap comment template and point the developer to [§JWT](#jwt-authentication).

## Session management and logout

```swift
// Before
Freshchat.sharedInstance().resetUser { /* fire and forget */ }

// After
func logout() {
    Freshdesk.dismissFreshdeskSDKViews()
    Freshdesk.resetUser(
        onSuccess: { clearAppSession(); navigateToLogin() },
        onFailure: { clearAppSession(); navigateToLogin() }   // reset did NOT happen — still clear your own state
    )
}
```

Verified `resetUser(onSuccess: (() -> Void)? = nil, onFailure: (() -> Void)? = nil)` contract:

- Preconditions: a user must already exist (read via `getUser`'s `alias`) **and** the widget must be loaded, or `onFailure` fires immediately with no reset attempted.
- Sequence: `getUser` → read `alias` → fetch session token → **deregister the push device** → only then reset.
- **Every step can abort the reset**: a failed session-token fetch or a failed push-deregistration both call `onFailure` and explicitly do **not** proceed with the reset.
- On success: clears the widget user, resets SDK configuration and JWT user details, calls `removeAllDeliveredNotifications()`, and emits `FDEvents.userCleared`.
- Always clear the app's own session in **both** `onSuccess` and `onFailure` — a failed SDK-side reset must not leave the app itself logged in as the old user.
- To switch users: call `resetUser` first, then `authenticateAndUpdate(jwt:)` with the new user's token. Do not call `authenticateAndUpdate` alone to switch users.

## JWT authentication

```swift
// Before
Freshchat.sharedInstance().setUserWithIdToken(jwt)
Freshchat.sharedInstance().restoreUser(withIdToken: jwt)

// After
// Pass at init:
let sdkConfig = FreshdeskSDKConfig(token: "…", host: "…", sdkId: "…", jwtToken: jwt)
Freshdesk.initialize(with: sdkConfig)
// Refresh / post-login / guest-upgrade — one call for all three cases, and NOT gated by JWT enforcement:
Freshdesk.authenticateAndUpdate(jwt: newJwt)
```

Verified `UserState` (raw values) and mapping from Freshchat's `getUserIdTokenStatus()`:

| Freshchat `getUserIdTokenStatus()` | Freshdesk `UserState` | Raw value |
|---|---|---|
| `TOKEN_NOT_SET` | `.jwtNotPresent` | `jwt_not_present` |
| `TOKEN_NOT_PROCESSED` | *(no in-flight equivalent)* | — |
| `TOKEN_VALID` | `.authenticated` | `authenticated` |
| `TOKEN_INVALID` | `.notAuthenticated` | `not_authenticated` |
| `TOKEN_EXPIRED` | `.authExpired` | `auth_expired` |
| — | `.identifierUpdated` | `identifier_updated` |
| — | `.undefined` | `undefined` |

There is **no pull-based getter** — `getUserIdTokenStatus()` has no Freshdesk equivalent. State only arrives pushed to `FreshdeskJWTDelegate.userStateChanged(_:)`. Internally, `.authenticated` **and** `.identifierUpdated` both count as authenticated — mirror that, don't check `== .authenticated` alone.

```swift
Freshdesk.setJWTDelegate(self)   // set early, on a long-lived object (AppDelegate/coordinator), not a view controller

extension AppCoordinator: FreshdeskJWTDelegate {
    func userStateChanged(_ userState: UserState) {
        switch userState {
        case .authExpired: Freshdesk.authenticateAndUpdate(jwt: fetchNewJWT())
        case .notAuthenticated: presentReLogin()
        default: break
        }
    }
}
```

## Opening the SDK UI

```swift
// Before -> After
Freshchat.sharedInstance().showConversations(self)  -> Freshdesk.openSupport(self)
Freshchat.sharedInstance().showFAQs(self)            -> Freshdesk.openKnowledgeBase(self)
Freshchat.sharedInstance().dismissFreshchatViews()   -> Freshdesk.dismissFreshdeskSDKViews()
```

- **Not a like-for-like screen.** `showConversations` opened the channel list. `openSupport` opens Freshdesk's Support Home (chat + topics + FAQs together). Flag this to the user — the first screen changes, so review entry-point copy and analytics screen names.
- `openTopic(_ viewController: UIViewController, topicId: Int?, topicName: String? = nil)` — **verified param order and types**: `topicId` is `Int?` and comes **before** `topicName`. This is the closest thing to Freshchat's tag-filtered / parallel-conversation flows, but it only pre-selects a topic for a **new** ticket; it does not filter an existing list and there is no per-reference thread or per-reference unread count.
  ```swift
  // Recommended migration path for reference-ID-based parallel conversations
  Freshdesk.setTicketProperties(with: ["order_id": "ORD-12345"])
  Freshdesk.openTopic(self, topicId: nil, topicName: "Order Support")
  ```
- `FAQOptions`, `ConversationOptions`, `getFAQsControllerForEmbed`/`getConversationsControllerForEmbed`, and `openFreshchatDeeplink(_:viewController:)` have **no equivalent at all** — confirmed absent by source grep (no `ControllerForEmbed`/`embed` symbol anywhere in `Sources/FreshdeskSDK`). Freshdesk only *presents* its widget from a view controller you pass in; there is nothing to embed in a tab or child container. If the app embedded Freshchat's FAQ/conversation screens in its own hierarchy, that composition has no replacement — this is one of the largest structural losses and worth flagging to product before code review.
- **Real precedent for the Gap comment pattern**: this very SDK repo's own Sample app has a commented-out call for exactly this kind of gap — `Sample/SouthWest/SouthWest/Modules/TabBar/Tabs/SideMenu/MyOrders/OrderItemView.swift:50-51` still carries:
  ```swift
  //                        Freshdesk.openConversation(topView, conversationReferenceID: item.id.uuidString,
  //                                                           topicName: Configurations.ParallelConversation.topicName)
  ```
  There is no live `openConversation` method in the public API — apply the same "comment it, annotate it, let the developer decide" treatment to any Freshchat call with no mapping.

## Messaging and bots with no equivalent

```swift
// Before — no migration path, apply the Gap comment template verbatim
let m1 = FreshchatMessage(message: "Need help with my order", andTag: "orders")
Freshchat.sharedInstance().sendMessage(m1)

Freshchat.sharedInstance().setBotVariables(["userTier": "gold"], withBotSpecificVariables: [:])
```

- `sendMessage` (both the tag form and the reference-ID form): no API to pre-fill or send a message programmatically. The end user must type. Workaround (behaviorally different — properties only reach Freshdesk after the user's first message, they don't create the conversation immediately the way `sendMessage` did):
  ```swift
  Freshdesk.setTicketProperties(with: ["order_id": "ORD-123", "issue": "package_not_delivered"])
  Freshdesk.openTopic(self, topicId: nil, topicName: "Order Support")
  ```
- `setBotVariables(_:withBotSpecificVariables:)`: no equivalent. Workaround: pass the same values via `setUserDetails`/`setTicketProperties` (whitelisted in the portal) and reference them from bot/automation rules server-side — confirm with the Freshdesk admin that the bot flows can actually read those fields.
- `updateConversationBannerMessage(_:)`: no equivalent. Static copy only, via `ContentConfiguration.headers` — there is no dynamic per-session banner.

## Unread count

```swift
// Before
Freshchat.sharedInstance().unreadCount { count in }

// After — now synchronous
let count = Freshdesk.getUnreadCount()

// Push
NotificationCenter.default.addObserver(self, selector: #selector(onUnreadCount(_:)),
    name: Notification.Name(FDEvents.unreadCount.rawValue), object: nil)
@objc func onUnreadCount(_ n: NSNotification) { if let c = n.object as? Int { updateBadge(c) } }
```

`unreadCount(forTags:completion:)` and `unreadCount(forTopic:forConversationReferenceID:completion:)` have **no equivalent** — they depended on Freshchat's channel/tag model, which Freshdesk doesn't have. No workaround exists; state this plainly rather than inventing one.

## Push notifications

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Freshdesk.setPushRegistrationToken(deviceToken)   // same shape as Freshchat's call
}

func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                             withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    if Freshdesk.isFreshdeskNotification(userInfo) {
        Freshdesk.handleRemoteNotification(userInfo, appState: UIApplication.shared.applicationState)
    } else {
        completionHandler([.banner, .badge, .sound])
    }
}
```

- **Certificate requirement changed.** Freshchat accepted `.p12` or `.p8`. **Freshdesk supports only `.p8`** (Auth Key + Team ID), uploaded under Admin Settings → Mobile Chat SDK → Push Notification. A `.p12`-only app is push-blocked until a `.p8` key is generated — flag this in Step 1, not after the code migration is done.
- `isFreshdeskNotification` reads `userInfo["content"]["source"] == "freshdesk_user"` (was `"freshchat_user"`); it tolerates `content` as either a nested dictionary or a JSON-encoded string.
- Verified `handleRemoteNotification` branching: app active + Freshdesk widget already frontmost → does nothing (suppressed); app active + widget not frontmost → shows the SDK's own in-app banner, tap opens the topic; app not active → opens the relevant topic once ready. There is **no interception callback** — `onNotificationClicked`'s block-and-redirect behavior has no equivalent. If the app used it to gate navigation on login state or route through its own router, that flow cannot be reproduced; the only lever is to not call `handleRemoteNotification` at all for notifications you want fully suppressed (in which case Freshdesk won't show them either).
- `config.notificationSoundEnabled`: no toggle — sound/badge/alert presentation comes entirely from the app's own `UNUserNotificationCenter` authorization options and the APNs payload.
- `config.showNotificationBanner`: the in-app banner described above is **automatic** — Freshchat's opt-in flag becomes non-optional behavior with no suppress/restyle API.

## Analytics and event tracking

```swift
// Before
Freshchat.sharedInstance().trackEvent("checkout_completed", withProperties: ["order_id": "123", "amount": 99])

// After — payload values MUST be String
Freshdesk.trackUserEvents(name: "checkout_completed", payload: ["order_id": "123", "amount": "99"])
```

Stringify every numeric/boolean value — verified signature is `trackUserEvents(name: String, payload: [String: String]? = nil)`, not `[String: Any]`. There is no client-side validation and no global disable toggle (`eventsUploadEnabled` has no counterpart) — remove the calls instead of trying to flag-gate them. Server-side limits to mention if events start getting rejected (confirm current values with the Freshdesk admin): 121 unique event names per account, 32-char name, 32-char property key, 256-char value, 20 properties per event.

## SDK events

Verified against `FDConstants.swift` (declarations) and `SDKWebViewController+ReverseCommunication.swift` (actual emit sites — the payload types below are confirmed at the `.post()` call, not just inferred from the enum):

| `FDEvents` case | `Notification.Name` raw value | `notification.object` |
|---|---|---|
| `.userCreated` | `FRESHDESK_USER_CREATED` | `[String: Any]` — includes `alias` |
| `.unreadCount` | `FRESHDESK_UNREAD_MESSAGE_COUNT_CHANGED` | `Int` |
| `.messageSent` | `FRESHDESK_MESSAGE_SENT` | `[String: Any]` |
| `.messageReceived` | `FRESHDESK_MESSAGE_RECEIVED` | `[String: Any]` |
| `.downloadFile` | `FRESHDESK_DOWNLOAD_FILE` | `Any?` — in practice a file URL string, **not** a typed `Foundation.URL` |
| `.userCleared` | `FRESHDESK_USER_CLEARED` | `nil` |

`FDEvents` is `CaseIterable`:

```swift
for event in FDEvents.allCases {
    NotificationCenter.default.addObserver(self, selector: #selector(handle(_:)),
        name: Notification.Name(event.rawValue), object: nil)
}
```

- Only **3 of Freshchat's 45** `FCEvent` names have a Freshdesk analogue: `FCEventMessageSent` → `.messageSent`, `FCEventMessageReceive` → `.messageReceived`, `FCEventIdTokenStatusChange` → `FreshdeskJWTDelegate`. Everything else (FAQ/KB events, navigation, CSAT, rich messaging, calendar/booking, attachment upload/error events, link-tap events) has no migration path — if analytics depends on any of them, say so plainly rather than guessing a substitute.
- `.unreadCount`, `.userCreated`, `.userCleared`, `.downloadFile` are **new** — no Freshchat predecessor. Don't describe these as "migrated"; they're new behavior the app didn't have before.
- JWT/auth state is **not** an `FDEvents` case — it only arrives via `FreshdeskJWTDelegate` ([§JWT](#jwt-authentication)).
- `value(forEventProperty:)` / `FCEventProperty` has no equivalent — parse the `[String: Any]` payload yourself and treat its schema as unstable (it isn't documented as stable public API).

## Listeners and handlers

```swift
// Before — returns Bool; false = SDK falls back to default behavior
Freshchat.sharedInstance().customLinkHandler = { url in
    if url.absoluteString.hasPrefix("myapp://") { router.navigate(url); return true }
    return false
}

// After — returns Void; YOU are responsible for every URL now
Freshdesk.setCustomLinkHandler { url in
    if url.absoluteString.hasPrefix("myapp://") { router.navigate(url) }
    else { openInAppBrowser(url) }   // must handle the default case yourself
}
```

**Behavioral trap, not just a rename.** The Freshchat handler could fall back to default SDK behavior by returning `false`. Freshdesk's closure returns `Void` — once set, every URL is the app's responsibility. A migrated handler that no-ops on an unrecognized URL turns that link dead. Always keep a default branch that opens the URL. Verified: the handler is held **strongly** and is not gated by initialization (you may set it before `initialize`), unlike the equivalent on Android — watch for retain cycles, use `[weak self]` where relevant.

**Attachments open in Safari.** `WKUIDelegate.createWebViewWith` routes any new-tab request — including file attachments — to `UIApplication.shared.open(url:...)` unless a custom link handler is set (in which case the custom handler receives it instead). This is not configurable; Freshchat displayed attachments in a native in-app viewer. Flag it as a visible UX regression, don't try to route around it in code.

## Theming and appearance

**No code migration exists.** `config.themeName` + a custom `.plist` has no `FreshdeskSDKConfig` counterpart at all. Appearance (brand colors, button colors, agent profile display, layout) is delivered by remote configuration from the Freshdesk portal, inherited from the linked Web Chat Widget's appearance settings. Do not write Swift to try to reproduce this — surface it as a checklist item: inventory what the theme `.plist` overrode, work with the Freshdesk admin to reproduce as much as possible through the portal, and get design/product sign-off that per-asset customization (chat bubbles, icons, placeholder/error images) has no equivalent.

## Localization and content configuration

`config.stringsBundle` has no direct code equivalent; language selection moves to `FreshdeskSDKConfig.locale` (init-only — re-`initialize` to change it) and per-string overrides move to `ContentConfiguration`, a **new** capability Freshchat never had:

```swift
let content = ContentConfiguration(
    headers: HeaderContent(chat: "Talk to our team", faq: "Help Centre"),
    placeholders: PlaceholderContent(replyField: "Type your reply...")
)
let sdkConfig = FreshdeskSDKConfig(token: "…", host: "…", sdkId: "…", config: Configuration(content: content))
Freshdesk.initialize(with: sdkConfig)

// Or at runtime (persists to UserDefaults, triggers a widget re-init):
Freshdesk.setContentConfiguration(content)
Freshdesk.setContentConfiguration(ContentConfiguration())   // reset to widget defaults
```

### Content configuration field reference

Verified field-by-field against `SDKContentConfiguration.swift`:

| Type | Fields |
|---|---|
| `ContentConfiguration` | `headers`, `placeholders`, `privacyPolicySetting`, `actions`, `additionalFields: [String: AnyCodable]` |
| `HeaderContent` | `chat`, `faq`, `faqMessageUs`, `faqNotAvailable`, `faqSearchNotAvailable`, `faqThankyou`, `faqUseful`, `faqNotUseful`, `channelResponse`, `ticketForm`, `typicallyRepliesFewMinsFallback` |
| `ChannelResponseContent` | `offline`, `online` |
| `ChannelResponseOnlineContent` | `defaultMessage` (encoded as `"default"`), `minutes`, `hours` |
| `ChannelResponseTimeUnitContent` | `one`, `more` — time templates must contain the literal `{{time}}` placeholder |
| `TicketFormContent` | `title`, `listTitle`, `submitBtnTitle`, `confirmationMessage` |
| `PlaceholderContent` | `replyField`, `searchField` |
| `ActionContent` | `tabChat` |
| `PrivacyPolicyContent` | `privacyPolicyMessage`, `privacyPolicyLinkText`, `privacyPolicyLink` |

All fields are optional and default to `nil`; an omitted field keeps the widget default. `additionalFields` is the escape hatch for widget keys not yet modeled as typed properties.

## Diagnostics

```swift
Freshdesk.enableDebugLogs(true)
Freshdesk.runDiagnostics { report in print(report.prettyPrinted()) }
```

- `runDiagnostics(completion: @escaping (FDDiagnosticReport) -> Void)` — new capability, no Freshchat predecessor.
- `FDDiagnosticReport`: `sdkVersion`, `generatedAt`, `overall: FDDiagnosticStatus`, `checks: [FDDiagnosticCheck]`. `FDDiagnosticCheck`: `id`, `title`, `status`, `details`, `fixHint: String?`.
- **Verified release-build gating**: in a `DEBUG` build diagnostics always run; in a **release** build they are skipped (return a single `.skipped` check) unless `Freshdesk.enableDebugLogs(true)` has been called to set `isLogsEnabled = true`. Safe to ship either way.
- Secrets (account token, device token) are masked in `details` — the report is safe to log or attach to a support ticket.

## Config flags with no code equivalent

These `FreshchatConfig` properties have **no `FreshdeskSDKConfig` counterpart**. When migrating the init block (SKILL.md Step 4), flag every one the app set to a non-default value rather than silently dropping it:

| Freshchat property | Default | Freshdesk equivalent |
|---|---|---|
| `gallerySelectionEnabled` | true | Portal widget config |
| `cameraCaptureEnabled` | true | Portal widget config |
| `fileAttachmentEnabled` | true | Portal widget config |
| `teamMemberInfoVisible` | true | Portal widget config |
| `responseExpectationVisible` | true | Portal widget config; labels via `ContentConfiguration.headers.channelResponse` |
| `showNotificationBanner` | true | No toggle — the in-app banner is automatic |
| `notificationSoundEnabled` | true | No toggle — governed by `UNUserNotificationCenter` options + APNs payload |
| `eventsUploadEnabled` | true | No toggle — omit `trackUserEvents` calls instead |
| `errorLogsEnabled` | false | `shouldEnableLogs` at init, or `enableDebugLogs(_:)` |
| `themeName` | nil | NA in code — portal remote config |
| `stringsBundle` | nil | `ContentConfiguration` + init-only `locale` |
| `domain` | — | Replaced by `host` (full portal URL) |

## Appendix — Freshchat APIs confirmed absent from Freshdesk 1.4.1

Consolidated planning list. Every one of these needs the [Gap comment template](SKILL.md#gap-comment-template), not a rewrite:

| Freshchat API | Area |
|---|---|
| `identifyUser(withExternalID:restoreID:)` | Identity |
| `getUserIdTokenStatus()` | Identity |
| `setBotVariables(_:withBotSpecificVariables:)` | Bots |
| `FreshchatMessage` + `sendMessage(_:)` (tag and reference-ID forms) | Messaging |
| `ConversationOptions.filter(byTags:withTitle:)` | Filtering |
| `ConversationOptions.setTopicName(_:withReferenceID:)` | Parallel conversations |
| `showConversation(_:withTopicName:withConversationReferenceID:)` as a persisted thread | Parallel conversations |
| `FAQOptions` (all methods) | FAQ UI |
| `unreadCount(forTags:)` | Unread |
| `unreadCount(forTopic:forConversationReferenceID:)` | Unread |
| `openFreshchatDeeplink(_:viewController:)` | Navigation |
| `getFAQsControllerForEmbed` / `getConversationsControllerForEmbed` (+ `WithOptions:` variants) | UI embedding |
| `onNotificationClicked` block | Push |
| `config.notificationSoundEnabled` | Push |
| `FreshchatEvent` / `value(forEventProperty:)` typed event properties | Events |
| 42 of 45 `FCEvent` names (see [§Events](#sdk-events)) | Events |
| `config.themeName` + custom theme `.plist` | Theming |
| `config.stringsBundle`; runtime locale change | Localization |
| `updateConversationBannerMessage(_:)` | UI |

## Version reference

| | Freshchat iOS | Freshdesk iOS |
|---|---|---|
| Version | `6.5.0` | `1.4.1` |
| Module | `FreshchatSDK` | `FreshdeskSDK` |
| Public facade | `Freshchat.sharedInstance()` | `Freshdesk` (`= Freshworks.shared`, a global constant) |
| Distribution | CocoaPods or SPM | **SPM only** |
| Minimum iOS | 12.0 | **15.0** |
| Push certificate | `.p12` or `.p8` | **`.p8` only** |
| Third-party dependencies | — | None — Apple frameworks only |
