//
//  ExtensionString.swift
//  UtilsSystemLib
//
//  Created by Nikolay Burkin on 26.02.2026.
//

import SwiftUI

// MARK: - String Regex Extension
extension String {
    func firstMatch(regex: String) -> String? {
        if let range = self.range(of: regex, options: .regularExpression) {
            return String(self[range])
        }
        return nil
    }
}
