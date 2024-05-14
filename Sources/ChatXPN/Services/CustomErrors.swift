//
//  CustomErrors.swift
//
//
//  Created by Karen Mirakyan on 14.05.24.
//

import Foundation
struct CustomErrors {
    static let userNotFound = NSError(domain: "Error",
                                      code: 0,
                                      userInfo: [NSLocalizedDescriptionKey : "User not found"])
    
    // lambda function to create NSError with error message
    static let createErrorWithMessage: (String) -> NSError = { errorMessage in
        let userInfo = [NSLocalizedDescriptionKey: errorMessage]
        return NSError(domain: "Error", code: 0, userInfo: userInfo)
    }
}
