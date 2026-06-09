//
//  SWConstants.swift
//  SouthWest
//
//  Created by Shahebaz Shaikh on 21/11/23.
//

import Foundation

typealias CallbackWithInt = (Int) -> ()
typealias Callback = () -> ()

struct Constants {
    
    struct Characters {
        static let emptyString = ""
        static let singleSpace = " "
        static let backslashWithDoubleQuote = "\""
        static let comma = ","
        static let colon = ":"
        static let commaSpace = ", "
        static let colonSpace = ": "
        static let hyphenString = "-"
    }

    struct Alert {
        static let title = "Alert"
        static let okay = "Okay"
    }
    
    struct Toast {
        static let eventSent = "Event sent: "
        static let userResetSuccess = "User reset was successful"
        static let invalidJson = "Invalid JSON. Please enter the correct JSON."
    }
    
    struct Login {
        static let sampleEmail = "test@gmail.com"
        static let samplePassword = "123456"
        static let email = "Email"
        static let password = "Password"
        static let forgotPassword = "Forgot Password?"
        static let signIn = "Sign In"
        static let or = "or"
        static let noAccount = "Don't have an account?"
        static let register = "Register Now"
        static let credentialsAlertTitle = "Invalid Credentials"
        static let credentialsAlertMessage = "Please enter a valid email and password."
        static let credentialsAlertButton = "Okay"
        static let emailPredicate = "SELF MATCHES %@"
        static let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        static let titleSignIn = "Let's Sign In"
        static let subheadingWelcome = "Welcome back, we missed you!"
    }
    
    struct Products {
        static let navigationTitleWelcome = "Welcome Back!"
        static let navigationSubtitleUsername = "Username"
        static let addToCart = "ADD TO CART"
    }
    
    struct Favourites {
        static let noFavourites = "No favourites added yet!"
    }
    
    struct Cart {
        static let checkout = "Checkout"
        static let cart = "Cart"
        static let done = "Done"
        static let continueButton = "Continue"
        static let returningCustomer = "Returning Customer"
        static let fasterCheckout = "Hey, welcome back! Sign in for faster checkout!"
        static let guest = "Guest"
        static let loginNotNeeded = "Login information not needed"
    }

    struct SideMenu {
        static let userName = "Falcon"
        static let userEmail = "falcon-email"
        static let myOrders = "My Orders"
        static let myOrdersDescription = "Already have 2 orders"
        static let sampleUnreadCount = "3"
        static let shippingAddresses = "Shipping Addresses"
        static let shippingAddressesDescription = "3 addresses"
        static let paymentMethod = "Payment Method"
        static let paymentMethodDescription = "VISA **34"
        static let readMore = "Read More"
        static let readMoreDescription = "FAQs"
        static let contactUs = "Contact Us"
        static let contactUsDescription = "Talk to an agent"
        static let myReview = "My Reviews"
        static let myReviewDescription = "Reviews for 4 items"
        static let settings = "Developer Settings"
        static let settingsDescription = "To develop and test"
        static let logout = "Logout"
        static let unreadNotificationName = "FRESHCHAT_UNREAD_MESSAGE_COUNT_CHANGED"
        static let SDKVersionTitle = "SDK Version: "
    }

    struct Features {
        
        struct UserDetails {
            static let updateTitle = "Update User"
            static let showTitle = "Show User"
            static let subheading = ""
            static let mainButton = "Update"
            
            static let info = "User Details"
            static let infoPlaceHolder = "Enter User Details"
            
            static let name = "Full Name"
            static let namePlaceholer = "Enter name"
            
            static let emailTitle = "Email"
            static let emailPlaceholer = "Enter email"
            
            static let phoneTitle = "Phone Number"
            static let phonePlaceholer = "Enter Phone Number"
            
            static let mobileTitle = "Mobile Number"
            static let mobilePlaceholer = "Enter mobile number"
            
            static let addressTitle = "Address"
            static let addressPlaceholer = "Enter address"
            
            static let customerPropertiesTitle = "Custom Properties"
            static let customerPropertyPlaceholer = "Enter properties"
            
            static let customerPropertyDescription = "Please enter the properties in the below fomrat. Eg:Key1: value1, key2: value2"

        }
        
        struct IdentifyUser {
            static let title = "Identify User"
            static let subheading = ""
            static let mainButton = "Identify/Show"

            static let externaIDTitle = "External ID"
            static let externalIDPlaceholder = "Enter External ID here."

            static let restoreIDTitle = "Restore ID"
            static let restoreIDPlaceholder = "Enter Restore ID here."

        }
        
        struct LocalisationConfig {
            
            static let title = "Set Localisation Config"
            static let subheading = "Override widget UI strings. Empty fields fall back to widget defaults. \"Apply Now\" triggers an SDK reInit, \"Save\" persists for the next launch."
            static let mainButton = "Apply Now (Runtime)"
            static let saveButton = "Save for Next Launch"
            static let resetButton = "Reset All"

            // Section headings
            static let sectionHeaders = "Headers"
            static let sectionChannelResponse = "Headers \u{2192} Channel Response"
            static let sectionChannelResponseOnline = "Headers \u{2192} Channel Response \u{2192} Online"
            static let sectionChannelResponseOnlineMinutes = "Headers \u{2192} Channel Response \u{2192} Online \u{2192} Minutes"
            static let sectionChannelResponseOnlineHours = "Headers \u{2192} Channel Response \u{2192} Online \u{2192} Hours"
            static let sectionTicketForm = "Headers \u{2192} Ticket Form"
            static let sectionPlaceholders = "Placeholders"
            static let sectionActions = "Actions"
            static let sectionPrivacy = "Privacy Policy Setting"
            static let sectionAdditional = "Additional Fields (Overflow / Future Keys)"

            // Headers
            static let chatTitle = "headers.chat"
            static let chatPlaceholder = "e.g. Chat with us"
            static let faqTitle = "headers.faq"
            static let faqPlaceholder = "e.g. Help Centre"
            static let faqMessageUsTitle = "headers.faq_message_us"
            static let faqMessageUsPlaceholder = "e.g. Message us"
            static let faqNotAvailableTitle = "headers.faq_not_available"
            static let faqNotAvailablePlaceholder = "e.g. FAQs not available"
            static let faqSearchNotAvailableTitle = "headers.faq_search_not_available"
            static let faqSearchNotAvailablePlaceholder = "e.g. No results found"
            static let faqThankyouTitle = "headers.faq_thankyou"
            static let faqThankyouPlaceholder = "e.g. Thanks for the feedback"
            static let faqUsefulTitle = "headers.faq_useful"
            static let faqUsefulPlaceholder = "e.g. Was this useful?"
            static let faqNotUsefulTitle = "headers.faq_not_useful"
            static let faqNotUsefulPlaceholder = "e.g. Not useful"
            static let typicallyRepliesFallbackTitle = "headers.typically_replies_few_mins_fallback"
            static let typicallyRepliesFallbackPlaceholder = "e.g. Typically replies in a few minutes"

            // Channel response
            static let offlineTitle = "channel_response.offline"
            static let offlinePlaceholder = "e.g. We are away right now"

            // Channel response \u{2192} online
            static let onlineDefaultTitle = "channel_response.online.default"
            static let onlineDefaultPlaceholder = "e.g. We typically reply in a few minutes"

            // Channel response \u{2192} online \u{2192} minutes
            static let onlineMinutesOneTitle = "channel_response.online.minutes.one"
            static let onlineMinutesOnePlaceholder = "e.g. Typically replies in {{time}} minute"
            static let onlineMinutesMoreTitle = "channel_response.online.minutes.more"
            static let onlineMinutesMorePlaceholder = "e.g. Typically replies in {{time}} minutes"

            // Channel response \u{2192} online \u{2192} hours
            static let onlineHoursOneTitle = "channel_response.online.hours.one"
            static let onlineHoursOnePlaceholder = "e.g. Typically replies in {{time}} hour"
            static let onlineHoursMoreTitle = "channel_response.online.hours.more"
            static let onlineHoursMorePlaceholder = "e.g. Typically replies in {{time}} hours"

            // Ticket form
            static let ticketTitleTitle = "ticket_form.title"
            static let ticketTitlePlaceholder = "e.g. Raise a ticket"
            static let ticketListTitleTitle = "ticket_form.list_title"
            static let ticketListTitlePlaceholder = "e.g. Choose a form"
            static let ticketSubmitTitle = "ticket_form.submit_btn_title"
            static let ticketSubmitPlaceholder = "e.g. Submit"
            static let ticketConfirmationTitle = "ticket_form.confirmation_message"
            static let ticketConfirmationPlaceholder = "e.g. We have received your request"

            // Placeholders
            static let replyFieldTitle = "placeholders.reply_field"
            static let replyFieldPlaceholder = "e.g. Type your reply..."
            static let searchFieldTitle = "placeholders.search_field"
            static let searchFieldPlaceholder = "e.g. Search articles..."

            // Actions
            static let tabChatTitle = "actions.tab_chat"
            static let tabChatPlaceholder = "e.g. Chat"

            // Privacy policy
            static let privacyMessageTitle = "privacy_policy_setting.privacy_policy_message"
            static let privacyMessagePlaceholder = "e.g. We respect your privacy"
            static let privacyLinkTextTitle = "privacy_policy_setting.privacy_policy_link_text"
            static let privacyLinkTextPlaceholder = "e.g. Privacy Policy"
            static let privacyLinkTitle = "privacy_policy_setting.privacy_policy_link"
            static let privacyLinkPlaceholder = "e.g. https://example.com/privacy"

            // Additional fields
            static let additionalTitle = "additional_fields (JSON)"
            static let additionalPlaceholder = "Optional JSON for any custom widget keys not yet typed in the SDK"
            static let additionalDescription = """
                Optional. Paste a JSON object whose keys will be merged at the top level of \
                the encoded `content`. Use this for new widget keys that aren't yet exposed \
                as typed properties on ContentConfiguration. Example:
                {
                  "custom_banner": "Hello",
                  "new_section": { "title": "Coming soon" }
                }
                """

            // Toast messages
            static let appliedRuntime = "Content config applied at runtime"
            static let savedForNextLaunch = "Saved. Will apply on next app launch"
            static let resetDone = "Content config reset to widget defaults"
        }
        
        struct OpenSpecificConversation {
            static let title = "Open Conversation"
            static let subheading = ""
            static let mainButton = "Open"

            static let topicNameTitle = "Topic Name"
            static let topicNamePlaceholder = "Enter Topic name here."
            
            static let referenceIdTitle = "Topic ID"
            static let referenceIdPlaceholder = "Enter Topic ID here."
        }
        
        struct LoadAccount {
            static let title = "Load Account"
            static let subheading = "Enter your account credentials to initialise the SDK"
            static let mainButton = "Update"
            
            static let widgetTokenTitle = "Widget Token"
            static let widgetTokenPlaceholder = "Enter Token"
            
            static let domainTitle = "Domain"
            static let domainPlaceholder = "Enter domain"
            
            static let sdkIdTitle = "Sdk ID"
            static let sdkIdPlaceholder = "Enter SDK ID"
            
            static let authTokenTitle = "Auth Token"
            static let authTokenPlaceholder = "Enter auth token"
            
            static let localeTitle = "Locale"
            static let localePlaceholder = "Enter Language"
            
            static let footer = "Auth token is mandatory only for JWT enabled acoounts"
            
            static let alertMessage = "Source, App ID, App key & domain are mandatory feilds."
        }
        
        struct Tags {
            static let title = "Conversation & FAQs Tags"
            static let subheading = "Enter the tags in a format where they are separated by a comma and a space, for example: Tag1,Tag2"
            static let mainButton = "Show"
            
            static let tagsTitle = "Tags"
            static let tagsPlaceholder = "Add Tags"
            
            static let selectFilterType = "Select Filter Type"
        }
        
        struct UpdateJWT {
            static let title = "Update JWT Auth Token"
            static let subheading = ""
            static let mainButton = "Authenticate"
            
            static let userStateTitle = "User State"
            static let userStatePlaceholder = "User State"

            static let tokenTitle = "JWT Token"
            static let tokenPlaceholder = "JWT Token"
            
            static let alertMessage = "Please enter a valid JWT"
        }
        
        struct LogEvent {
            static let title = "Log User Event"
            static let subheading = ""
            static let mainButton = "Log Event"
            
            static let eventNameTitle = "Event Name"
            static let eventNamePlaceholder = "Enter event name"
            
            static let eventValueTitle = "Event Value"
            static let eventValuePlaceholder = "Enter event value"
            static let eventValueDescription = "Please enter the event value in the below fomrat. Eg:Key1: value1, key2: value2"
        }
        
        struct ChangeLanguage {
            static let subheading = ""
            static let mainButton = "Change"
            
            static let pickerTitle = "SupportedLanguage"
            static let widgetLanguage = "Widget Language"
            static let userLanguage = "User Language"

            static let defaultSelectedLanguageCode = "en"
            static let defaultSelectedLanguageDisplayName = "English"
        }
        
        struct UpdateConvOrBotAttributesView {
            static let mainButton = "Update"
        }
        
        struct setUserProperties {
            static let title = "Set User Properties"
            static let subheading = ""
            static let textEditor = "User Properties"
            static let textEditorPlaceholder = "Enter User properties json string here"
            static let textEditorDescription = """
                                             Please enter the User properties data in the below json string format.
                                             {
                                                "name": "Mobile iOS SDK",
                                                "address": "Chennai, India",
                                                "mobile": "1234567890",
                                                "phone": "9876543210",
                                                "customnumber": 123
                                             }
                                             """
        }
        
        struct setTicketProperties {
            static let title = "Set Ticket Properties"
            static let subheading = ""
            static let textEditor = "Ticket Properties"
            static let textEditorPlaceholder = "Enter Ticket properties json string here"
            static let textEditorDescription = """
                                             Please enter the Ticket properties data in the below json string format.
                                             {
                                              "subject": "Product Enquiry",
                                              "priority": 3
                                             }
                                             """
        }
        
        struct Configurations {
            static let title = "Configurations"
            static let subheading = ""
            static let mainButton = "Done"
            static let outboundEventsToggleTitle = "Listen Outbound Events"
            static let dismissButtonToggleTitle = "Show Dismiss Button"
        }
        
        struct PreChatFormTemplate {
            static let title = "Pre-chat Form Template"
            static let subheading = "Update Pre-chat Form Template"
            static let mainButton = "Update"
            static let contentPropertyPlaceholder = "Please enter the pre-chat form template here"
            static let description = """
                                     Please enter the pre-chat form template in the below json format.
                                     {
                                      "status": "active",
                                      "type": 4
                                     }
                                     """
        }
    }
    
    struct Orders {
        static let name = "Bomber Jacket"
        static let price = "49.99"
        static let color = "Black"
        static let size = "XS"
        static let currency = "$"
        static let colorPrefix = "Color: "
        static let sizePrefix = "Size: "
        static let statusPrefix = "Status:"
        static let separator = " | "
        static let getHelp = "Get Help"
        static let viewSummary = "View Summary"
        struct Status {
            static let processing = "Processing"
            static let delivered = "Delivered"
        }
    }

    struct UserDefaultsKeys {
        static let selectedWidgetLanguageLocaleCode = "fw_selectedWidgetLanguageLocaleCode"
        static let selectedUserLanguageLocaleCode = "fw_selectedUserLanguageLocaleCode"
        static let topicIdForConversation = "fw_topicIdForConversation"
        static let topicNameForConversation = "fw_topicNameForConversation"
        static let externalID = "fw_externalID"
        static let restoreID = "fw_restoreID"
        static let userDetails = "fw_userDetails"
        static let tags = "fw_tags"
        static let tagsSelectOption = "fw_tagsSelectOption"
        static let ticketProperties = "fw_ticketProperties"
        static let userProperties = "fw_userProperties"
        static let headerProperty = "fw_headerProperty"
        static let contentProperty = "fw_contentProperty"
        static let contentConfiguration = "fw_contentConfiguration"
        static let preChatFormTemplate = "fw_preChatFormTemplate"
        
        
        static let token = "fw_token"
        static let domain = "fw_domain"
        static let sdkID = "fw_sdkID"
        static let jwt = "fw_jwt"
        static let locale = "fw_locale"

    }
    
    struct PreviewProvider {
        static let sampleText = "Sample Text"
        static let emptyText = ""
    }
    
    struct AccessibilityIdentifiers {
        static let email = "Email"
        static let password = "Password"
        static let signIn = "Sign In"
        static let dismiss = "Dismiss"
        static let myOrders = "My Orders"
        static let settings = "Develoepr Settings"
        static let contactUs = "Contact Us"
        static let productsView = "productsView"
        static let showFaqs = "showFaqs"
    }
}

struct Images {
    static let iconBack = "iconBack"
    static let background = "background"
    static let iconGoogle = "iconGoogle"
    static let iconFacebook = "iconFacebook"
    static let iconApple = "iconApple"
    static let iconHomeFilled = "iconHomeFilled"
    static let iconHome = "iconHome"
    static let iconFavouritesFilled = "iconFavouritesFilled"
    static let iconFavourites = "iconFavourites"
    static let iconCartFilled = "iconCartFilled"
    static let iconCart = "iconCart"
    static let systemCloseFilled = "xmark.circle.fill"
    static let userImage = "userImage"
    static let iconLogout = "iconLogout"
    static let orderImageOne = "itemImage1"
    static let orderImageTwo = "itemImage2"
    static let iconHelp = "iconHelp"
    static let iconSummary = "iconSummary"
    static let homeScreen = "homeScreen"
    static let iconSideMenu = "iconSideMenu"
    static let iconCartRound = "iconCartRound"
    static let iconFAQsRound = "iconFAQsRound"
    static let productImage = "productImage"
    static let productOptions = "productOptions"
    static let iconAddToCart = "iconAddToCart"
    static let checkoutArrow = "checkoutArrow"
    static let cartList = "cartList"
    static let orderPlaced = "orderPlaced"
}

struct Colors {
    static let darkBlue = "buttonDarkBlack"
    static let backgroundGray = "backgroundGray"
    static let backgroundDarkGray = "backgroundDarkGray"
}

struct Dimensions {
    struct DismissButton {
        static let height: CGFloat = 60
        static let width: CGFloat = 60
        static let trailingSpacing: CGFloat = 16
        static let bottomSpacing: CGFloat = 64
    }
}

// TODO: Will change with change in account
struct SDKTopicConfiguration {
    static let topicName = "Topic 3"
    struct ParallelConversation {
        static let identifier = "Get Help"
        static let identifierOne = "Get Help 1"
        static let identifierTwo = "Get Help 2"
    }
}
