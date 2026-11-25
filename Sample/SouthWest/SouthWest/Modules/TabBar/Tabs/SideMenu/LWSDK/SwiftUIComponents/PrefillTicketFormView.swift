//
//  PrefillTicketFormView.swift
//  SouthWest
//

import SwiftUI
import UIKit

struct PrefillTicketFormView: View {

    let didDismiss: (_ formIdText: String, _ fieldsJson: String, _ shouldSubmit: Bool) -> Void

    @State private var formId: String
    @State private var fieldsJson: String

    init(didDismiss: @escaping (_ formIdText: String, _ fieldsJson: String, _ shouldSubmit: Bool) -> Void) {
        self.didDismiss = didDismiss
        let storedId = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.prefillTicketFormId)
            ?? Constants.Characters.emptyString
        let storedPayload = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.prefillTicketFormPayloadJson)
        _formId = State(initialValue: storedId)
        _fieldsJson = State(initialValue: storedPayload ?? Constants.Features.PrefillTicketForm.defaultFieldsJson)
    }

    var body: some View {
        FeatureBackgroundView(
            heading: Constants.Features.PrefillTicketForm.title,
            subheading: Constants.Features.PrefillTicketForm.subheading,
            mainButtonTitle: Constants.Features.UpdateConvOrBotAttributesView.mainButton,
            dismissTapped: {
                didDismiss(Constants.Characters.emptyString, Constants.Characters.emptyString, false)
            },
            mainButtonTapped: {
                let trimmedId = formId.trimmingCharacters(in: .whitespacesAndNewlines)
                let payload = fieldsJson.trimmingCharacters(in: .whitespacesAndNewlines)
                UserDefaults.standard.set(trimmedId, forKey: Constants.UserDefaultsKeys.prefillTicketFormId)
                UserDefaults.standard.set(payload, forKey: Constants.UserDefaultsKeys.prefillTicketFormPayloadJson)
                didDismiss(trimmedId, payload, true)
            },
            content: {
                VStack(alignment: .leading, spacing: 16) {
                    FeatureTextfield(
                        title: Constants.Features.PrefillTicketForm.formIdTitle,
                        placeholder: Constants.Features.PrefillTicketForm.formIdPlaceholder,
                        keyboardType: UIKeyboardType.numberPad,
                        content: $formId
                    )
                    FeatureTextEditor(
                        title: Constants.Features.PrefillTicketForm.fieldsPayloadTitle,
                        placeholder: Constants.Features.PrefillTicketForm.fieldsPayloadPlaceholder,
                        description: Constants.Features.PrefillTicketForm.fieldsPayloadDescription,
                        editorHeight: 200,
                        content: $fieldsJson
                    )
                }
            })
    }
}
