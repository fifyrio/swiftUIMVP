//
//  JWTManager.swift
//  SwiftUIDemo
//
//  Created by 吴伟 on 2024/1/4.
//

import Foundation
import JWTKit

struct MyJWTPayload: JWTPayload {
    // Define your payload properties
    var user_id: String
    var token: String
    var exp: TimeInterval

    // Implement this method to verify your payload if needed
    func verify(using signer: JWTSigner) throws {
        // Custom verification logic
    }
}

public class JWTManager {
    public static let shared = JWTManager()
    
    private let uuidKey = "user_uuid"
    static private let JWT_KEY: String = ""
    
    private var exp: TimeInterval {
        
        // Get the current date and time
        let now = Date()        
        // Add 60 minutes to the current time
        if let fiveMinutesLater = Calendar.current.date(byAdding: .minute, value: 60, to: now) {
            // Get the timestamp for now and five minutes later
            
            let fiveMinutesLaterTimestamp = fiveMinutesLater.timeIntervalSince1970
            return fiveMinutesLaterTimestamp
        } else {
            print("Error calculating the future timestamp")
            return 0
        }
    }
    
    private var uuid: String {
        get {
            return UserDefaults.standard.string(forKey: uuidKey) ?? "\(Date().timeIntervalSince1970)_\(UUID().uuidString)"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: uuidKey)            
        }
    }
    
    private init() {
    }
    
    public var apiKey: String? {
        let payload = MyJWTPayload(user_id: uuid, token: "admin", exp: exp)
        do {
            let privateKey = JWTManager.JWT_KEY // Use your private key here
            let signer = JWTSigner.hs256(key: Data(privateKey.utf8))

            let jwtString = try signer.sign(payload)
            print("Encoded JWT: \(jwtString)")
            return jwtString
        } catch {
            print("JWT Encoding Error: \(error)")
            return nil
        }
    }
}
