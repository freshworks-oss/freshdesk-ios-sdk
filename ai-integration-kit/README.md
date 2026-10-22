# Freshdesk iOS SDK — AI Integration Kit

This folder contains reusable "skills" that teach AI coding agents
(Cursor, Claude, GitHub Copilot, OpenAI Codex CLI, Kiro, etc.) how to
integrate, debug, migrate, and verify the **Freshdesk iOS SDK** in your
iOS app:

| Skill | Use it when |
|---|---|
| [`freshchat-to-freshdesk-ios-migration`](ai/skills/freshchat-to-freshdesk-ios-migration/SKILL.md) | Your app currently depends on the legacy **Freshchat iOS SDK** and you want to move to Freshdesk. Migrates the dependency (CocoaPods/SPM → Freshdesk SPM) first, then every Freshchat API call site — rewriting what maps and commenting out, with a `FRESHCHAT-MIGRATION-GAP` marker, what doesn't. |
| [`freshdesk-ios-integration`](ai/skills/freshdesk-ios-integration/SKILL.md) | Your app has no chat SDK yet, or already has `FreshdeskSDK` and you want to add/debug/verify the integration. |

If you're migrating from Freshchat, start with the migration skill and
hand off to the integration skill afterward for JWT/push wiring and
`Freshdesk.runDiagnostics` triage — see that skill's "Relationship to
other tools in this kit" section.

Each skill's content (`SKILL.md`, plus its own reference files) is
duplicated into multiple tool-specific locations so your AI tool of
choice can discover it automatically with no extra configuration.

## Prerequisites

Before integrating, confirm:

- Host app **iOS deployment target is 15 or newer** (FreshdeskSDK requires iOS 15).
- Access to **Admin Settings → Mobile Chat SDK** in your Freshdesk portal
  (account token, host URL, SDK ID).
- Optional: push notification setup (`.p8` Auth Key in the portal) and/or
  server-side JWT generation if your widget enforces authentication.

## Canonical source

Edit skill content in one place only, under each skill's own folder:

```
ai-integration-kit/ai/skills/freshchat-to-freshdesk-ios-migration/SKILL.md
ai-integration-kit/ai/skills/freshdesk-ios-integration/SKILL.md
```

Worked examples live alongside each `SKILL.md` in `examples.md`; the
migration skill additionally has `api-mapping.md`, the full Freshchat →
Freshdesk API reference it relies on. After editing any of these files,
regenerate the tool-specific copies:

```bash
cd ai-integration-kit && ./sync.sh
```

The sync script copies `SKILL.md` into `AGENTS.md`, `CLAUDE.md`, Cursor,
Copilot, and Kiro paths listed below. Commit both the canonical files and
the generated copies so customers can copy the kit as-is.

## How to use it

1. Copy the **contents** of this folder into the **root of your iOS app
   repository** (the directory that contains your `.xcodeproj`,
   `Package.swift`, or `Podfile`):

   ```
   your-ios-app/
   ├── AGENTS.md                  ← from this kit
   ├── CLAUDE.md                  ← from this kit
   ├── .cursor/                   ← from this kit
   ├── .github/                   ← merge with your existing .github if any
   ├── .kiro/                     ← from this kit
   ├── ai/                        ← from this kit
   └── ...your existing app files
   ```

   If a folder already exists in your app repo (for example `.github/`),
   merge the contents instead of overwriting it.

2. Open your project in your AI tool and ask (pick one that matches your tool and your starting point):

   - **Migrating off Freshchat:** "Follow the freshchat-to-freshdesk-ios-migration
     skill in this repo and migrate my app from FreshchatSDK to FreshdeskSDK."
   - **Any tool, fresh integration:** "Follow the Freshdesk iOS SDK integration
     skill in this repo and integrate FreshdeskSDK into my app."
   - **Cursor:** "Use the freshdesk-ios-integration skill and wire up
     Freshdesk support." (or `freshchat-to-freshdesk-ios-migration` if migrating)
   - **Claude Code / CLI:** "Read CLAUDE.md and integrate FreshdeskSDK."
   - **GitHub Copilot:** "Follow the Freshdesk iOS integration instructions
     in .github/instructions/."

3. If you're migrating, the agent will first remove the Freshchat
   dependency and add the Freshdesk SwiftPM dependency, then rewrite each
   Freshchat API call site it finds — leaving anything with no Freshdesk
   equivalent commented out with a `FRESHCHAT-MIGRATION-GAP` marker for you
   to decide on. Either way, the agent ends by wiring up
   `Freshdesk.initialize`, support entry points, push notifications, and
   JWT (only what your app actually needs), then calls
   `Freshdesk.runDiagnostics` to verify the setup.

## Tool → file mapping

| AI tool                                    | File the tool reads automatically                                |
|--------------------------------------------|------------------------------------------------------------------|
| Cursor                                     | `.cursor/skills/freshdesk-ios-integration/SKILL.md`              |
| Claude (Code / CLI / agents)               | `CLAUDE.md` (and `ai/skills/freshdesk-ios-integration/SKILL.md`) |
| OpenAI Codex CLI / generic AGENTS.md tools | `AGENTS.md`                                                      |
| GitHub Copilot                             | `.github/instructions/freshdesk-ios-integration.instructions.md` |
| Kiro                                       | `.kiro/steering/freshdesk-ios-integration.md`                    |
| Other / unknown                            | `ai/skills/freshdesk-ios-integration/SKILL.md`                   |

All duplicated files contain the **same** content as the canonical
`SKILL.md`. You can keep just the paths your AI tool understands and
delete the rest.

## Troubleshooting

| Problem | What to check |
|---------|---------------|
| Cursor does not apply the skill | Confirm `.cursor/skills/freshdesk-ios-integration/SKILL.md` exists in your app repo root. Mention `FreshdeskSDK` or `freshdesk-ios-integration` in your prompt. |
| Copilot ignores the instructions | Confirm `.github/instructions/freshdesk-ios-integration.instructions.md` is present. Merge into `.github/` without overwriting your existing Copilot config. |
| Agent edits the wrong copy | Edit `ai/skills/freshdesk-ios-integration/SKILL.md` in the SDK repo, run `./sync.sh`, then re-copy the kit into your app. |
| Diagnostics report is empty or minimal | Call `Freshdesk.enableDebugLogs(true)` before `Freshdesk.runDiagnostics`, and ensure `Freshdesk.initialize(with:)` has run at least once. |

## What the skills cover

`freshchat-to-freshdesk-ios-migration`:

- **Dependency migration** — removes the Freshchat CocoaPods pod or SPM
  package and adds the Freshdesk SPM package, raising the deployment
  target to iOS 15 if needed.
- **API migration** — walks every Freshchat call site; rewrites what has
  a Freshdesk equivalent (adjusting types/async shape/argument order as
  needed, not a blind rename) and comments out, with a
  `FRESHCHAT-MIGRATION-GAP` marker, whatever doesn't (parallel
  conversations, `sendMessage`, theming, and more — see its
  `api-mapping.md` for the full list).

`freshdesk-ios-integration`:

- **Greenfield mode** — SDK not yet in your app. The agent asks where
  to wire support entry points, push, JWT, and optional content
  configuration / localisation (`ContentConfiguration`), then writes the
  code in the right files (AppDelegate, view controller / SwiftUI view).
- **Diagnostics-driven debug mode** — SDK already integrated. The agent
  runs `Freshdesk.runDiagnostics`, reads the `FDDiagnosticReport`, and
  applies each check's `fixHint` verbatim.

## After integration

Always re-run diagnostics to confirm a clean baseline:

```swift
Freshdesk.enableDebugLogs(true)
Freshdesk.runDiagnostics { report in
    print(report.prettyPrinted())
}
```

The report masks all secrets (account token, JWT, APNs token, device
token) so it is safe to share with your AI tool or with Freshdesk
support.

## Reference

- Mobile SDK iOS setup guide:
  https://support.freshdesk.com/en/support/solutions/articles/50000011673-mobile-sdk-ios-setup-guide
- Enable JWT authentication:
  https://support.freshdesk.com/en/support/solutions/articles/50000011580-enable-jwt-authentication
- README and API surface:
  https://github.com/freshworks-oss/freshdesk-ios-sdk/blob/main/README.md
