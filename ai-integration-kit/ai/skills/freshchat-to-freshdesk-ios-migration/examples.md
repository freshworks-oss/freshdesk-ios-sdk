# Freshchat → Freshdesk iOS Migration — Examples

Worked scenarios for the [migration skill](SKILL.md). Each references [api-mapping.md](api-mapping.md) rather than repeating its tables.

## Example 0: CocoaPods app, straightforward migration

User: "We have `pod 'FreshchatSDK'` in our Podfile. Migrate us to Freshdesk."

1. Step 0 detection: `grep -rn "FreshchatSDK" Podfile` finds `pod 'FreshchatSDK'`; `grep -rln "import FreshchatSDK" --include="*.swift" .` finds 4 files: `AppDelegate.swift`, `SupportViewController.swift`, `UserSessionManager.swift`, `PushHandler.swift`.
2. Step 1 Q&A (one at a time): "Is your widget JWT-enforced?" → "no". "Still on a `.p12` push cert?" → "yes, we'll need a `.p8`." "Current deployment target?" → "iOS 13" (must rise to 15 — confirmed acceptable).
3. Step 2 (CocoaPods path): remove `pod 'FreshchatSDK'` from `Podfile`, run `pod install`. Add the Freshdesk SPM package (`https://github.com/freshworks/freshdesk-ios-sdk`) via Xcode → File → Add Package Dependencies. Raise deployment target to iOS 15.
4. Step 4: rewrite `AppDelegate.swift`'s init block per [api-mapping.md §Entry point](api-mapping.md#entry-point-and-initialization). The old config had `cameraCaptureEnabled = true` and `fileAttachmentEnabled = true` — flag both with a Gap comment pointing at the config-flags table, since neither has a code equivalent; note in the summary that these need portal configuration instead.
5. Step 5: work through the remaining 3 files.
   - `SupportViewController.swift`: `showConversations(self)` → `openSupport(self)` (direct rewrite, flag the screen-identity change per api-mapping.md).
   - `UserSessionManager.swift`: `setUser`/`setUserProperties` → single `setUserDetails(with:)`; `resetUserWithCompletion:` → `resetUser(onSuccess:onFailure:)` with both branches clearing app session.
   - `PushHandler.swift`: `setPushRegistrationToken`, `isFreshchatNotification` → `isFreshdeskNotification`, `handleRemoteNotification(_:andAppstate:)` → `handleRemoteNotification(_:appState:)`.
6. Once every file's calls are handled, swap `import FreshchatSDK` → `import FreshdeskSDK` in all 4 files.
7. Step 7: build. Report: 0 `FRESHCHAT-MIGRATION-GAP` markers (this app used no gap APIs), 4 files changed, portal checklist = raise the `.p8` push key and confirm iOS 15 minimum with the team. Hand off to `freshdesk-ios-integration` to wire push capability and run diagnostics.

## Example 1: SPM app with a parallel-conversations feature (a real gap)

User: "We use `Package.swift` with the `freshchat-ios` package, and we open a per-order conversation thread with `showConversation(_:withTopicName:withConversationReferenceID:)`."

1. Step 0: SPM project — `freshchat-ios` found in `Package.swift`'s `dependencies:`. One call site in `OrderDetailViewController.swift`:
   ```swift
   Freshchat.sharedInstance().showConversation(self, withTopicName: "orders", withConversationReferenceID: order.id)
   ```
2. Step 2: remove the `freshchat-ios` entry from `Package.swift`, add `.package(url: "https://github.com/freshworks/freshdesk-ios-sdk", from: "1.0.0")` and the `FreshdeskSDK` product to the target's dependencies.
3. Step 5: `api-mapping.md`'s Quick Lookup marks `showConversation(_:withTopicName:withConversationReferenceID:)` as a **Gap (partial)** — `openTopic` pre-selects a topic but is not a persisted per-reference thread and has no independent unread count. This is a product-visible behavior loss, not a pure rename. Apply the recommended migration path from [api-mapping.md §Opening the UI](api-mapping.md#opening-the-sdk-ui):
   ```swift
   // FRESHCHAT-MIGRATION-GAP: Parallel conversations by reference ID
   // No Freshdesk iOS SDK equivalent exists as of SDK 1.4.1 (see api-mapping.md).
   // Why it mattered here: opened a persisted, independently-threaded conversation scoped to this order,
   // with its own unread count, so a customer could have simultaneous open threads for different orders.
   // Suggested workaround: carry the order as ticket metadata instead of a separate thread — you lose the
   // independent thread and the per-order unread count.
   // Decision needed: accept the coarser single-topic experience, or escalate to the Freshworks product
   // team since a commented-out `Freshdesk.openConversation(...)` call already exists in this SDK's own
   // Sample app (OrderItemView.swift), suggesting this may be on a roadmap.
   // Original Freshchat code (will not compile once FreshchatSDK is removed):
   // Freshchat.sharedInstance().showConversation(self, withTopicName: "orders", withConversationReferenceID: order.id)
   Freshdesk.setTicketProperties(with: ["order_id": order.id])
   Freshdesk.openTopic(self, topicId: nil, topicName: "Order Support")
   ```
4. Report this as one `FRESHCHAT-MIGRATION-GAP` marker with a concrete workaround applied alongside it (not just a stub) — this is the workaround path, so both the comment and a working substitute exist. Note in the output that per-order unread counts are lost regardless of which path the developer picks.

## Example 2: JWT-enforced app — silent no-op trap

User: "Our widget enforces JWT. We call `Freshchat.sharedInstance().setUserWithIdToken(jwt)` at login and `setUserProperties` right after to set the user's plan tier."

1. Step 1: JWT enforcement = yes. This changes how Step 4 and Step 5 must treat every identity/property call site — not just a rename.
2. Step 4: init block gets `jwtToken: jwt` (or `nil` if the JWT isn't available yet at launch), plus `Freshdesk.setJWTDelegate(self)`.
3. Step 5: `setUserWithIdToken(jwt)` → `authenticateAndUpdate(jwt: jwt)` at login (verified: **not** gated by JWT enforcement, per api-mapping.md §JWT). But the immediately-following `setUserProperties(["plan": "premium"])` call is a trap: `api-mapping.md` §Identity states `setUserDetails`/`setTicketProperties` **return early and do nothing** under JWT enforcement — no throw, no callback. Do not simply rename this call; flag it:
   ```swift
   // FRESHCHAT-MIGRATION-GAP: setUserProperties under JWT enforcement
   // Freshdesk.setUserDetails(with:) exists but silently no-ops when the widget enforces JWT
   // (verified: Freshworks.swift checks userAuthenticationEnforcedState == .enabled and returns
   // before doing anything — no error surfaces to the app or the user).
   // Why it mattered here: set the "plan" property so it appeared on the ticket/contact record.
   // Suggested workaround: put "plan" in the JWT payload your backend signs, not in a setUserDetails call.
   // Decision needed: confirm with backend team that the JWT claims include this field before removing
   // the Freshchat call below.
   // Original Freshchat code (will not compile once FreshchatSDK is removed):
   // Freshchat.sharedInstance().setUserProperties(["plan": "premium"])
   ```
4. Report this prominently in the output — a call that used to work and now silently does nothing is exactly the kind of regression that won't show up until a customer complains their plan tier isn't visible to support.

## Example 3: Events observer — one notification becomes six

User: "We have a single `FRESHCHAT_EVENTS` observer that switches on `event.name`."

```swift
// Before
NotificationCenter.default.addObserver(self, selector: #selector(handleFreshchatEvent(_:)),
    name: NSNotification.Name(rawValue: FRESHCHAT_EVENTS), object: nil)

@objc func handleFreshchatEvent(_ notification: NSNotification) {
    guard let event = notification.userInfo?["event"] as? FreshchatEvent else { return }
    switch event.name {
    case FCEventMessageSent: logSent(event.value(forEventProperty: FCPropertyChannelName))
    case FCEventIdTokenStatusChange: refreshAuthState()
    case FCEventFAQOpen: trackFAQOpen()
    default: break
    }
}
```

1. Consult [api-mapping.md §Events](api-mapping.md#sdk-events): only `FCEventMessageSent`/`FCEventMessageReceive`/`FCEventIdTokenStatusChange` have Freshdesk analogues. `FCEventFAQOpen` does not — it's in the 42-of-45 lost-events list.
2. Rewrite the observer registration and the message-sent branch (direct mapping), route the token-status branch to `FreshdeskJWTDelegate` instead of an event case, and apply the Gap comment template to the FAQ-open branch:
   ```swift
   for event in FDEvents.allCases {
       NotificationCenter.default.addObserver(self, selector: #selector(handleFreshdeskEvent(_:)),
           name: Notification.Name(event.rawValue), object: nil)
   }

   @objc func handleFreshdeskEvent(_ notification: NSNotification) {
       switch notification.name.rawValue {
       case FDEvents.messageSent.rawValue:
           if let message = notification.object as? [String: Any] { logSent(message) }
       // FRESHCHAT-MIGRATION-GAP: FAQ-open event tracking
       // No FDEvents case exists for FAQ article opens as of SDK 1.4.1 (see api-mapping.md §Events —
       // FAQ/KB events are among the 42 of 45 FCEvent names with no Freshdesk equivalent).
       // Why it mattered here: fed FAQ engagement into our analytics funnel.
       // Suggested workaround: none identified in api-mapping.md.
       // Decision needed: drop this metric, or get analytics sign-off before cutover per SKILL.md Step 6.
       // Original Freshchat code:
       // case FCEventFAQOpen: trackFAQOpen()
       default: break
       }
   }
   ```
   The old `FCEventIdTokenStatusChange` branch moves entirely out of this method — call `Freshdesk.setJWTDelegate(self)` in the init block (Step 4) and implement `userStateChanged(_:)` there instead of inside this notification handler.
3. Report: 1 gap marker (FAQ tracking), 2 direct rewrites, 1 relocated to a different mechanism (delegate, not notification) — call that relocation out explicitly in the summary so the developer doesn't go looking for it in the notification handler later.

## Example 4: `sendMessage` — a gap with a behaviorally-different workaround

User: "On our 'Report a problem' screen we pre-fill and send the first message for the user with `sendMessage`."

```swift
// Before
let m = FreshchatMessage(message: "App crashed on checkout, order #\(orderId)", andTag: "bug-report")
Freshchat.sharedInstance().sendMessage(m)
```

1. `api-mapping.md` §Messaging: confirmed no equivalent. The workaround is not equivalent behavior — `setTicketProperties` + `openTopic` requires the user to actually send a message before the properties reach Freshdesk, whereas `sendMessage` created the conversation immediately with no user action.
2. Apply the Gap comment template with that behavioral caveat spelled out, plus the best-effort workaround underneath it (not a silent drop, since a reasonable substitute exists — just not an equivalent one):
   ```swift
   // FRESHCHAT-MIGRATION-GAP: Programmatic message sending
   // No Freshdesk iOS SDK equivalent exists as of SDK 1.4.1 (see api-mapping.md §Messaging and bots).
   // Why it mattered here: pre-filled and immediately sent a bug-report message with no user action needed.
   // Suggested workaround (NOT equivalent — requires the user to send a message before this reaches
   // Freshdesk, unlike the original which sent immediately):
   Freshdesk.setTicketProperties(with: ["order_id": orderId, "issue": "checkout_crash"])
   Freshdesk.openTopic(self, topicId: nil, topicName: "Bug Report")
   // Decision needed: is requiring the user to type a message (even a generic "please describe what
   // happened") acceptable here, or should this flow be redesigned?
   // Original Freshchat code (will not compile once FreshchatSDK is removed):
   // let m = FreshchatMessage(message: "App crashed on checkout, order #\(orderId)", andTag: "bug-report")
   // Freshchat.sharedInstance().sendMessage(m)
   ```
3. Report this gap with the behavioral caveat highlighted — this is exactly the kind of change that looks like it "works" (code compiles, ticket properties get set) but silently changes the UX in a way product should sign off on.
