//
//  SetConfigLocalisationView.swift
//  SouthWest
//
//  Originally created by Srivikashini Venkatachalam on 29/01/24.
//  Rewritten to provide a typed full-form input for the SDK
//  ContentConfiguration localisation API. Each TextField maps 1:1
//  to a property on ContentConfiguration / HeaderContent /
//  TicketFormContent / PlaceholderContent / ActionContent /
//  PrivacyPolicyContent. Empty fields are omitted so the widget
//  uses its own default value for that key.
//

import SwiftUI
import FreshdeskSDK

// Result emitted when the form is dismissed.
enum ContentConfigAction {
    case dismiss
    case applyRuntime(ContentConfiguration)
    case saveForNextLaunch(ContentConfiguration)
    case reset
}

struct SetConfigLocalisationView: View {

    let didDismiss: (ContentConfigAction) -> Void

    // MARK: Headers
    @State private var chat: String = ""
    @State private var faq: String = ""
    @State private var faqMessageUs: String = ""
    @State private var faqNotAvailable: String = ""
    @State private var faqSearchNotAvailable: String = ""
    @State private var faqThankyou: String = ""
    @State private var faqUseful: String = ""
    @State private var faqNotUseful: String = ""
    // Fallback shown when BE fails to deliver a dynamic response-expectation time.
    @State private var typicallyRepliesFallback: String = ""

    // MARK: Channel response (nested under headers)
    @State private var channelResponseOffline: String = ""

    // MARK: Channel response \u{2192} online
    // Default message when no specific time has been computed.
    @State private var onlineDefault: String = ""
    // Pluralised templates for minutes (one / more) — accept the {{time}} placeholder.
    @State private var onlineMinutesOne: String = ""
    @State private var onlineMinutesMore: String = ""
    // Pluralised templates for hours (one / more) — accept the {{time}} placeholder.
    @State private var onlineHoursOne: String = ""
    @State private var onlineHoursMore: String = ""

    // MARK: Ticket form (nested under headers)
    @State private var ticketTitle: String = ""
    @State private var ticketListTitle: String = ""
    @State private var ticketSubmitBtnTitle: String = ""
    @State private var ticketConfirmationMessage: String = ""

    // MARK: Placeholders
    @State private var replyField: String = ""
    @State private var searchField: String = ""

    // MARK: Actions
    @State private var tabChat: String = ""

    // MARK: Privacy policy
    @State private var privacyPolicyMessage: String = ""
    @State private var privacyPolicyLinkText: String = ""
    @State private var privacyPolicyLink: String = ""

    // MARK: Additional fields overflow (raw JSON)
    @State private var additionalFieldsJSON: String = ""

    // MARK: Local UI state
    @State private var validationMessage: String?

    var body: some View {
        FeatureBackgroundView(
            heading: Constants.Features.LocalisationConfig.title,
            subheading: Constants.Features.LocalisationConfig.subheading,
            mainButtonTitle: Constants.Features.LocalisationConfig.mainButton,
            dismissTapped: {
                didDismiss(.dismiss)
            },
            mainButtonTapped: {
                applyNowTapped()
            },
            content: {
                VStack(alignment: .leading, spacing: 12) {

                    sectionView(Constants.Features.LocalisationConfig.sectionHeaders) {
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.chatTitle,
                            placeholder: Constants.Features.LocalisationConfig.chatPlaceholder,
                            content: $chat
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.faqTitle,
                            placeholder: Constants.Features.LocalisationConfig.faqPlaceholder,
                            content: $faq
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.faqMessageUsTitle,
                            placeholder: Constants.Features.LocalisationConfig.faqMessageUsPlaceholder,
                            content: $faqMessageUs
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.faqNotAvailableTitle,
                            placeholder: Constants.Features.LocalisationConfig.faqNotAvailablePlaceholder,
                            content: $faqNotAvailable
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.faqSearchNotAvailableTitle,
                            placeholder: Constants.Features.LocalisationConfig.faqSearchNotAvailablePlaceholder,
                            content: $faqSearchNotAvailable
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.faqThankyouTitle,
                            placeholder: Constants.Features.LocalisationConfig.faqThankyouPlaceholder,
                            content: $faqThankyou
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.faqUsefulTitle,
                            placeholder: Constants.Features.LocalisationConfig.faqUsefulPlaceholder,
                            content: $faqUseful
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.faqNotUsefulTitle,
                            placeholder: Constants.Features.LocalisationConfig.faqNotUsefulPlaceholder,
                            content: $faqNotUseful
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.typicallyRepliesFallbackTitle,
                            placeholder: Constants.Features.LocalisationConfig.typicallyRepliesFallbackPlaceholder,
                            content: $typicallyRepliesFallback
                        )
                    }

                    sectionView(Constants.Features.LocalisationConfig.sectionChannelResponse) {
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.offlineTitle,
                            placeholder: Constants.Features.LocalisationConfig.offlinePlaceholder,
                            content: $channelResponseOffline
                        )
                    }

                    sectionView(Constants.Features.LocalisationConfig.sectionChannelResponseOnline) {
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.onlineDefaultTitle,
                            placeholder: Constants.Features.LocalisationConfig.onlineDefaultPlaceholder,
                            content: $onlineDefault
                        )
                    }

                    sectionView(Constants.Features.LocalisationConfig.sectionChannelResponseOnlineMinutes) {
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.onlineMinutesOneTitle,
                            placeholder: Constants.Features.LocalisationConfig.onlineMinutesOnePlaceholder,
                            content: $onlineMinutesOne
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.onlineMinutesMoreTitle,
                            placeholder: Constants.Features.LocalisationConfig.onlineMinutesMorePlaceholder,
                            content: $onlineMinutesMore
                        )
                    }

                    sectionView(Constants.Features.LocalisationConfig.sectionChannelResponseOnlineHours) {
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.onlineHoursOneTitle,
                            placeholder: Constants.Features.LocalisationConfig.onlineHoursOnePlaceholder,
                            content: $onlineHoursOne
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.onlineHoursMoreTitle,
                            placeholder: Constants.Features.LocalisationConfig.onlineHoursMorePlaceholder,
                            content: $onlineHoursMore
                        )
                    }

                    sectionView(Constants.Features.LocalisationConfig.sectionTicketForm) {
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.ticketTitleTitle,
                            placeholder: Constants.Features.LocalisationConfig.ticketTitlePlaceholder,
                            content: $ticketTitle
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.ticketListTitleTitle,
                            placeholder: Constants.Features.LocalisationConfig.ticketListTitlePlaceholder,
                            content: $ticketListTitle
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.ticketSubmitTitle,
                            placeholder: Constants.Features.LocalisationConfig.ticketSubmitPlaceholder,
                            content: $ticketSubmitBtnTitle
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.ticketConfirmationTitle,
                            placeholder: Constants.Features.LocalisationConfig.ticketConfirmationPlaceholder,
                            content: $ticketConfirmationMessage
                        )
                    }

                    sectionView(Constants.Features.LocalisationConfig.sectionPlaceholders) {
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.replyFieldTitle,
                            placeholder: Constants.Features.LocalisationConfig.replyFieldPlaceholder,
                            content: $replyField
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.searchFieldTitle,
                            placeholder: Constants.Features.LocalisationConfig.searchFieldPlaceholder,
                            content: $searchField
                        )
                    }

                    sectionView(Constants.Features.LocalisationConfig.sectionActions) {
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.tabChatTitle,
                            placeholder: Constants.Features.LocalisationConfig.tabChatPlaceholder,
                            content: $tabChat
                        )
                    }

                    sectionView(Constants.Features.LocalisationConfig.sectionPrivacy) {
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.privacyMessageTitle,
                            placeholder: Constants.Features.LocalisationConfig.privacyMessagePlaceholder,
                            content: $privacyPolicyMessage
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.privacyLinkTextTitle,
                            placeholder: Constants.Features.LocalisationConfig.privacyLinkTextPlaceholder,
                            content: $privacyPolicyLinkText
                        )
                        FeatureTextfield(
                            title: Constants.Features.LocalisationConfig.privacyLinkTitle,
                            placeholder: Constants.Features.LocalisationConfig.privacyLinkPlaceholder,
                            content: $privacyPolicyLink
                        )
                    }

                    sectionView(Constants.Features.LocalisationConfig.sectionAdditional) {
                        FeatureTextEditor(
                            title: Constants.Features.LocalisationConfig.additionalTitle,
                            placeholder: Constants.Features.LocalisationConfig.additionalPlaceholder,
                            description: Constants.Features.LocalisationConfig.additionalDescription,
                            content: $additionalFieldsJSON
                        )
                    }

                    if let validationMessage = validationMessage {
                        Text(validationMessage)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding(.horizontal, 4)
                    }

                    HStack(spacing: 12) {
                        Button(action: saveOnlyTapped) {
                            Text(Constants.Features.LocalisationConfig.saveButton)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, minHeight: 36)
                                .background(Color(Colors.darkBlue).opacity(0.15))
                                .foregroundColor(Color(Colors.darkBlue))
                                .cornerRadius(8)
                        }

                        Button(action: resetTapped) {
                            Text(Constants.Features.LocalisationConfig.resetButton)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, minHeight: 36)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        )
        .onAppear(perform: preloadFromPersistedConfig)
    }

    // MARK: - Section helper

    @ViewBuilder
    private func sectionView<Inner: View>(_ heading: String,
                                          @ViewBuilder content: () -> Inner) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(heading)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(Colors.darkBlue))
                .padding(.top, 6)
            content()
        }
    }

    // MARK: - Pre-population

    private func preloadFromPersistedConfig() {
        guard let persisted = UserDefaults.standard.sampleContentConfiguration else { return }

        if let headers = persisted.headers {
            chat = headers.chat ?? ""
            faq = headers.faq ?? ""
            faqMessageUs = headers.faqMessageUs ?? ""
            faqNotAvailable = headers.faqNotAvailable ?? ""
            faqSearchNotAvailable = headers.faqSearchNotAvailable ?? ""
            faqThankyou = headers.faqThankyou ?? ""
            faqUseful = headers.faqUseful ?? ""
            faqNotUseful = headers.faqNotUseful ?? ""
            typicallyRepliesFallback = headers.typicallyRepliesFewMinsFallback ?? ""
            channelResponseOffline = headers.channelResponse?.offline ?? ""
            // Preload nested response-expectation online templates if any
            let online = headers.channelResponse?.online
            onlineDefault = online?.defaultMessage ?? ""
            onlineMinutesOne = online?.minutes?.one ?? ""
            onlineMinutesMore = online?.minutes?.more ?? ""
            onlineHoursOne = online?.hours?.one ?? ""
            onlineHoursMore = online?.hours?.more ?? ""
            ticketTitle = headers.ticketForm?.title ?? ""
            ticketListTitle = headers.ticketForm?.listTitle ?? ""
            ticketSubmitBtnTitle = headers.ticketForm?.submitBtnTitle ?? ""
            ticketConfirmationMessage = headers.ticketForm?.confirmationMessage ?? ""
        }
        if let placeholders = persisted.placeholders {
            replyField = placeholders.replyField ?? ""
            searchField = placeholders.searchField ?? ""
        }
        if let actions = persisted.actions {
            tabChat = actions.tabChat ?? ""
        }
        if let privacy = persisted.privacyPolicySetting {
            privacyPolicyMessage = privacy.privacyPolicyMessage ?? ""
            privacyPolicyLinkText = privacy.privacyPolicyLinkText ?? ""
            privacyPolicyLink = privacy.privacyPolicyLink ?? ""
        }
        if !persisted.additionalFields.isEmpty,
           let data = try? JSONEncoder().encode(persisted.additionalFields),
           let pretty = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: pretty, options: [.prettyPrinted]),
           let str = String(data: prettyData, encoding: .utf8) {
            additionalFieldsJSON = str
        }
    }

    // MARK: - Build ContentConfiguration

    // Returns nil only when the additionalFields JSON is invalid; in that case
    // a `validationMessage` is set so the user can correct the input.
    private func buildContentConfiguration() -> ContentConfiguration? {
        validationMessage = nil

        let header = HeaderContent(
            chat: nilIfEmpty(chat),
            faq: nilIfEmpty(faq),
            faqMessageUs: nilIfEmpty(faqMessageUs),
            faqNotAvailable: nilIfEmpty(faqNotAvailable),
            faqSearchNotAvailable: nilIfEmpty(faqSearchNotAvailable),
            faqThankyou: nilIfEmpty(faqThankyou),
            faqUseful: nilIfEmpty(faqUseful),
            faqNotUseful: nilIfEmpty(faqNotUseful),
            channelResponse: channelResponseContent(),
            ticketForm: ticketFormContent(),
            typicallyRepliesFewMinsFallback: nilIfEmpty(typicallyRepliesFallback)
        )

        let placeholder = PlaceholderContent(
            replyField: nilIfEmpty(replyField),
            searchField: nilIfEmpty(searchField)
        )

        let action = ActionContent(tabChat: nilIfEmpty(tabChat))

        let privacy = PrivacyPolicyContent(
            privacyPolicyMessage: nilIfEmpty(privacyPolicyMessage),
            privacyPolicyLinkText: nilIfEmpty(privacyPolicyLinkText),
            privacyPolicyLink: nilIfEmpty(privacyPolicyLink)
        )

        var overflow: [String: FreshdeskSDK.AnyCodable] = [:]
        let trimmedJSON = additionalFieldsJSON.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedJSON.isEmpty {
            guard let parsed = parseAdditionalFields(trimmedJSON) else {
                validationMessage = Constants.Toast.invalidJson
                return nil
            }
            overflow = parsed
        }

        return ContentConfiguration(
            headers: header.isEmpty ? nil : header,
            placeholders: placeholder.isEmpty ? nil : placeholder,
            privacyPolicySetting: privacy.isEmpty ? nil : privacy,
            actions: action.isEmpty ? nil : action,
            additionalFields: overflow
        )
    }

    private func channelResponseContent() -> ChannelResponseContent? {
        let online = channelResponseOnlineContent()
        let offline = nilIfEmpty(channelResponseOffline)
        guard offline != nil || online != nil else { return nil }
        return ChannelResponseContent(offline: offline, online: online)
    }

    // Builds the nested online response-expectation block (default / minutes / hours).
    // Returns nil when no field has been entered, so the widget keeps its own default.
    private func channelResponseOnlineContent() -> ChannelResponseOnlineContent? {
        let minutes = ChannelResponseTimeUnitContent(
            one: nilIfEmpty(onlineMinutesOne),
            more: nilIfEmpty(onlineMinutesMore)
        )
        let hours = ChannelResponseTimeUnitContent(
            one: nilIfEmpty(onlineHoursOne),
            more: nilIfEmpty(onlineHoursMore)
        )
        let defaultMessage = nilIfEmpty(onlineDefault)
        let resolvedMinutes: ChannelResponseTimeUnitContent? = minutes.isEmpty ? nil : minutes
        let resolvedHours: ChannelResponseTimeUnitContent? = hours.isEmpty ? nil : hours
        guard defaultMessage != nil || resolvedMinutes != nil || resolvedHours != nil else {
            return nil
        }
        return ChannelResponseOnlineContent(
            defaultMessage: defaultMessage,
            minutes: resolvedMinutes,
            hours: resolvedHours
        )
    }

    private func ticketFormContent() -> TicketFormContent? {
        let tf = TicketFormContent(
            title: nilIfEmpty(ticketTitle),
            listTitle: nilIfEmpty(ticketListTitle),
            submitBtnTitle: nilIfEmpty(ticketSubmitBtnTitle),
            confirmationMessage: nilIfEmpty(ticketConfirmationMessage)
        )
        return tf.isEmpty ? nil : tf
    }

    // Parses the additionalFields JSON into [String: FreshdeskSDK.AnyCodable].
    // Returns nil when the input is not a valid JSON object.
    private func parseAdditionalFields(_ jsonString: String) -> [String: FreshdeskSDK.AnyCodable]? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        guard let decoded = try? JSONDecoder().decode([String: FreshdeskSDK.AnyCodable].self, from: data) else {
            return nil
        }
        return decoded
    }

    private func nilIfEmpty(_ string: String) -> String? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    // MARK: - Actions

    private func applyNowTapped() {
        guard let config = buildContentConfiguration() else { return }
        UserDefaults.standard.sampleContentConfiguration = config.isSampleEmpty ? nil : config
        didDismiss(.applyRuntime(config))
    }

    private func saveOnlyTapped() {
        guard let config = buildContentConfiguration() else { return }
        UserDefaults.standard.sampleContentConfiguration = config.isSampleEmpty ? nil : config
        didDismiss(.saveForNextLaunch(config))
    }

    private func resetTapped() {
        UserDefaults.standard.sampleContentConfiguration = nil
        didDismiss(.reset)
    }
}

// MARK: - Sub-struct emptiness helpers used by the form

extension HeaderContent {
    var isEmpty: Bool {
        chat == nil && faq == nil && faqMessageUs == nil &&
        faqNotAvailable == nil && faqSearchNotAvailable == nil &&
        faqThankyou == nil && faqUseful == nil && faqNotUseful == nil &&
        channelResponse == nil && ticketForm == nil &&
        typicallyRepliesFewMinsFallback == nil
    }
}

extension ChannelResponseTimeUnitContent {
    var isEmpty: Bool {
        one == nil && more == nil
    }
}

extension TicketFormContent {
    var isEmpty: Bool {
        title == nil && listTitle == nil &&
        submitBtnTitle == nil && confirmationMessage == nil
    }
}

extension PlaceholderContent {
    var isEmpty: Bool {
        replyField == nil && searchField == nil
    }
}

extension ActionContent {
    var isEmpty: Bool {
        tabChat == nil
    }
}

extension PrivacyPolicyContent {
    var isEmpty: Bool {
        privacyPolicyMessage == nil &&
        privacyPolicyLinkText == nil &&
        privacyPolicyLink == nil
    }
}

struct SetConfigLocalisationView_Previews: PreviewProvider {
    static var previews: some View {
        SetConfigLocalisationView { _ in }
    }
}
