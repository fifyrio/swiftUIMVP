//
//  OnboardStatus.swift
//  EmmaAICharacter
//
//  Created by 吴伟 on 12/5/24.
//

import SwiftUI
import Combine

public class OnboardStatus: ObservableObject {    
    @Published public var isCompleted: Bool = UserDefaults.standard.bool(forKey: "haveOnboarded")
    public init() {
    }
    public func completeOnboarding() {
        isCompleted = true
        UserDefaults.standard.set(true, forKey: "haveOnboarded")
    }
}
