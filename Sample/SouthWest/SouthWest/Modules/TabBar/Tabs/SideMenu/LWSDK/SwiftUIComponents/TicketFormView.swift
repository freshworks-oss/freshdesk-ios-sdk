//
//  TicketFormView.swift
//  SouthWest
//

import FreshdeskSDK
import SwiftUI

struct TicketFormView: View {

    private enum ActiveOverlay {
        case openTicketForm
        case clearTicketForm
        case prefillTicketForm
        case disableTicketFormFields
        case hideTicketFormFields
        case hideTicketFormFieldChoices
    }

    @State private var activeOverlay: ActiveOverlay?

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                sdkButton(title: Constants.Features.TicketForm.openTicketFormButton) {
                    activeOverlay = .openTicketForm
                }
                sdkButton(title: Constants.Features.TicketForm.clearTicketFormButton) {
                    activeOverlay = .clearTicketForm
                }
                sdkButton(title: Constants.Features.TicketForm.prefillTicketFormButton) {
                    activeOverlay = .prefillTicketForm
                }
                sdkButton(title: Constants.Features.TicketForm.disableTicketFormFieldsButton) {
                    activeOverlay = .disableTicketFormFields
                }
                sdkButton(title: Constants.Features.TicketForm.hideTicketFormFieldsButton) {
                    activeOverlay = .hideTicketFormFields
                }
                sdkButton(title: Constants.Features.TicketForm.hideTicketFormFieldChoicesButton) {
                    activeOverlay = .hideTicketFormFieldChoices
                }
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 24)

            if let overlay = activeOverlay {
                overlayView(for: overlay)
                    .zIndex(1)
            }
        }
    }

    @ViewBuilder
    private func overlayView(for overlay: ActiveOverlay) -> some View {
        switch overlay {
        case .openTicketForm:
            TicketFormIdSheetView(
                heading: Constants.Features.OpenTicketForm.title,
                subheading: Constants.Features.OpenTicketForm.subheading,
                formIdTitle: Constants.Features.OpenTicketForm.formIdTitle,
                formIdPlaceholder: Constants.Features.OpenTicketForm.formIdPlaceholder,
                mainButtonTitle: Constants.Features.TicketFormIdSheet.mainButton,
                userDefaultsKey: Constants.UserDefaultsKeys.ticketFormOpenFormId,
                didDismiss: handleOpenTicketFormDismiss
            )
        case .clearTicketForm:
            TicketFormIdSheetView(
                heading: Constants.Features.ClearTicketForm.title,
                subheading: Constants.Features.ClearTicketForm.subheading,
                formIdTitle: Constants.Features.ClearTicketForm.formIdTitle,
                formIdPlaceholder: Constants.Features.ClearTicketForm.formIdPlaceholder,
                mainButtonTitle: Constants.Features.ClearTicketForm.mainButton,
                userDefaultsKey: Constants.UserDefaultsKeys.ticketFormClearFormId,
                didDismiss: handleClearTicketFormDismiss
            )
        case .prefillTicketForm:
            PrefillTicketFormView(didDismiss: handlePrefillTicketFormDismiss)
        case .disableTicketFormFields:
            DisableTicketFormFieldsView(didDismiss: handleDisableTicketFormFieldsDismiss)
        case .hideTicketFormFields:
            HideTicketFormFieldsView(didDismiss: handleHideTicketFormFieldsDismiss)
        case .hideTicketFormFieldChoices:
            HideTicketFormFieldChoicesView(didDismiss: handleHideTicketFormFieldChoicesDismiss)
        }
    }

    private func sdkButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color(Colors.darkBlue))
                .cornerRadius(14)
        }
    }

    private func handleOpenTicketFormDismiss(_ formIdText: String, _ shouldSubmit: Bool) {
        activeOverlay = nil
        guard shouldSubmit else { return }
        let trimmed = formIdText.trimmingCharacters(in: .whitespacesAndNewlines)
        DispatchQueue.main.async {
            guard let presenter = UIApplication.topView else { return }
            if trimmed.isEmpty {
                Freshdesk.openTicketForm(presenter, formId: nil)
            } else if let formId = Int(trimmed) {
                Freshdesk.openTicketForm(presenter, formId: formId)
            } else {
                presenter.showToast(message: Constants.Toast.invalidFormId)
            }
        }
    }

    private func handleClearTicketFormDismiss(_ formIdText: String, _ shouldSubmit: Bool) {
        activeOverlay = nil
        guard shouldSubmit else { return }
        let trimmed = formIdText.trimmingCharacters(in: .whitespacesAndNewlines)
        DispatchQueue.main.async {
            guard let presenter = UIApplication.topView else { return }
            guard let formId = Int(trimmed) else {
                presenter.showToast(message: Constants.Toast.invalidFormId)
                return
            }
            Freshdesk.clearTicketForm(formId: formId)
        }
    }

    private func handlePrefillTicketFormDismiss(_ formIdText: String, _ fieldsJson: String, _ shouldSubmit: Bool) {
        activeOverlay = nil
        guard shouldSubmit else { return }
        DispatchQueue.main.async {
            guard let presenter = UIApplication.topView else { return }
            guard let formId = Int(formIdText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                presenter.showToast(message: Constants.Toast.invalidFormId)
                return
            }
            let json = fieldsJson.trimmingCharacters(in: .whitespacesAndNewlines)
            guard SWUtilMethods.isValidJSON(json),
                  let fields = SWUtilMethods.convertToJsonDictionary(from: json) else {
                presenter.showToast(message: Constants.Toast.invalidJson)
                return
            }
            Freshdesk.prefillTicketForm(formId: formId, fields: fields)
        }
    }

    private func handleDisableTicketFormFieldsDismiss(_ formIdText: String, _ fieldsJsonArray: String, _ shouldSubmit: Bool) {
        activeOverlay = nil
        guard shouldSubmit else { return }
        DispatchQueue.main.async {
            guard let presenter = UIApplication.topView else { return }
            guard let formId = Int(formIdText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                presenter.showToast(message: Constants.Toast.invalidFormId)
                return
            }
            let json = fieldsJsonArray.trimmingCharacters(in: .whitespacesAndNewlines)
            guard SWUtilMethods.isValidJSON(json),
                  let fields = SWUtilMethods.convertToJsonStringArray(from: json) else {
                presenter.showToast(message: Constants.Toast.invalidStringArrayJson)
                return
            }
            Freshdesk.disableTicketFormFields(formId: formId, fields: fields)
        }
    }

    private func handleHideTicketFormFieldsDismiss(_ formIdText: String, _ fieldsJsonArray: String, _ shouldSubmit: Bool) {
        activeOverlay = nil
        guard shouldSubmit else { return }
        DispatchQueue.main.async {
            guard let presenter = UIApplication.topView else { return }
            guard let formId = Int(formIdText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                presenter.showToast(message: Constants.Toast.invalidFormId)
                return
            }
            let json = fieldsJsonArray.trimmingCharacters(in: .whitespacesAndNewlines)
            guard SWUtilMethods.isValidJSON(json),
                  let fields = SWUtilMethods.convertToJsonStringArray(from: json) else {
                presenter.showToast(message: Constants.Toast.invalidStringArrayJson)
                return
            }
            Freshdesk.hideTicketFormFields(formId: formId, fields: fields)
        }
    }

    private func handleHideTicketFormFieldChoicesDismiss(_ formIdText: String, _ choicesJson: String, _ shouldSubmit: Bool) {
        activeOverlay = nil
        guard shouldSubmit else { return }
        DispatchQueue.main.async {
            guard let presenter = UIApplication.topView else { return }
            guard let formId = Int(formIdText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                presenter.showToast(message: Constants.Toast.invalidFormId)
                return
            }
            let json = choicesJson.trimmingCharacters(in: .whitespacesAndNewlines)
            guard SWUtilMethods.isValidJSON(json),
                  let choices = SWUtilMethods.convertToJsonDictionary(from: json) else {
                presenter.showToast(message: Constants.Toast.invalidJson)
                return
            }
            Freshdesk.hideTicketFormFieldChoices(formId: formId, choices: choices)
        }
    }
}

struct TicketFormView_Previews: PreviewProvider {
    static var previews: some View {
        TicketFormView()
    }
}
