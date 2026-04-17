//
//  MetadataTypes.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 02/11/2015.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
//

import Foundation

/// Represents metadata for a specific geographical territory used in phone number parsing.
// SKIP @nobridge
public struct MetadataTerritory: Decodable {
    enum CodingKeys: String, CodingKey {
        case codeID = "id"
        case countryCode
        case internationalPrefix
        case mainCountryForCode
        case nationalPrefix
        case nationalPrefixFormattingRule
        case nationalPrefixForParsing
        case nationalPrefixTransformRule
        case preferredExtnPrefix
        case emergency
        case fixedLine
        case generalDesc
        case mobile
        case pager
        case personalNumber
        case premiumRate
        case sharedCost
        case tollFree
        case voicemail
        case voip
        case uan
        case numberFormats = "numberFormat"
        case leadingDigits
        case availableFormats
    }

    /// ISO 3166-compliant region code.
    public let codeID: String
    /// International dialing country code.
    public let countryCode: UInt64
    /// International dialing prefix (e.g., "011").
    public let internationalPrefix: String?
    /// Indicates whether this is the primary country for the associated country code.
    public let mainCountryForCode: Bool
    /// National dialing prefix (e.g., "0").
    public let nationalPrefix: String?
    /// Rule for formatting the national prefix in numbers.
    public let nationalPrefixFormattingRule: String?
    /// Alternate national prefix used for parsing.
    public let nationalPrefixForParsing: String?
    /// Rule to transform the national prefix before parsing.
    public let nationalPrefixTransformRule: String?
    /// Preferred extension prefix (e.g., " ext. ").
    public let preferredExtnPrefix: String?
    /// Metadata description for emergency numbers.
    public let emergency: MetadataPhoneNumberDesc?
    /// Metadata description for fixed-line numbers.
    public let fixedLine: MetadataPhoneNumberDesc?
    /// Metadata description for general numbers.
    public let generalDesc: MetadataPhoneNumberDesc?
    /// Metadata description for mobile numbers.
    public let mobile: MetadataPhoneNumberDesc?
    /// Metadata description for pager numbers.
    public let pager: MetadataPhoneNumberDesc?
    /// Metadata description for personal numbers.
    public let personalNumber: MetadataPhoneNumberDesc?
    /// Metadata description for premium-rate numbers.
    public let premiumRate: MetadataPhoneNumberDesc?
    /// Metadata description for shared-cost numbers.
    public let sharedCost: MetadataPhoneNumberDesc?
    /// Metadata description for toll-free numbers.
    public let tollFree: MetadataPhoneNumberDesc?
    /// Metadata description for voicemail numbers.
    public let voicemail: MetadataPhoneNumberDesc?
    /// Metadata description for VoIP numbers.
    public let voip: MetadataPhoneNumberDesc?
    /// Metadata description for UAN numbers.
    public let uan: MetadataPhoneNumberDesc?
    /// List of formatting patterns used within this territory.
    public let numberFormats: [MetadataPhoneNumberFormat]
    /// Optional leading digits used to narrow down matching within the territory.
    public let leadingDigits: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        codeID = try container.decode(String.self, forKey: .codeID)
        let code = try container.decode(String.self, forKey: .countryCode)
        countryCode = UInt64(code)!
        mainCountryForCode = container.decodeBoolString(forKey: .mainCountryForCode)
        let possibleNationalPrefixForParsing: String? = try container.decodeIfPresent(String.self, forKey: .nationalPrefixForParsing)
        let possibleNationalPrefix: String? = try container.decodeIfPresent(String.self, forKey: .nationalPrefix)
        nationalPrefix = possibleNationalPrefix
        let nationalPrefixForParsing = (possibleNationalPrefixForParsing == nil && possibleNationalPrefix != nil) ? nationalPrefix : possibleNationalPrefixForParsing
        self.nationalPrefixForParsing = nationalPrefixForParsing?.replacingOccurrences(of: "\\", with: #"\\"#)
        nationalPrefixFormattingRule = try container.decodeIfPresent(String.self, forKey: .nationalPrefixFormattingRule)
        let availableFormats = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .availableFormats)
        let temporaryFormatList: [MetadataPhoneNumberFormat] = availableFormats?.decodeArrayOrObject(forKey: .numberFormats) ?? []
        numberFormats = temporaryFormatList.withDefaultNationalPrefixFormattingRule(nationalPrefixFormattingRule)

        internationalPrefix = try container.decodeIfPresent(String.self, forKey: .internationalPrefix)
        nationalPrefixTransformRule = try container.decodeIfPresent(String.self, forKey: .nationalPrefixTransformRule)
        preferredExtnPrefix = try container.decodeIfPresent(String.self, forKey: .preferredExtnPrefix)
        emergency = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .emergency)
        fixedLine = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .fixedLine)
        generalDesc = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .generalDesc)
        mobile = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .mobile)
        pager = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .pager)
        personalNumber = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .personalNumber)
        premiumRate = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .premiumRate)
        sharedCost = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .sharedCost)
        tollFree = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .tollFree)
        voicemail = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .voicemail)
        voip = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .voip)
        uan = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .uan)
        leadingDigits = try container.decodeIfPresent(String.self, forKey: .leadingDigits)
    }
}

/// Describes a specific type of phone number (e.g., mobile, fixed-line) using metadata.
// SKIP @nobridge
public struct MetadataPhoneNumberDesc: Decodable {
    /// Example number demonstrating a valid format for this type.
    public let exampleNumber: String?
    /// Regular expression pattern for national numbers of this type.
    public let nationalNumberPattern: String?
    /// Regular expression pattern for possible numbers of this type.
    public let possibleNumberPattern: String?
    /// Valid number lengths for this type.
    public let possibleLengths: MetadataPossibleLengths?
}

/// Describes valid lengths for a phone number, either nationally or locally.
// SKIP @nobridge
public struct MetadataPossibleLengths: Decodable {
    /// Valid national number lengths (as a comma-separated string).
    let national: String?
    /// Valid local-only number lengths (as a comma-separated string).
    let localOnly: String?
}

/// Describes how a phone number should be formatted within a specific context.
// SKIP @nobridge
public struct MetadataPhoneNumberFormat: Decodable {
    enum CodingKeys: String, CodingKey {
        case pattern
        case format
        case intlFormat
        case leadingDigitsPatterns = "leadingDigits"
        case nationalPrefixFormattingRule
        case nationalPrefixOptionalWhenFormatting
        case domesticCarrierCodeFormattingRule = "carrierCodeFormattingRule"
    }

    /// Regular expression pattern that matches numbers this format applies to.
    public let pattern: String?
    /// Format string used to output the number.
    public let format: String?
    /// International version of the format string.
    public let intlFormat: String?
    /// List of regular expressions for leading digits to match before applying the format.
    public let leadingDigitsPatterns: [String]?
    /// Rule for inserting the national prefix when formatting.
    public var nationalPrefixFormattingRule: String?
    /// Indicates whether the national prefix is optional during formatting.
    public let nationalPrefixOptionalWhenFormatting: Bool?
    /// Rule for formatting the domestic carrier code.
    public let domesticCarrierCodeFormattingRule: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        leadingDigitsPatterns = container.decodeArrayOrObject(forKey: .leadingDigitsPatterns)
        nationalPrefixOptionalWhenFormatting = container.decodeBoolString(forKey: .nationalPrefixOptionalWhenFormatting)

        pattern = try container.decodeIfPresent(String.self, forKey: .pattern)
        format = try container.decodeIfPresent(String.self, forKey: .format)
        intlFormat = try container.decodeIfPresent(String.self, forKey: .intlFormat)
        nationalPrefixFormattingRule = try container.decodeIfPresent(String.self, forKey: .nationalPrefixFormattingRule)
        domesticCarrierCodeFormattingRule = try container.decodeIfPresent(String.self, forKey: .domesticCarrierCodeFormattingRule)
    }
}

/// Internal structure used for decoding metadata from bundled resources.
struct PhoneNumberMetadata: Decodable {
    enum CodingKeys: String, CodingKey {
        case phoneNumberMetadata
        case territories
        case territory
    }

    var territories: [MetadataTerritory]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let metadataObject = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .phoneNumberMetadata)
        let territoryObject = try metadataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .territories)
        territories = try territoryObject.decode([MetadataTerritory].self, forKey: .territory)
    }
}
