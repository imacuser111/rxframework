//
//  UserDefaultsAdapter.swift
//  ExampleWebSocket
//
//  Created by Cheng-Hong on 2022/1/10.
//

import Foundation

@propertyWrapper
struct UserDefaultsBacked<Value> {
    let key: String
    let defaultValue: Value
    var storage: UserDefaults = UserDefaults()
    
  var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}

struct UserDefaultsAdapter {
    private static let TOKEN = "TOKEN" // LoginSys Token
    private static let REFRESHTOKEN = "REFRESHTOKEN" // LoginSys Token
    
    @UserDefaultsBacked<String>(key: TOKEN, defaultValue: "") static var token: String
    
    @UserDefaultsBacked<String>(key: REFRESHTOKEN, defaultValue: "") static var refreshToken: String
}
