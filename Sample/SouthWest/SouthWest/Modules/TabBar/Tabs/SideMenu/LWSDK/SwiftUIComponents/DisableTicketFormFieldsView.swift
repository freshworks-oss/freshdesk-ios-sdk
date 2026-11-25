//
//  DisableTicketFormFieldsView.swift
//  SouthWest
//

import SwiftUI
import UIKit

struct DisableTicketFormFieldsView: View {

    let didDismiss: (_ formIdText: String, _ fieldsJsonArray: String, _ shouldSubmit: Bool) -> Void

    @State private var formId: String
    @State private var fieldsJsonArray: String

    init(didDismiss: @escaping (_ formIdText: String, _ fieldsJsonArray: String, _ shouldSubmit: Bool) -> Void) {
        self.didDismiss = didDismiss
        let storedId = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.disableTicketFormFieldsFormId)
            ?? Constants.Characters.emptyString
        let storedPayload = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.disableTicketFormFieldsPayloadJson)
        _formId = State(initialValue: storedId)
        _fieldsJsonArray = State(initialValue: storedPayload ?? Constants.Features.DisableTicketFormFields.defaultFieldsJson)
    }

    var body: some View {
        FeatureBackgroundView(
            heading: Constants.Features.DisableTicketFormFields.title,
            subheading: Constants.Features.DisableTicketFormFields.subheading,
            mainButtonTitle: Constants.Features.DisableTicketFormFields.mainButton,
            dismissTapped: {
                didDismiss(Constants.Characters.emptyString, Constants.Characters.emptyString, false)
            },
            mainButtonTapped: {
                let trimmedId = formId.trimmingCharacters(in: .whitespacesAndNewlines)
                let payload = fieldsJsonArray.trimmingCharacters(in: .whitespacesAndNewlines)
                UserDefaults.standard.set(trimmedId, forKey: Constants.UserDefaultsKeys.disableTicketFormFieldsFormId)
                UserDefaults.standard.set(payload, forKey: Constants.UserDefaultsKeys.disableTicketFormFieldsPayloadJson)
                didDismiss(trimmedId, payload, true)
            },
            content: {
                VStack(alignment: .leading, spacing: 16) {
                    FeatureTextfield(
                        title: Constants.Features.DisableTicketFormFields.formIdTitle,
                        placeholder: Constants.Features.DisableTicketFormFields.formIdPlaceholder,
                        keyboardType: UIKeyboardType.numberPad,
                        content: $formId
                    )
                    FeatureTextEditor(
                        title: Constants.Features.DisableTicketFormFields.fieldsPayloadTitle,
                        placeholder: Constants.Features.DisableTicketFormFields.fieldsPayloadPlaceholder,
                        description: Constants.Features.DisableTicketFormFields.fieldsPayloadDescription,
                        editorHeight: 200,
                        content: $fieldsJsonArray
                    )
                }
            })
    }
}
