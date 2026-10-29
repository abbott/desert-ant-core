import Redact
import SwiftUI

extension Category {
    /// System colors, so each one reads in light and dark mode.
    var color: Color {
        switch self {
        case .name: .blue
        case .contact: .teal
        case .address: .purple
        case .finance: .orange
        case .identifier: .red
        case .network: .pink
        case .other: .gray
        }
    }
}

/// What Redact found in the current text, colored by category. The switches
/// and the search filter this list only; they do not change what is redacted.
struct ReportView: View {
    let items: [Redaction.Item]
    /// False while a newer redaction is being computed.
    let isCurrent: Bool

    @State private var hidden: Set<Category> = []
    @State private var search = ""

    // Spelled out: the private state makes the memberwise one private too.
    init(items: [Redaction.Item], isCurrent: Bool) {
        self.items = items
        self.isCurrent = isCurrent
    }

    var body: some View {
        Group {
            if items.isEmpty {
                ContentUnavailableView("Nothing redacted", systemImage: "checkmark.shield",
                                       description: Text("What Redact masks in the text appears here."))
            } else {
                List {
                    Section {
                        ForEach(present) { category in
                            Toggle(isOn: shows(category)) {
                                HStack {
                                    Circle().fill(category.color).frame(width: 10, height: 10)
                                    Text(category.title)
                                    Spacer()
                                    Text("\(counts[category, default: 0])")
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                }
                            }
                        }
                    } header: {
                        Text(verbatim: items.count == 1 ? "1 item redacted" : "\(items.count) items redacted")
                    }

                    Section("Items") {
                        TextField("Search", text: $search)
                            .textFieldStyle(.roundedBorder)
                        ForEach(shown) { item in ReportRow(item: item) }
                        if shown.isEmpty {
                            Text("No items match.").foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .opacity(isCurrent ? 1 : 0.5)
    }

    private var counts: [Category: Int] {
        Dictionary(grouping: items) { Category($0.label) }.mapValues(\.count)
    }

    /// The categories in this result, in a fixed order.
    private var present: [Category] { Category.allCases.filter { counts[$0] != nil } }

    private var shown: [Redaction.Item] {
        items.filter { item in
            !hidden.contains(Category(item.label)) && (search.isEmpty
                || [item.original, item.placeholder, item.label.displayName]
                    .contains { $0.localizedCaseInsensitiveContains(search) })
        }
    }

    private func shows(_ category: Category) -> Binding<Bool> {
        Binding(
            get: { !hidden.contains(category) },
            set: { if $0 { hidden.remove(category) } else { hidden.insert(category) } }
        )
    }
}

private struct ReportRow: View {
    let item: Redaction.Item

    var body: some View {
        let color = Category(item.label).color
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.placeholder)
                    .font(.caption.monospaced().weight(.semibold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.15), in: Capsule())
                Spacer()
                Text(item.confidence, format: .percent.precision(.fractionLength(0)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Text(item.original)
                .font(.callout.monospaced())
                .textSelection(.enabled)
            Text(item.label.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
