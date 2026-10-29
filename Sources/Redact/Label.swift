/// A category of personal information that ``Redact`` can detect.
///
/// The raw value is the stable public label string (e.g. `"GIVEN_NAME"`) used in
/// redaction placeholders like `[GIVEN_NAME_1]`.
public enum Label: String, Sendable, Hashable, CaseIterable {
    case givenName = "GIVEN_NAME"
    case surname = "SURNAME"
    case streetName = "STREET_NAME"
    case buildingNumber = "BUILDING_NUMBER"
    case secondaryAddress = "SECONDARY_ADDRESS"
    case city = "CITY"
    case state = "STATE"
    case zipCode = "ZIP_CODE"
    case email = "EMAIL"
    case phone = "PHONE"
    case creditCard = "CREDIT_CARD"
    case bankAccount = "BANK_ACCOUNT"
    case routingNumber = "ROUTING_NUMBER"
    /// An address the model found that none of the address patterns below
    /// matched. In ``Options/labels`` with none of them, it selects them too.
    case ipAddress = "IP_ADDRESS"
    case ipv4Address = "IPV4_ADDRESS"
    case ipv6Address = "IPV6_ADDRESS"
    case macAddress = "MAC_ADDRESS"
    case url = "URL"
    case governmentID = "GOVERNMENT_ID"
    case passport = "PASSPORT"
    case driversLicense = "DRIVERS_LICENSE"
    case taxID = "TAX_ID"
    case ssn = "SSN"
    case imei = "IMEI"
    /// An organisation or company name. **Not redacted by default**: a company
    /// is not a natural person. Detected so it can be identified rather than
    /// mislabelled as a `SURNAME`; opt in via ``Options/labels``.
    case org = "ORG"

    /// A short, human-readable name for this category.
    public var displayName: String {
        switch self {
        case .givenName: "Given name"
        case .surname: "Surname"
        case .streetName: "Street"
        case .buildingNumber: "Building number"
        case .secondaryAddress: "Unit / apartment"
        case .city: "City"
        case .state: "State / region"
        case .zipCode: "Postal code"
        case .email: "Email"
        case .phone: "Phone"
        case .creditCard: "Credit card"
        case .bankAccount: "Bank account"
        case .routingNumber: "Routing number"
        case .ipAddress: "IP address"
        case .ipv4Address: "IPv4 address"
        case .ipv6Address: "IPv6 address"
        case .macAddress: "MAC address"
        case .url: "URL"
        case .governmentID: "Government ID"
        case .passport: "Passport"
        case .driversLicense: "Driver's license"
        case .taxID: "Tax ID"
        case .ssn: "SSN"
        case .imei: "IMEI"
        case .org: "Organisation"
        }
    }

    /// Name-family labels (given name / surname).
    static let nameFamilies: Set<String> = ["GIVEN_NAME", "SURNAME"]

    /// The categories redacted when ``Options/labels`` is `nil`: all but ``org``.
    public static let defaultEnabled: Set<Label> = Set(allCases).subtracting([.org])

    /// The raw labels a redaction keeps for ``Options/labels``. IP_ADDRESS
    /// selected every address before the address kinds had labels of their
    /// own, so a set that names it and none of them still does.
    static func allowed(_ labels: Set<Label>?) -> Set<String> {
        var allowed = labels ?? defaultEnabled
        let kinds: Set<Label> = [.ipv4Address, .ipv6Address, .macAddress]
        if allowed.contains(.ipAddress), allowed.isDisjoint(with: kinds) { allowed.formUnion(kinds) }
        return Set(allowed.map(\.rawValue))
    }
}
