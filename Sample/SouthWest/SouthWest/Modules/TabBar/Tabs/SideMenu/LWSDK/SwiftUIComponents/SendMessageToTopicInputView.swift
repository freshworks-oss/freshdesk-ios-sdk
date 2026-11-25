//
//  SendMessageToTopicInputView.swift
//  SouthWest
//
//  Input prompt used to test `Freshdesk.messageToTopic`.
//

import SwiftUI

struct SendMessageToTopicInputView: View {
    /// Called with `nil` when cancelled; otherwise with a validated request.
    let didDismiss: (_ request: SendMessageRequest?) -> Void

    struct SendMessageRequest {
        enum Topic {
            case id(Int)
            case name(String)
        }

        let topic: Topic
        let message: String
        let isDraft: Bool
    }

    @State private var topicIdText: String = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.topicIdForSendMessage) ?? Constants.Characters.emptyString
    @State private var topicNameText: String = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.topicNameForSendMessage) ?? Constants.Characters.emptyString
    @State private var message: String = Constants.Characters.emptyString
    @State private var isDraft: Bool = true
    @State private var errorMessage: String? = nil

    private var trimmedTopicId: String {
        topicIdText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedTopicName: String {
        topicNameText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedMessage: String {
        message.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        FeatureBackgroundView(
            heading: Constants.Features.SendMessageToTopic.title,
            subheading: Constants.Features.SendMessageToTopic.subheading,
            mainButtonTitle: Constants.Features.SendMessageToTopic.mainButton,
            dismissTapped: {
                didDismiss(nil)
            },
            mainButtonTapped: {
                sendTapped()
            },
            content: {
                VStack(alignment: .leading, spacing: 16) {
                    Text(Constants.Features.SendMessageToTopic.topicHint)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    FeatureTextfield(
                        title: Constants.Features.SendMessageToTopic.topicIdTitle,
                        placeholder: Constants.Features.SendMessageToTopic.topicIdPlaceholder,
                        content: $topicIdText
                    )
                    .keyboardType(.numberPad)

                    FeatureTextfield(
                        title: Constants.Features.SendMessageToTopic.topicNameTitle,
                        placeholder: Constants.Features.SendMessageToTopic.topicNamePlaceholder,
                        content: $topicNameText
                    )

                    FeatureTextfield(
                        title: Constants.Features.SendMessageToTopic.messageTitle,
                        placeholder: Constants.Features.SendMessageToTopic.messagePlaceholder,
                        content: $message
                    )

                    Toggle(Constants.Features.SendMessageToTopic.draftToggleTitle, isOn: $isDraft)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            })
    }

    private func sendTapped() {
        guard !trimmedMessage.isEmpty else {
            errorMessage = Constants.Features.SendMessageToTopic.missingMessageError
            return
        }

        let topic: SendMessageRequest.Topic
        if !trimmedTopicId.isEmpty {
            // Topic ID takes precedence when both are provided.
            guard let topicId = Int(trimmedTopicId) else {
                errorMessage = Constants.Features.SendMessageToTopic.invalidTopicIdError
                return
            }
            topic = .id(topicId)
        } else if !trimmedTopicName.isEmpty {
            topic = .name(trimmedTopicName)
        } else {
            errorMessage = Constants.Features.SendMessageToTopic.missingTopicError
            return
        }

        errorMessage = nil
        UserDefaults.standard.set(trimmedTopicId, forKey: Constants.UserDefaultsKeys.topicIdForSendMessage)
        UserDefaults.standard.set(trimmedTopicName, forKey: Constants.UserDefaultsKeys.topicNameForSendMessage)
        didDismiss(SendMessageRequest(topic: topic, message: message, isDraft: isDraft))
    }
}

#Preview {
    SendMessageToTopicInputView { _ in }
}
