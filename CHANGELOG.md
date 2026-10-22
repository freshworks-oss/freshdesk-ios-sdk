# Changelog

All notable changes to the Freshdesk iOS SDK are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!--
HOW TO USE (for developers):
  Add your change under "## [Unreleased]" in the appropriate category
  (Added / Changed / Deprecated / Removed / Fixed / Security) in every feature PR.
  At release time the pipeline promotes "[Unreleased]" to "[<version>] - <date>"
  and uses that section as the GitHub Release notes. Do NOT hand-edit versions below.
-->

## [Unreleased]

## [1.4.2] - 2026-10-22
#### Bug Fixes
- Fixed a crash that occurred when SDK APIs were called before SDK initialization.

#### Enhancements
- Added AI Agent-assisted migration support through the freshchat-to-freshdesk-ios-migration skill, enabling AI-assisted implementation of the Freshchat to Freshdesk iOS SDK migration.

## [1.2.0]
### Added
- Support to override the SDK's built-in default static strings, including customizing additional locales beyond the default language through locale string overrides configured during SDK initialization.

## [1.1.3]
### Fixed
- Fixed an issue where tapping a push notification while the app was in a killed state did not navigate to the ticket detail page.

## [1.1.2]
### Fixed
- Fix for intermittent inconsistencies in push token registration where registration fails.

## [1.1.1]
### Fixed
- Fixed an issue in the JWT authentication flow where the `authenticate` event was not emitted by the SDK for a new user.

## [1.1.0]
### Added
- A flag in initialisation to support debug logs.
### Fixed
- Resolved an issue affecting push notifications specifically during the user restore.
- Minor bug fixes and improvements.

## [1.0.0]
First public release of the Mobile Chat SDK.
### Added
- Live Chat with AI & Support Agents.
- FAQ Support displayed natively within the SDK.
- Secure JWT-based authentication and authorization.
- Realtime push notifications.
- Localization support.
- Away experience — customers can raise chat or email tickets outside business hours.

## [0.2.0]
### Changed
- `FRESHDESK_CSAT_UPDATED` and `FRESHDESK_CSAT_RECEIVED` events are deprecated.
### Added
- Real-time agent message notifications in tickets.
- Better feedback and error handling with the Reset user API.
### Fixed
- Improvements in the AuthenticateAndUpdate API and other minor improvements.

## [0.1.0]
### Added
- Chat with the end agent.
- FAQ support.
- Set User, Get User, Reset User.
- Secure user authentication and authorization via JWT.
- Unread message counts.
- Localization support.
- `trackUserEvents(name:payload:)` for custom event tracking.
- `getSDKVersion() -> String`.
- `dismissFreshworksSDKViews()`.
- Messenger events: FRESHDESK_USER_CREATED, FRESHDESK_UNREAD_MESSAGE_COUNT_CHANGED, FRESHDESK_MESSAGE_SENT, FRESHDESK_MESSAGE_RECEIVED, FRESHDESK_CSAT_UPDATED, FRESHDESK_CSAT_RECEIVED, FRESHDESK_DOWNLOAD_FILE, FRESHDESK_USER_CLEARED.
