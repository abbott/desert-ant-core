import Redact

// Without SwiftUI on purpose: its `Label` view makes `Label` ambiguous in any
// file that imports both.

/// How the report and the redacted text group and color what Redact found.
enum Category: CaseIterable, Identifiable {
    case name, contact, address, finance, identifier, network, other
    var id: Self { self }

    init(_ label: Label) {
        switch label {
        case .givenName, .surname: self = .name
        case .email, .phone, .url: self = .contact
        case .streetName, .buildingNumber, .secondaryAddress, .city, .state, .zipCode: self = .address
        case .creditCard, .bankAccount, .routingNumber: self = .finance
        case .governmentID, .passport, .driversLicense, .taxID, .ssn: self = .identifier
        case .ipAddress, .ipv4Address, .ipv6Address, .macAddress, .imei: self = .network
        // ORG, which this app never asks for, and any label added later.
        default: self = .other
        }
    }

    var title: String {
        switch self {
        case .name: "Name"
        case .contact: "Contact"
        case .address: "Address"
        case .finance: "Finance"
        case .identifier: "ID"
        case .network: "Network"
        case .other: "Other"
        }
    }
}
