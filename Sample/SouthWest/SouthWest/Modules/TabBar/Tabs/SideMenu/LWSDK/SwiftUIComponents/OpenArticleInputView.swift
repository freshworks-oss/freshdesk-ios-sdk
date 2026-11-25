//
//  OpenArticleInputView.swift
//  SouthWest
//

import SwiftUI
import UIKit

struct OpenArticleInputView: View {
    let didDismiss: (_ articleIdText: String, _ shouldOpenArticle: Bool) -> Void

    @State private var articleId: String = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.articleIdForOpenArticle) ?? Constants.Characters.emptyString

    var body: some View {
        FeatureBackgroundView(
            heading: Constants.Features.OpenArticle.title,
            subheading: Constants.Features.OpenArticle.subheading,
            mainButtonTitle: Constants.Features.OpenArticle.mainButton,
            dismissTapped: {
                dismissAction()
            },
            mainButtonTapped: {
                openButtonTapped()
            },
            content: {
                FeatureTextfield(
                    title: Constants.Features.OpenArticle.articleIdTitle,
                    placeholder: Constants.Features.OpenArticle.articleIdPlaceholder,
                    keyboardType: UIKeyboardType.numberPad,
                    content: $articleId
                )
            })
    }

    private func dismissAction() {
        didDismiss(Constants.Characters.emptyString, false)
    }

    private func openButtonTapped() {
        let trimmed = articleId.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(trimmed, forKey: Constants.UserDefaultsKeys.articleIdForOpenArticle)
        didDismiss(trimmed, true)
    }
}

struct OpenArticleInputView_Previews: PreviewProvider {
    static var previews: some View {
        OpenArticleInputView { _, _ in }
    }
}
