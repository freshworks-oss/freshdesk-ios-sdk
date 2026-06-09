//
//  UserDetails.swift
//  SouthWest
//
//  Created by Shahebaz Shaikh on 21/11/23.
//

import Foundation
import FreshdeskSDK

// Extension to reset UserDefaults
extension UserDefaults {
    func resetUserDetails() {
        //User details
        removeObject(forKey: Constants.UserDefaultsKeys.userDetails)
        
        //Locale change
        removeObject(forKey: Constants.UserDefaultsKeys.selectedUserLanguageLocaleCode)
        
        //Parallel conversation
        removeObject(forKey: Constants.UserDefaultsKeys.topicIdForConversation)
        removeObject(forKey: Constants.UserDefaultsKeys.topicNameForConversation)
        
        //Tags
        removeObject(forKey: Constants.UserDefaultsKeys.tags)
        removeObject(forKey: Constants.UserDefaultsKeys.tagsSelectOption)
        
        //Jwt
        updateJWT(Constants.Characters.emptyString)
        
        //Ticket Properties
        removeObject(forKey: Constants.UserDefaultsKeys.ticketProperties)
        
        //Bot variables
        removeObject(forKey: Constants.UserDefaultsKeys.userProperties)
        
        //Header and content property
        removeObject(forKey: Constants.UserDefaultsKeys.headerProperty)
        removeObject(forKey: Constants.UserDefaultsKeys.contentProperty)

        //ContentConfiguration for localisation testing
        removeObject(forKey: Constants.UserDefaultsKeys.contentConfiguration)
    }
}

// Extension to UserDefaults to persist a ContentConfiguration value used by the
// sample app so the developer-entered localisation overrides survive app launches.
// Note: The SDK persists its own copy internally when `setContentConfiguration` is
// called; this app-side copy is used to pre-populate the form and to feed the
// `Configuration(content:)` parameter at SDK init time on next launch.
extension UserDefaults {
    var sampleContentConfiguration: ContentConfiguration? {
        get {
            guard let data = data(forKey: Constants.UserDefaultsKeys.contentConfiguration) else {
                return nil
            }
            return try? JSONDecoder().decode(ContentConfiguration.self, from: data)
        }
        set {
            if let value = newValue,
               !value.isSampleEmpty,
               let data = try? JSONEncoder().encode(value) {
                set(data, forKey: Constants.UserDefaultsKeys.contentConfiguration)
            } else {
                removeObject(forKey: Constants.UserDefaultsKeys.contentConfiguration)
            }
        }
    }
}

// The SDK's `ContentConfiguration.isEmpty` is internal, so we re-derive the same
// check here for the sample app's persistence layer. This keeps the form behavior
// identical to the SDK's own emptiness check without exposing internal API.
extension ContentConfiguration {
    var isSampleEmpty: Bool {
        headers == nil &&
        placeholders == nil &&
        privacyPolicySetting == nil &&
        actions == nil &&
        additionalFields.isEmpty
    }
}

// Extension to UserDefaults to simplify storing and retrieving UserDetails
extension UserDefaults {
    
    func updateSDKConfig(_ sdkConfig: FreshdeskSDKConfig, locale: String? = nil) {
        UserDefaults.standard.set(sdkConfig.token, forKey: Constants.UserDefaultsKeys.token)
        UserDefaults.standard.set(sdkConfig.host, forKey: Constants.UserDefaultsKeys.domain)
        UserDefaults.standard.set(sdkConfig.sdkId, forKey: Constants.UserDefaultsKeys.sdkID)
        UserDefaults.standard.set(sdkConfig.jwtAuthToken, forKey: Constants.UserDefaultsKeys.jwt)
        UserDefaults.standard.set(locale, forKey: Constants.UserDefaultsKeys.locale)
    }
    
    func updateJWT(_ jwt: String) {
        UserDefaults.standard.set(jwt, forKey: Constants.UserDefaultsKeys.jwt)
    }

    func getSDKConfig() -> FreshdeskSDKConfig? {
        guard let token =  UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.token),
              let domain =  UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.domain),
              let sdkId =  UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.sdkID),
              let jwtToken =  UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.jwt),
              let locale =  UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.locale)
        else {
            return nil
        }
        
        guard !sdkId.isEmpty && !token.isEmpty && !domain.isEmpty else {
            return nil
        }
        
        let sdkConfig = FreshdeskSDKConfig(token: token, host: domain, sdkId: sdkId, jwtToken: jwtToken, locale: locale)
        return sdkConfig
    }
}

