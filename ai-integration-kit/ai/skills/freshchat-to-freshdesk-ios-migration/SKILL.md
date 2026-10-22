---
name: freshchat-to-freshdesk-ios-migration
description: Migrate an iOS app from the legacy Freshchat iOS SDK (FreshchatSDK, CocoaPods or SPM) to the Freshdesk iOS SDK (FreshdeskSDK, SPM only). First migrates the dependency (Podfile/Package.swift/Xcode package list), then walks every Freshchat API call site and either rewrites it to the mapped Freshdesk API or, where no equivalent exists, leaves the original code in place commented out with a `FRESHCHAT-MIGRATION-GAP` marker so the app developer can decide what to do next. Use when the user mentions migrating from Freshchat to Freshdesk, replacing FreshchatSDK, `pod 'FreshchatSDK'`, `import FreshchatSDK`, `Freshchat.sharedInstance()`, FreshchatConfig, FreshchatUser, FreshchatMessage, FAQOptions, ConversationOptions, or asks to "move off Freshchat", "upgrade to the new Freshdesk SDK", or "port our chat SDK integration".
---

# Freshchat → Freshdesk iOS SDK Migration

This skill teaches an AI coding agent how to migrate a host iOS app off the legacy **Freshchat iOS SDK** (`FreshchatSDK`) onto the **Freshdesk iOS SDK** (`FreshdeskSDK`). It is a **re-integration**, not a version bump: the two SDKs have different architectures (native UI vs. embedded web widget, channels/tags vs. topics+tickets, synchronous init vs. queued async init, JWT-first identity). Treat every call site individually rather than doing a blind find-and-replace.

The migration has exactly two phases, always in this order:

1. **Dependency migration** — remove the Freshchat dependency (CocoaPods or SPM) and add the Freshdesk SPM dependency. The app must compile against `FreshdeskSDK` before any API-level work makes sense.
2. **API migration** — for every Freshchat API call site: if [api-mapping.md](api-mapping.md) has a Freshdesk equivalent, rewrite the call (adjusting types/async shape/argument order as required — these are rarely 1:1 renames). If it has **no** equivalent, do **not** delete the code: comment it out in place using the [Gap comment template](#gap-comment-template) below and leave the decision to the developer.

After migration, hand off to the **freshdesk-ios-integration** skill (same `ai/skills/` folder) for initialization Q&A details, JWT/push wiring, and `Freshdesk.runDiagnostics` triage — this skill focuses on getting *off* Freshchat; that skill focuses on getting Freshdesk fully working.

## When to use

- The app currently depends on `FreshchatSDK` (CocoaPods or SPM) and the user wants to move to `FreshdeskSDK`.
- The user asks to "migrate from Freshchat", "replace Freshchat with Freshdesk", "remove FreshchatSDK", or similar.
- The user mentions Freshchat symbols directly: `Freshchat.sharedInstance()`, `FreshchatConfig`, `FreshchatUser`, `FreshchatMessage`, `FAQOptions`, `ConversationOptions`, `FRESHCHAT_EVENTS`, `identifyUser(withExternalID:restoreID:)`, `pod 'FreshchatSDK'`, `import FreshchatSDK`.

Do NOT use this skill for:

- A fresh Freshdesk integration with no prior Freshchat code — use **freshdesk-ios-integration** (Mode A) instead.
- Debugging an already-Freshdesk-only app — use **freshdesk-ios-integration** (Mode B) instead.
- Any SDK other than Freshchat/Freshdesk iOS.

## Relationship to other tools in this kit

This skill and **freshdesk-ios-integration** are complementary, not overlapping:

| | freshchat-to-freshdesk-ios-migration (this skill) | freshdesk-ios-integration |
|---|---|---|
| Starting state | `FreshchatSDK` present | No SDK, or `FreshdeskSDK` already present |
| Job | Remove Freshchat, add Freshdesk, port every call site | Add Freshdesk from scratch, or debug an existing Freshdesk integration |
| Ends with | A build that compiles against `FreshdeskSDK` only, plus a list of unresolved gaps | A working, diagnosed integration |

Once dependency migration (Step 2) and the API loop (Step 5) are done, switch to **freshdesk-ios-integration** Mode B to run `Freshdesk.runDiagnostics` and finish wiring anything Step 5 flagged as needing portal/JWT/push input.

## Inputs

Ask one question at a time; do not assume defaults. Some of these only matter once the app compiles again and you switch to `freshdesk-ios-integration` — ask them here anyway so the developer isn't blocked mid-migration.

| Input | Why it matters | Where to get it |
|---|---|---|
| Account token, host URL, SDK ID | Required by `FreshdeskSDKConfig` at init | Freshdesk Admin Settings → Mobile Chat SDK → select SDK → App Keys |
| Does the widget enforce JWT? (yes / no / unknown) | `setUserDetails`/`setTicketProperties` silently no-op under enforcement — decides whether identity/property code must move into a JWT payload instead | Freshdesk Admin Settings → Mobile Chat SDK → JWT settings |
| Is the app still on an APNs `.p12` push certificate? | Freshdesk supports **`.p8` only** — a `.p12`-only app is push-blocked until a `.p8` key is generated | Apple Developer portal |
| Current CocoaPods or SPM setup | Decides the exact Step 2 procedure | `Podfile` / `Package.swift` / Xcode package list |
| Current deployment target | Freshdesk requires **iOS 15+** (Freshchat supported iOS 12+) — must be raised if lower | Xcode project settings |
| Any custom Freshchat theming (`themeName` `.plist`) or `stringsBundle`? | Neither carries over; appearance becomes Freshdesk-portal-driven remote config — this is often the single largest migration cost | Search the codebase for `config.themeName` / `config.stringsBundle` |
| Any usage of parallel conversations, tag filtering, embedded FAQ/conversations screens, `sendMessage`, or `setBotVariables`? | These have **no Freshdesk equivalent** (see api-mapping.md Appendix A) — flag early so product/design can sign off on the loss before code review, not after | Grep results from Step 0 |

If any answer is "unknown", proceed and let Step 0's codebase scan and Step 7's build/diagnostics fill the gap later.

## Steps

### Step 0: Detect the current state

Before changing anything, scan the workspace:

```bash
# Dependency manifests
grep -rn "FreshchatSDK" --include="Podfile" --include="Podfile.lock" .
grep -rn "freshchat" Package.swift Package.resolved 2>/dev/null
grep -rln "FreshchatSDK" --include="project.pbxproj" .

# Source usage
grep -rln "import FreshchatSDK" --include="*.swift" .
grep -rln "Freshchat\.sharedInstance\(\)" --include="*.swift" .
```

Decide:

- **Freshchat present, Freshdesk absent** → full migration. Start at Step 1.
- **Both present** → a migration is already in progress. Skip to Step 5 (API loop) and use `grep -rn "import FreshchatSDK"` to find what's left.
- **Freshdesk present, Freshchat absent** → nothing to migrate. Tell the user and suggest `freshdesk-ios-integration` if they want to verify or extend the integration instead.
- **Neither present** → this is a greenfield integration, not a migration. Hand off to `freshdesk-ios-integration` Mode A.

Also record every file that contains Freshchat usage — you will revisit each one in Step 5. A quick inventory of API symbols in use (cross-reference against api-mapping.md's "Freshchat symbol" column) tells you up front how many call sites are direct renames vs. gaps, which is worth sharing with the user before you start editing.

### Step 1: Confirm migration-affecting decisions

Ask the questions from the **Inputs** table above, one at a time. In particular, get an explicit answer on JWT enforcement and push certificate type before Step 4 — both change what the initialization code should look like, and getting them wrong means revisiting the same file twice.

### Step 2: Migrate the dependency

#### If the app uses CocoaPods

1. Remove the Freshchat line from `Podfile`:
   ```ruby
   # Remove:
   pod 'FreshchatSDK'
   ```
   If `FreshchatSDK` was the project's only pod, you may remove the CocoaPods integration entirely (`.xcworkspace` reverts to the plain `.xcodeproj`) — confirm with the user before doing this, since it changes the build system.
2. Run `pod install` (or ask the user to) to regenerate `Podfile.lock` and the workspace.
3. Delete any manually vendored `FreshchatSDK.xcframework`.
4. **Freshdesk is SPM-only** — CocoaPods cannot install it. In Xcode: File → Add Package Dependencies → `https://github.com/freshworks/freshdesk-ios-sdk` → add the `FreshdeskSDK` product to the app target. Adding SPM alongside an existing CocoaPods setup is supported by Xcode, but validate the build early since it is a build-system change, not just a dependency swap.

#### If the app uses Swift Package Manager

1. Remove the Freshchat package dependency:
   - **`Package.swift` project**: remove the `freshchat-ios` entry from `dependencies:` and from the target's `dependencies:` array.
   - **Xcode project (package list only)**: Project settings → Package Dependencies → remove the Freshchat package.
2. Add the Freshdesk package:
   ```swift
   .package(url: "https://github.com/freshworks/freshdesk-ios-sdk", from: "1.0.0"), // use the latest release tag from GitHub
   // ...
   .product(name: "FreshdeskSDK", package: "freshdesk-ios-sdk"),
   ```
   Or via Xcode: File → Add Package Dependencies with the same URL.

#### Either path

- Raise the deployment target to **iOS 15.0** if it is currently lower (Freshdesk's `Package.swift` declares `.iOS(.v15)`; SPM resolution fails below that). This may mean dropping support for devices the app currently serves — confirm with the user before raising it, since it is a product decision, not just a build setting.
- Delete the Freshchat theme `.plist` (referenced by `config.themeName`) and the `.strings` bundle (referenced by `config.stringsBundle`) — neither has a Freshdesk equivalent (see Step 6).
- Do not remove `import FreshchatSDK` yet if any source file still calls Freshchat APIs — that comes after Step 5, once every call site has been handled. Removing the dependency before the API loop leaves the project in a non-compiling state for longer than necessary; removing it after is the safer order for a large codebase, since the compiler's "cannot find type" errors become your worklist for Step 5.

### Step 3: Prepare for the rename pass

Do not blanket find-and-replace `import FreshchatSDK` → `import FreshdeskSDK` yet. Each file needs its call sites migrated first (Step 5), or the file won't compile between the import swap and the API rewrite. The exception is a file with zero Freshchat API calls beyond the import itself — safe to swap immediately.

### Step 4: Migrate the initialization block

This is almost always the highest-value, highest-risk single file (typically `AppDelegate`). Migrate it deliberately, not as part of the generic Step 5 loop, because the config object's shape changes completely.

```swift
// Before
let config = FreshchatConfig(appID: "APP-ID", andAppKey: "APP-KEY")
config.domain = "YOUR-DOMAIN"
config.gallerySelectionEnabled = true
config.cameraCaptureEnabled = true
config.fileAttachmentEnabled = true
config.teamMemberInfoVisible = true
config.showNotificationBanner = true
config.responseExpectationVisible = true
config.eventsUploadEnabled = true
config.notificationSoundEnabled = true
config.errorLogsEnabled = true
config.themeName = "MyFreshchatTheme"
config.stringsBundle = "MyFreshchatStrings"
Freshchat.sharedInstance().initWith(config)

// After
let sdkConfig = FreshdeskSDKConfig(
    token: "<account-token>",        // required — from Step 1
    host: "<host-url>",              // required
    sdkId: "<sdk-id>",               // required
    jwtToken: "<jwt-or-nil>",        // required if JWT enforcement is on (Step 1)
    locale: "<locale-or-nil>",       // init-only; nil = widget default
    shouldEnableLogs: true           // debug builds only; from your debug flag
)
Freshdesk.initialize(with: sdkConfig)
Freshdesk.setJWTDelegate(self)       // only if using JWT — see api-mapping.md §JWT
```

Every `FreshchatConfig` feature-toggle property in the "before" block above (`gallerySelectionEnabled`, `cameraCaptureEnabled`, `fileAttachmentEnabled`, `teamMemberInfoVisible`, `showNotificationBanner`, `responseExpectationVisible`, `eventsUploadEnabled`, `notificationSoundEnabled`) has **no `FreshdeskSDKConfig` counterpart** — behavior is now controlled by the linked Web Chat Widget's settings in the Freshdesk portal. Do not silently drop these: apply the [Gap comment template](#gap-comment-template) to the whole config block, listing which flags were set to a non-default value, so the developer can raise the equivalent portal configuration with their Freshdesk admin before cutover. See api-mapping.md's "Config flags with no code equivalent" table for the full list and portal-side equivalents.

`themeName` and `stringsBundle` get the same treatment — flag them, don't just delete them (see Step 6).

There is no readiness callback (`initializedCallback` equivalent) on iOS. Do not gate app UI on one; `Freshdesk.initialize(with:)` returns `Void` and queues most subsequent calls internally until the widget loads. See api-mapping.md's sequencing-contract note before assuming a call made right after `initialize` will be dropped — it usually won't be, but a small number of preconditions can still surface a user-visible alert.

### Step 5: Migrate every remaining API call site

For each file flagged in Step 0, and for each Freshchat symbol in it:

1. Look up the symbol in [api-mapping.md](api-mapping.md)'s mapping table.
2. **Direct or Changed** → rewrite the call site using the Freshdesk signature shown. Pay attention to: argument order changes (e.g. `openTopic`'s `topicId` comes before `topicName` and is `Int?`, not `String`), sync→async shape changes (`getUser` is now callback-based), and value-type narrowing (`trackUserEvents` payload values must be `String`, not `Any`).
3. **Gap (NA)** → do not delete the call. Comment it out using the template below, citing the specific capability from api-mapping.md and any workaround it documents.
4. Once every call in a file is handled, swap that file's `import FreshchatSDK` → `import FreshdeskSDK`.

Work file-by-file rather than symbol-by-symbol across the whole repo — a single call site's rewrite is usually not context-free (e.g. a `showConversations` call needs to know whether the enclosing code assumed synchronous return).

#### Gap comment template

When no Freshdesk equivalent exists, leave the original code in place, commented out, directly above or in place of where it ran, annotated like this:

```swift
// FRESHCHAT-MIGRATION-GAP: <short capability name, matches api-mapping.md>
// No Freshdesk iOS SDK equivalent exists as of SDK <version> (see api-mapping.md).
// Why it mattered here: <one line — what this call accomplished in the Freshchat flow>
// Suggested workaround: <the workaround from api-mapping.md, or "none" if api-mapping.md states none>
// Decision needed: keep this flow client-side without SDK support, redesign it, or drop it.
// Original Freshchat code (will not compile once FreshchatSDK is removed):
// let m1 = FreshchatMessage(message: "Need help with my order", andTag: "orders")
// Freshchat.sharedInstance().sendMessage(m1)
```

Use the exact marker string `FRESHCHAT-MIGRATION-GAP` on every occurrence — it is what the developer (or CI) greps for afterward:

```bash
grep -rn "FRESHCHAT-MIGRATION-GAP" --include="*.swift" .
```

Never invent a workaround that isn't in api-mapping.md. If api-mapping.md says "none", say "none" — do not guess at a clever substitute the SDK doesn't actually support.

### Step 6: Audit theming, localization, and portal-only features

These cannot be migrated in code at all — they require action in the Freshdesk portal, and the visual/behavioral result will differ regardless:

- **Theming** (`config.themeName` + custom `.plist`): there is no theming/appearance API in Freshdesk. Appearance is remote-configured from the linked Web Chat Widget in the portal. Flag this to the user as likely the single largest non-code migration cost; do not attempt to reproduce it in Swift.
- **Localization** (`config.stringsBundle`): replaced by `ContentConfiguration` (code-first, per-string overrides — see api-mapping.md) plus the init-only `locale` parameter. There is no runtime language switch; changing language requires re-`initialize`.
- **Feature toggles** (camera/gallery/file attachment, team-member info, response-expectation visibility, notification banner, event upload): all become portal widget configuration. List every one the app set to a non-default value (Step 4) so the user can hand that list to their Freshdesk admin.

Do not write speculative Swift code for any of these — there is nothing to write. Surface them as a checklist item instead.

### Step 7: Build, verify, and hand off

1. Confirm no source file still imports `FreshchatSDK` and the dependency is fully removed from `Podfile`/`Package.swift`.
2. Build the app. Fix any remaining compile errors — each one is either a missed call site (back to Step 5) or a type mismatch introduced during rewriting.
3. Run:
   ```bash
   grep -rn "FRESHCHAT-MIGRATION-GAP" --include="*.swift" .
   ```
   and include the count and locations in your final summary — these are the developer's open decisions, not migration failures.
4. Instruct the user to run the app, exercise the support entry point once, then call:
   ```swift
   Freshdesk.enableDebugLogs(true)
   Freshdesk.runDiagnostics { report in print(report.prettyPrinted()) }
   ```
5. Switch to the **freshdesk-ios-integration** skill (Mode B) to triage the diagnostics report and finish anything Step 1's Q&A flagged as still open (JWT wiring, push capability, content configuration).

## Output

When responding to the user, always include:

1. **Dependency change summary**: what was removed (CocoaPods pod / SPM package, vendored framework) and what was added (Freshdesk SPM package, URL, target).
2. **Deployment target change**, if any, and why (iOS 15 minimum).
3. **List of files modified**, grouped by what changed in each (import swap, direct API rewrite, gap comment inserted, init block rewrite).
4. **Full list of `FRESHCHAT-MIGRATION-GAP` markers inserted**, each with its file:line, the capability name, and the one-line "why it mattered" — this is the developer's decision list, not something you resolve on their behalf.
5. **Portal/product checklist** carried over from Step 6 (theming, localization, feature toggles) plus anything from Step 1 still unanswered (JWT enforcement, push certificate).
6. **Hand-off instruction**: build, run, exercise the support entry point, run `Freshdesk.runDiagnostics`, and switch to `freshdesk-ios-integration` for the rest.

Never invent a token, host, sdkId, JWT, or push key, and never invent a workaround for a gap that api-mapping.md marks as having none.

## Examples

For worked migration scenarios (CocoaPods app, SPM app, JWT-enforced app, an app that used `sendMessage`/`setBotVariables`), see [examples.md](examples.md).

## Reference

- Full API mapping table, Freshchat-symbol lookup, config-flag-to-portal table, `ContentConfiguration` field reference, and the "no Freshdesk equivalent" appendix: [api-mapping.md](api-mapping.md).
- Mobile SDK iOS setup guide: https://support.freshdesk.com/en/support/solutions/articles/50000011673-mobile-sdk-ios-setup-guide
- Enable JWT authentication: https://support.freshdesk.com/en/support/solutions/articles/50000011580-enable-jwt-authentication
- README and API surface: https://github.com/freshworks/freshdesk-ios-sdk/blob/main/README.md
- Post-migration integration, debugging, and diagnostics: the `freshdesk-ios-integration` skill in this same `ai/skills/` folder.
