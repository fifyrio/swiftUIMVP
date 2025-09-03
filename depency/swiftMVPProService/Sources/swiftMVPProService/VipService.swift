//
//  VipService.swift
//  EmmaAICharacter
//
//  Created by 吴伟 on 11/20/24.
//

import Foundation
import SwiftUI
import RevenueCat

extension UserDefaults {
    static var isProVersion: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isProVersion")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isProVersion")
        }
    }
    
    static var creditCreationCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: "creditCreationCount")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "creditCreationCount")
        }
    }
    
    static func incrementNoteCreationCount() {
        creditCreationCount += 1
    }
    
    static func resetNoteCreationCount() {
        creditCreationCount = 0
    }
}


public class VipService : ObservableObject{
  
    @Published var isSubscriptionActive = UserDefaults.isProVersion
    @Published var isLoading = false

    public init() {
        
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            self.isSubscriptionActive = customerInfo?.entitlements.all[ProConstants.ENTITLEMENTS_ID]?.isActive == true
        }
    }

    public func setThePurchaseStatus(isPro : Bool){
        self.isSubscriptionActive = isPro
        UserDefaults.isProVersion = isPro
        
        // When user becomes Pro, reset credit creation count
        if isPro {
            UserDefaults.resetNoteCreationCount()
        }
    }
}
