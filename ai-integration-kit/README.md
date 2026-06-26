# Freshdesk iOS SDK — AI Integration Kit

This folder contains a reusable "skill" that teaches AI coding agents
(Cursor, Claude, GitHub Copilot, OpenAI Codex CLI, Kiro, etc.) how to
integrate, debug, and verify the **Freshdesk iOS SDK** in your iOS app.

The same skill content (`SKILL.md`) is duplicated into multiple
tool-specific locations so your AI tool of choice can discover it
automatically with no extra configuration.

## Prerequisites

Before integrating, confirm:

- Host app **iOS deployment target is 17 or newer** (FreshdeskSDK requires iOS 17).
- Access to **Admin Settings → Mobile Chat SDK** in your Freshdesk portal
  (account token, host URL, SDK ID).
- Optional: push notification setup (`.p8` Auth Key in the portal) and/or
  server-side JWT generation if your widget enforces authentication.

## Canonical source

Edit skill content in one place only:

```
ai-integration-kit/ai/skills/freshdesk-ios-integration/SKILL.md
```

Worked examples live alongside it in `examples.md`. After editing either
file, regenerate the tool-specific copies:

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

2. Open your project in your AI tool and ask (pick one that matches your tool):

   - **Any tool:** "Follow the Freshdesk iOS SDK integration skill in this
     repo and integrate FreshdeskSDK into my app."
   - **Cursor:** "Use the freshdesk-ios-integration skill and wire up
     Freshdesk support."
   - **Claude Code / CLI:** "Read CLAUDE.md and integrate FreshdeskSDK."
   - **GitHub Copilot:** "Follow the Freshdesk iOS integration instructions
     in .github/instructions/."

3. The agent will inspect your app, add the SwiftPM dependency, wire
   up `Freshdesk.initialize`, support entry points, push notifications,
   and JWT (only what your app actually needs), then call
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

## What the skill covers

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
