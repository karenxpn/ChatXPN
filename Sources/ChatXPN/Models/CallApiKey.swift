//
//  File.swift
//  
//
//  Created by Karen Mirakyan on 18.06.24.
//

import Foundation
import SwiftUI

public struct APIKeyEnvironmentKey: EnvironmentKey {
    public static let defaultValue: String = ""
}

public extension EnvironmentValues {
    var apiKey: String {
        get { self[APIKeyEnvironmentKey.self] }
        set { self[APIKeyEnvironmentKey.self] = newValue }
    }
}
