//
//  HideTicketFormFieldsView.swift
//  SouthWest
//

import SwiftUI
import UIKit

struct HideTicketFormFieldsView: View {

    let didDismiss: (_ formIdText: String, _ fieldsJsonArray: String, _ shouldSubmit: Bool) -> Void

    @State private var formId: String
    @State private var fieldsJsonArray: String

    init(didDismiss: @escaping (_ formIdText: String, _ fieldsJsonArray: String, _ shouldSubmit: Bool) -> Void) {
        self.didDismiss = didDismiss
        let storedId = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.hideTicketFormFieldsFormId)
            ?? Constants.Characters.emptyString
        let storedPayload = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.hideTicketFormFieldsPayloadJson)
        _formId = State(initialValue: storedId)
        _fieldsJsonArray = State(initialValue: storedPayload ?? Constants.Features.HideTicketFormFields.defaultFieldsJson)
    }

    var body: some View {
        FeatureBackgroundView(
            heading: Constants.Features.HideTicketFormFields.title,
            subheading: Constants.Features.HideTicketFormFields.subheading,
            mainButtonTitle: Constants.Features.HideTicketFormFields.mainButton,
            dismissTapped: {
                didDismiss(Constants.Characters.emptyString, Constants.Characters.emptyString, false)
            },
            mainButtonTapped: {
                let trimmedId = formId.trimmingCharacters(in: .whitespacesAndNewlines)
                let payload = fieldsJsonArray.trimmingCharacters(in: .whitespacesAndNewlines)
                UserDefaults.standard.set(trimmedId, forKey: Constants.UserDefaultsKeys.hideTicketFormFieldsFormId)
                UserDefaults.standard.set(payload, forKey: Constants.UserDefaultsKeys.hideTicketFormFieldsPayloadJson)
                didDismiss(trimmedId, payload, true)
            },
            content: {
                VStack(alignment: .leading, spacing: 16) {
                    FeatureTextfield(
                        title: Constants.Features.HideTicketFormFields.formIdTitle,
                        placeholder: Constants.Features.HideTicketFormFields.formIdPlaceholder,
                        keyboardType: UIKeyboardType.numberPad,
                        content: $formId
                    )
                    FeatureTextEditor(
                        title: Constants.Features.HideTicketFormFields.fieldsPayloadTitle,
                        placeholder: Constants.Features.HideTicketFormFields.fieldsPayloadPlaceholder,
                        description: Constants.Features.HideTicketFormFields.fieldsPayloadDescription,
                        editorHeight: 200,
                        content: $fieldsJsonArray
                    )
                }
            })
    }
}
