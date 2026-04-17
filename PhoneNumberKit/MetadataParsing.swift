//
//  MetadataParsing.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 2019-02-10.
//  Copyright © 2019 Roy Marmelstein. All rights reserved.
//

import Foundation

// MARK: - Parsing helpers

extension KeyedDecodingContainer where K: CodingKey {
    /// Decodes a string to a boolean. Returns false if empty.
    ///
    /// - Parameter key: Coding key to decode
    func decodeBoolString(forKey key: KeyedDecodingContainer<K>.Key) -> Bool {
        guard let value: String = try? self.decode(String.self, forKey: key) else {
            return false
        }
        return Bool(value) ?? false
    }

    /// Decodes either a single object or an array into an array. Returns an empty array if empty.
    ///
    /// - Parameter key: Coding key to decode
    func decodeArrayOrObject<T: Decodable>(forKey key: KeyedDecodingContainer<K>.Key) -> [T] {
        guard let array: [T] = try? self.decode([T].self, forKey: key) else {
            guard let object: T = try? self.decode(T.self, forKey: key) else {
                return [T]()
            }
            return [object]
        }
        return array
    }
}

extension Collection where Element == MetadataPhoneNumberFormat {
    func withDefaultNationalPrefixFormattingRule(_ nationalPrefixFormattingRule: String?) -> [Element] {
        return self.map { format -> MetadataPhoneNumberFormat in
            var modifiedFormat = format
            if modifiedFormat.nationalPrefixFormattingRule == nil {
                modifiedFormat.nationalPrefixFormattingRule = nationalPrefixFormattingRule
            }
            return modifiedFormat
        }
    }
}
