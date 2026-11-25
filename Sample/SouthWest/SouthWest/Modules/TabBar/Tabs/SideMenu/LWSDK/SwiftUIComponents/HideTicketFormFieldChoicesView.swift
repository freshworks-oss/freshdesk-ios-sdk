//
//  HideTicketFormFieldChoicesView.swift
//  SouthWest
//

import SwiftUI
import UIKit

struct HideTicketFormFieldChoicesView: View {

    let didDismiss: (_ formIdText: String, _ choicesJson: String, _ shouldSubmit: Bool) -> Void

    @State private var formId: String
    @State private var choicesJson: String

    init(didDismiss: @escaping (_ formIdText: String, _ choicesJson: String, _ shouldSubmit: Bool) -> Void) {
        self.didDismiss = didDismiss
        let storedId = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.hideTicketFormFieldChoicesFormId)
            ?? Constants.Characters.emptyString
        let storedPayload = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.hideTicketFormFieldChoicesPayloadJson)
        _formId = State(initialValue: storedId)
        _choicesJson = State(initialValue: storedPayload ?? Constants.Features.HideTicketFormFieldChoices.defaultChoicesJson)
    }

    var body: some View {
        FeatureBackgroundView(
            heading: Constants.Features.HideTicketFormFieldChoices.title,
            subheading: Constants.Features.HideTicketFormFieldChoices.subheading,
            mainButtonTitle: Constants.Features.HideTicketFormFieldChoices.mainButton,
            dismissTapped: {
                didDismiss(Constants.Characters.emptyString, Constants.Characters.emptyString, false)
            },
            mainButtonTapped: {
                let trimmedId = formId.trimmingCharacters(in: .whitespacesAndNewlines)
                let payload = choicesJson.trimmingCharacters(in: .whitespacesAndNewlines)
                UserDefaults.standard.set(trimmedId, forKey: Constants.UserDefaultsKeys.hideTicketFormFieldChoicesFormId)
                UserDefaults.standard.set(payload, forKey: Constants.UserDefaultsKeys.hideTicketFormFieldChoicesPayloadJson)
                didDismiss(trimmedId, payload, true)
            },
            content: {
                VStack(alignment: .leading, spacing: 16) {
                    FeatureTextfield(
                        title: Constants.Features.HideTicketFormFieldChoices.formIdTitle,
                        placeholder: Constants.Features.HideTicketFormFieldChoices.formIdPlaceholder,
                        keyboardType: UIKeyboardType.numberPad,
                        content: $formId
                    )
                    FeatureTextEditor(
                        title: Constants.Features.HideTicketFormFieldChoices.choicesPayloadTitle,
                        placeholder: Constants.Features.HideTicketFormFieldChoices.choicesPayloadPlaceholder,
                        description: Constants.Features.HideTicketFormFieldChoices.choicesPayloadDescription,
                        editorHeight: 200,
                        content: $choicesJson
                    )
                }
            })
    }
}
