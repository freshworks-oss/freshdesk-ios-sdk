//
//  ViewController.swift
//  FreshworksSDKTestApp
//
//  Created by Harish Kumar on 24/05/23.
//

import UIKit
import SwiftUI
import FreshdeskSDK

final class ViewController: UIViewController {
    
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var unreadCountBadgeLabel: UILabel!
    @IBOutlet weak var customLinkButton: UIButton!
    var outboundEventLogsEnabled = false
    var dismissButtonEnabled = false
    private var toastMessageQueue: [String] = []
    private var isToastShowing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFDObservers()
        setupUI()
    }
    
    private func setupUI() {
        unreadCountBadgeLabel.backgroundColor = .red
        unreadCountBadgeLabel.textColor = .white
        updateUnreadCount(Freshdesk.getUnreadCount())
    }
    
    // MARK: - Actions
    @IBAction func didTapShowConversations(_ sender: UIButton) {
        Freshdesk.openSupport(self)
        setDismissButton()
    }
    
    @IBAction func didTapShowFAQs(_ sender: UIButton) {
        Freshdesk.openKnowledgeBase(self)
        setDismissButton()
    }
    
    @IBAction func didTapOpenSpecificConversations(_ sender: UIButton) {
        let openSpecificConversationsInputView = OpenSpecificConversationsInputView { [weak self] (topicId, topicName, showConversation) in
            guard let self else { return }
            self.dismiss(animated: false) {
                if showConversation {
                    Freshdesk.openTopic(self, topicId: topicId, topicName: topicName)
                }
            }
        }
        present(openSpecificConversationsInputView)
    }
    
    @IBAction func didTapResetUser(_ sender: UIButton) {
        resetUser { [weak self] in
            self?.showToast(message: Constants.Toast.userResetSuccess)
        }
        //Rest user with success and failure
        Freshdesk.resetUser(
            onSuccess: {
                self.showToast(message: Constants.Toast.userResetSuccess)
            },
            onFailure: {
                print("Reset user Failed!")
            }
        )
    }
   
    @IBAction func setUserProperties(_ sender: Any) {
        let userPropertiesViewData = PropertiesViewModelData(title: Constants.Features.setUserProperties.title, subheading: Constants.Features.setUserProperties.subheading, textEditor: Constants.Features.setUserProperties.textEditor, textEditorPlaceholder: Constants.Features.setUserProperties.textEditorPlaceholder, textEditorDescription: Constants.Features.setUserProperties.textEditorDescription)
        let userPropertiesString = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.userProperties) ?? Constants.Characters.emptyString
        
        let updateCustomBotVariables = UpdateConvOrBotAttributesView(didDismiss: { [weak self] (userPropertiesJsonString, isSetUserProperties)  in
            guard let `self` = self else { return }
            if let userProperties = SWUtilMethods.convertToJsonDictionary(from: userPropertiesJsonString) {
                self.dismiss(animated: false) {
                    if isSetUserProperties {
                        Freshdesk.setUserDetails(with: userProperties)
                        UserDefaults.standard.set(userPropertiesJsonString, forKey: Constants.UserDefaultsKeys.userProperties)
                        
                    }
                }
            } else {
                if isSetUserProperties {
                    self.showToast(message: Constants.Toast.invalidJson)
                } else {
                    self.dismiss(animated: false)
                }
            }
        }, attributesString: userPropertiesString, propertiesViewAttributes: userPropertiesViewData)
        
        present(updateCustomBotVariables)
    }
    
    @IBAction func enableCustomLinksHandler(_ sender: Any) {
        customLinkButton.setTitle(" Custom Link : Enabled", for: .normal)
        Freshdesk.setCustomLinkHandler { url in
            print("Link tapped: \(url)")
            // Custom handling logic
            if url.absoluteString.hasPrefix("freshdesk://") {
                self.showToast(message: "Deeplink URL tapped: \(url.host ?? url.absoluteString)")
                return
            }
            self.showToast(message: "Custom link handler: \(url.host ?? url.absoluteString)")
        }
    }
    
    @IBAction func handleDismissSDK(_ sender: Any) {
        self.showToast(message: "Dismiss active after 10 secs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            Freshdesk.dismissFreshdeskSDKViews()
        }
    }
 
    @IBAction func setTicketProperties(_ sender: Any) {
        let ticketPropertiesViewData = PropertiesViewModelData(title: Constants.Features.setTicketProperties.title, subheading: Constants.Features.setTicketProperties.subheading, textEditor: Constants.Features.setTicketProperties.textEditor, textEditorPlaceholder: Constants.Features.setTicketProperties.textEditorPlaceholder, textEditorDescription: Constants.Features.setTicketProperties.textEditorDescription)
        let ticketPropertiesString = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.ticketProperties) ?? Constants.Characters.emptyString
        
        let updateConversationProperties = UpdateConvOrBotAttributesView(didDismiss: { [weak self] (ticketPropertiesJsonString, isSetTicketProperties)  in
            guard let `self` = self else { return }
                        
            if let ticketProperties = SWUtilMethods.convertToJsonDictionary(from: ticketPropertiesJsonString) {
                self.dismiss(animated: false) {
                    if isSetTicketProperties {
                        Freshdesk.setTicketProperties(with: ticketProperties)
                        UserDefaults.standard.set(ticketPropertiesJsonString, forKey: Constants.UserDefaultsKeys.ticketProperties)
                    }
                }
            } else {
                if isSetTicketProperties {
                    self.showToast(message: Constants.Toast.invalidJson)
                } else {
                    self.dismiss(animated: false)
                }
            }
        }, attributesString: ticketPropertiesString, propertiesViewAttributes: ticketPropertiesViewData)
        
        present(updateConversationProperties)
    }
   
    @IBAction func didTapUpdateJWT(_ sender: Any) {
        
        let updateJWTView = UpdateJWTView { [weak self] (jwt)  in
            self?.dismiss(animated: false) {
                guard let jwt = jwt else { return }
                UserDefaults.standard.updateJWT(jwt)
                Freshdesk.authenticateAndUpdate(jwt: jwt)
            }
        }
        
        present(updateJWTView)
    }
    
    @IBAction func didTestTrackUserEvent(_ sender: UIButton) {
        let logUserEventView = LogUserEventView { (eventName, eventValue, isLogEvent)  in
            self.dismiss(animated: false) { [weak self] in
                if isLogEvent && !eventName.isEmpty {
                    Freshdesk.trackUserEvents(name: eventName, payload: eventValue)
                    self?.showToast(message: Constants.Toast.eventSent + eventName)
                }
            }
        }
        
        present(logUserEventView)
    }
    
    
    @IBAction private func changeAccount(_ sender: UIButton) {
        let changeAccountView = ChangeAccountView { [weak self] (sdkConfig)  in
            guard let `self` = self else { return }
            self.dismiss(animated: false) {
                if let sdkConfig = sdkConfig {
                    self.resetUser {
                        UserDefaults.standard.updateJWT(sdkConfig.jwtAuthToken ?? "")
                        Freshdesk.initialize(with: sdkConfig)
                    }
                }
            }
        }
        
        present(changeAccountView)
    }
    
    private func resetUser(completion: (() -> Void)? = nil) {
        UserDefaults.standard.resetUserDetails()
        completion?()
    }
    
    @IBAction func configureTapped(_ sender: UIButton) {
        let configureView = ConfigureView(
            outboundEventLogsEnabled: outboundEventLogsEnabled,
            dismissButtonEnabled: dismissButtonEnabled, didDismiss: { outboundEventLogsEnabled, dismissButtonEnabled in
                self.dismiss(animated: false) {
                    self.outboundEventLogsEnabled = outboundEventLogsEnabled
                    self.dismissButtonEnabled = dismissButtonEnabled
                }
            })
        
        present(configureView)
    }
}

// TODO:- To be removed
extension ViewController {
    @IBAction func didTapSetUser(_ sender: UIButton) {
        let updateUserDetailsView = UpdateUserDetailsView { (userDetails)  in
            self.dismiss(animated: false) {
                if let userDetails = userDetails {
                    //TODO:-  Previous implementation of setuser details (Can be removed)
                }
            }
        }
        
        present(updateUserDetailsView)
    }
    
    
    @IBAction func didTapGetUser(_ sender: UIButton) {
        
        Freshdesk.getUser { user in
            print(user)
            let userDetailsString = SWUtilMethods.convertToJsonString(from: user)
            let showUserDetailsView = ShowUserDetailsView(userInfo: userDetailsString) {
                self.dismiss(animated: false)
            }
            self.present(showUserDetailsView)
        }
    }
    
    @IBAction func didTapIdentifyUser(_ sender: UIButton) {
        let identifyUserView = IdentifyUserView { [weak self] (externalId,restoreId, showConversation)  in
            guard let `self` = self else { return }
            self.dismiss(animated: false) {
                if showConversation {
                    Freshdesk.openSupport(self)
                    self.setDismissButton()
                }
            }
        }

        present(identifyUserView)
    }
    
    @IBAction func didSetConfigForLocalisation(_ sender: Any) {
        let setConfigLocalisationView = SetConfigLocalisationView { (headerProperty, content, toBeDismissed)  in
            self.dismiss(animated: false) {
                if !toBeDismissed {
                    typealias jsonDictionary = [String: Any]
                    var headerPropertyJSONData: jsonDictionary? = nil
                    var contentPropertyJSONData: jsonDictionary? = nil
                    
                    do{
                        if !headerProperty.isEmpty, let headerPropertyJson = headerProperty.data(using: String.Encoding.utf8) {
                            if let headerPropertyDecodedData = try JSONDecoder().decode(AnyCodable.self, from: headerPropertyJson).value as? [String: Any] {
                                headerPropertyJSONData = headerPropertyDecodedData
                            }
                        }
                        
                        if !content.isEmpty, let contentPropertyJson = content.data(using: String.Encoding.utf8) {
                            if let contentPropertyDecodedData = try JSONDecoder().decode(AnyCodable.self, from: contentPropertyJson).value as? [String: Any] {
                                contentPropertyJSONData = contentPropertyDecodedData
                            }
                        }
                    } catch {
                        print("Error with handling json: \(error.localizedDescription)")
                    }
                    
                }
            }
        }
        
        present(setConfigLocalisationView)
    }
    
    @IBAction func changeWidgetLanguage(_ sender: UIButton) {
        showChangeLanguageView(.widget)
    }
    
    @IBAction func changeUserLanguage(_ sender: UIButton) {
        showChangeLanguageView(.user)
    }
    
    func showChangeLanguageView(_ type: ChangeLanguagueType) {
        let rawValue =  UserDefaults.standard.string(forKey: type.userDefaultKey) ?? SupportedLanguage.none.rawValue
        let userDefaultSelectedLangauge = SupportedLanguage(rawValue: rawValue) ?? .none
        
        let logUserEventView = ChangeLanguageView(changeLanguagueType: type,
                                                  selectedLangauge: userDefaultSelectedLangauge) { (selectedLanguage, isChangeLocale)  in
            self.dismiss(animated: false) {
            }
        }
        
        present(logUserEventView)
    }
    
    @IBAction func preChatFormTapped(_ sender: Any) {
        let preChatFormTemplateView = PreChatFormView { [weak self] preChatFormTemplate, toBeDismissed in
            guard let self else { return }
            self.dismiss(animated: false) {
                if toBeDismissed || preChatFormTemplate.isEmpty { return }
                
                guard SWUtilMethods.isValidJSON(preChatFormTemplate) else {
                    self.showToast(message: Constants.Toast.invalidJson)
                    return
                }
                
            }
        }
        
        present(preChatFormTemplateView)
    }
}

extension ViewController {
    private func present<Content: View>(_ content: Content) {
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        hostingController.modalPresentationStyle = .overFullScreen
        present(hostingController, animated: false)
    }
}

extension ViewController {
    
    // MARK: - Notification observer methods
    
    func addFDObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onUserCreated(_:)), name: Notification.Name(FDEvents.userCreated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onUnreadCount(_:)), name: Notification.Name(FDEvents.unreadCount.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFreshchatEventTriggered(_:)), name: Notification.Name(FDEvents.messageSent.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFreshchatEventTriggered(_:)), name: Notification.Name(FDEvents.messageReceived.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFreshchatEventTriggered(_:)), name: Notification.Name(FDEvents.downloadFile.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFreshchatEventTriggered(_:)), name: Notification.Name(FDEvents.userCleared.rawValue), object: nil)
    }
    
    func removeFDObservers() {
        for events in FDEvents.allCases {
            NotificationCenter.default.removeObserver(self, name: Notification.Name(events.rawValue), object: nil)
        }
    }
    
    @objc func onUserCreated(_ notification: NSNotification) {
        print(notification.name)
        print(notification.object ?? "")
        self.showToastMessageForEvents(message: notification.name.rawValue)
    }
    
    @objc func onUnreadCount(_ notification: NSNotification) {
        print(notification.name)
        print(notification.object ?? "")
        var eventInfo = notification.name.rawValue
        if let unreadCount = notification.object as? Int {
            eventInfo += " : " + String(unreadCount)
            updateUnreadCount(unreadCount)
        }
        self.showToastMessageForEvents(message: eventInfo)
    }
    
    private func updateUnreadCount(_ count: Int) {
        let formattedCount = count > 9 ? "9+" : "\(count)"
        let hasUnreadCount = count > 0
        
        DispatchQueue.main.async {
            self.unreadCountBadgeLabel.text = hasUnreadCount ? formattedCount : Constants.Characters.emptyString
            self.unreadCountBadgeLabel.isHidden = !hasUnreadCount
            self.unreadCountBadgeLabel.layer.cornerRadius = self.unreadCountBadgeLabel.frame.height/2
            self.unreadCountBadgeLabel.clipsToBounds = true
            self.unreadCountBadgeLabel.layoutIfNeeded()
        }
    }
    
    @objc func onFreshchatEventTriggered(_ notification: NSNotification) {
        print(notification.name)
        print(notification.object ?? "")
        self.showToastMessageForEvents(message: notification.name.rawValue)
    }
    
}

extension ViewController {
    // MARK: - Dismiss button methods
    func setDismissButton() {
        if dismissButtonEnabled {
            DismissFreshworksButton.addToTopView()
        } else {
            DismissFreshworksButton.removeFromTopView()
        }
    }
    

    // MARK: -  Outbound events methods
    func showToastMessageForEvents(message: String) {
        if self.outboundEventLogsEnabled {
            self.showToast(message: message)
        }
    }

    func showToast(message: String, toBeAppended: Bool = true) {
        if toBeAppended {
            toastMessageQueue.append(message)
        }
        if !isToastShowing && !toastMessageQueue.isEmpty {
            isToastShowing = true
            let message = toastMessageQueue.first
            self.showToast(message: message, duration: 1.4) { [weak self] in
                self?.toastMessageQueue.removeFirst()
                self?.isToastShowing = false
                self?.showToast(message: "", toBeAppended: false)
            }
        }
    }
}

// MARK: - Dismiss button class
fileprivate class DismissFreshworksButton: UIButton {
    
    struct DismissFrame {
        static let positionX = UIScreen.main.bounds.width - Dimensions.DismissButton.height - Dimensions.DismissButton.trailingSpacing
        static let positionY = UIScreen.main.bounds.height - Dimensions.DismissButton.height - Dimensions.DismissButton.bottomSpacing
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureButton()
    }
    
    private func configureButton() {
        backgroundColor = UIColor(named: Colors.darkBlue)
        tintColor = .white
        setImage(UIImage(systemName: "xmark"), for: .normal)
        addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
    }
    
    static func addToTopView() {
        guard let topView = UIApplication.topView,
              let navigationController = topView as? UINavigationController,
              let topViewController = navigationController.viewControllers.first else {
            return
        }
        let dismissButton = DismissFreshworksButton()
        dismissButton.frame = CGRect(x: DismissFrame.positionX,
                                     y: DismissFrame.positionY,
                                     width: Dimensions.DismissButton.width,
                                     height: Dimensions.DismissButton.height)
        dismissButton.layer.cornerRadius = Dimensions.DismissButton.height / 2
        topViewController.view.addSubview(dismissButton)
        topViewController.view.bringSubviewToFront(dismissButton)
    }
    
    static func removeFromTopView() {
        guard let topView = UIApplication.topView,
              let navigationController = topView as? UINavigationController,
              let topViewController = navigationController.viewControllers.first else {
            return
        }
        topViewController.view.subviews.forEach {
            if $0 is DismissFreshworksButton { $0.removeFromSuperview() }
        }
    }
    
    @objc private func dismissTapped() {
        DismissFreshworksButton.removeFromTopView()
        Freshdesk.dismissFreshdeskSDKViews()
    }
}
