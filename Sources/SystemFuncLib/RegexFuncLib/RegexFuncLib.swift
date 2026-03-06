//
//  StaticFunc.swift
//  SystemFuncLib
//
//  Created by Nikolay Burkin on 06.03.2026.
//

public static StaticFuncLib {
    
    // MARK: - Общий метод для извлечения номера
    public static func extractCardNumber(from text: String) -> String? {
        if let number = text.firstMatch(regex: "\\d[\\d\\s]{7,}\\d") {
            return number.replacingOccurrences(of: " ", with: "")
        }
        return nil
    }
    
}
