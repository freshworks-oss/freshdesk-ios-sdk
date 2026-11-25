//
//  TicketFormIdSheetView.swift
//  SouthWest
//

import SwiftUI
import UIKit

struct TicketFormIdSheetView: View {
    let heading: String
    let subheading: String
    let formIdTitle: String
    let formIdPlaceholder: String
    let mainButtonTitle: String
    private let userDefaultsKey: String
    let didDismiss: (_ formIdText: String, _ shouldSubmit: Bool) -> Void

    @State private var formId: String

    init(
        heading: String,
        subheading: String,
        formIdTitle: String,
        formIdPlaceholder: String,
        mainButtonTitle: String,
        userDefaultsKey: String,
        didDismiss: @escaping (_ formIdText: String, _ shouldSubmit: Bool) -> Void
    ) {
        self.heading = heading
        self.subheading = subheading
        self.formIdTitle = formIdTitle
        self.formIdPlaceholder = formIdPlaceholder
        self.mainButtonTitle = mainButtonTitle
        self.userDefaultsKey = userDefaultsKey
        self.didDismiss = didDismiss
        _formId = State(
            initialValue: UserDefaults.standard.string(forKey: userDefaultsKey) ?? Constants.Characters.emptyString
        )
    }

    var body: some View {
        FeatureBackgroundView(
            heading: heading,
            subheading: subheading,
            mainButtonTitle: mainButtonTitle,
            dismissTapped: {
                didDismiss(Constants.Characters.emptyString, false)
            },
            mainButtonTapped: {
                let trimmed = formId.trimmingCharacters(in: .whitespacesAndNewlines)
                UserDefaults.standard.set(trimmed, forKey: userDefaultsKey)
                didDismiss(trimmed, true)
            },
            content: {
                FeatureTextfield(
                    title: formIdTitle,
                    placeholder: formIdPlaceholder,
                    keyboardType: UIKeyboardType.numberPad,
                    content: $formId
                )
            })
    }
}
