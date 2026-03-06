import Foundation

/// Сравнивает две строки, игнорируя диакритические знаки и регистр.
public func equalsIgnoreDiacriticsAndCase(_ lhs: String, _ rhs: String) -> Bool {
    return removeDiacritics(lhs) == removeDiacritics(rhs)
}

/// Проверяет вхождение строки, игнорируя диакритические знаки и регистр.
public func containsIgnoreDiacriticsAndCase(_ string: String, _ substring: String) -> Bool {
    return removeDiacritics(string).contains(removeDiacritics(substring))
}

/// Удаляет диакритические знаки из строки (без дополнительных замен)
public func removeDiacritics(_ string: String) -> String {
    let lowercased = string.lowercased()
    let decomposed = lowercased.decomposedStringWithCanonicalMapping
    let filtered = decomposed.unicodeScalars.filter { !$0.properties.isDiacritic }
    return String(String.UnicodeScalarView(filtered))
}
