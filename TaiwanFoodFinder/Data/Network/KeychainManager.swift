//
//  KeychainManager.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/10.
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    func save(_ value: String, key: String) {
        let data = Data(value.utf8)

        // Delete existing item — query must NOT include kSecValueData
        let deleteQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new item
        let addQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        if status != errSecSuccess {
            #if DEBUG
            let message = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error"
            print("[KeychainManager] SecItemAdd failed: \(status) - \(message)")
            #endif
        }
    }
    
    func get(_ key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data {
            return String(data: data, encoding: .utf8)
        } else {
            #if DEBUG
            if status != errSecItemNotFound {
                let message = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error"
                print("[KeychainManager] SecItemCopyMatching failed: \(status) - \(message)")
            }
            #endif
            return nil
        }
    }
    
    func delete(_ key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        #if DEBUG
        if status != errSecSuccess && status != errSecItemNotFound {
            let message = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error"
            print("[KeychainManager] SecItemDelete failed: \(status) - \(message)")
        }
        #endif
    }
}
