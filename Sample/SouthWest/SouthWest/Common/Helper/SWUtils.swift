//
//  SWUtils.swift
//  SouthWest
//
//  Created by Shahebaz Shaikh on 05/04/24.
//

import Foundation

final class SWUtilMethods {
    internal static func isValidJSON(_ jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else {
            return false
        }
        
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: [])
            return true
        } catch {
            return false
        }
    }
    
    static func convertToDictionary(from jsonString: String) -> [String: String] {
        jsonString
            .replacingOccurrences(of: Constants.Characters.backslashWithDoubleQuote, with: Constants.Characters.emptyString)
            .components(separatedBy: Constants.Characters.commaSpace)
            .reduce(into: [String: String]()) { result, keyValue in
                let components = keyValue.components(separatedBy: Constants.Characters.colonSpace)
                if components.count == 2 {
                    let key = components[0]
                    let value = components[1]
                    result[key] = value
                }
            }
    }
    
    
    static func convertToJsonStringArray(from jsonString: String) -> [String]? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let array = jsonObject as? [Any] else {
                return nil
            }
            var strings: [String] = []
            strings.reserveCapacity(array.count)
            for element in array {
                guard let str = element as? String else {
                    return nil
                }
                strings.append(str)
            }
            return strings
        } catch {
            print("Error deserializing JSON array of strings: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func convertToJsonDictionary(from jsonString: String) -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8) else {
            print("Error: Could not convert string to Data using UTF-8 encoding.")
            return nil
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let dictionary = jsonObject as? [String: Any] {
                return dictionary
            } else {
                print("Error: JSON string does not represent a dictionary.")
                return nil
            }
        } catch {
            print("Error deserializing JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func convertToJsonString(from dictionary: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("✅ Conversion Successful:")
                return jsonString
            } else {
                print("❌ Error: Could not convert JSON data to a String.")
                return nil
            }
        } catch {
            print("❌ Error: Could not convert dictionary to JSON data: \(error)")
            return nil
        }
    }
}
