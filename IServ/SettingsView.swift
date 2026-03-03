import SwiftUI

struct SettingsView: View {
    @AppStorage("iservURL") private var iservURLString: String = ""
    @State private var workingURL: String
    @State private var validationError: String?

    init(currentURLString: String) {
        _workingURL = State(initialValue: currentURLString)
    }

    var body: some View {
        Form {
            Section(header: Text("IServ-Server"), footer: footerText) {
                TextField("https://dein-gymnasium.de/iserv", text: $workingURL)
            }
            Section {
                Button("Speichern") {
                    if let sanitized = sanitize(urlString: workingURL) {
                        iservURLString = sanitized.absoluteString
                        validationError = nil
                    } else {
                        validationError = "Bitte eine gültige URL eingeben."
                    }
                }
                .buttonStyle(.borderedProminent)

                Button(role: .destructive) {
                    workingURL = ""
                    iservURLString = ""
                } label: {
                    Text("Zurücksetzen (URL entfernen)")
                }
            }
        }
        .navigationTitle("Einstellungen")
    }

    private var footerText: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Gib die vollständige Adresse deines IServ-Servers an. Beispiel: https://schule.de/iserv")
            if let validationError {
                Text(validationError)
                    .foregroundStyle(.red)
            }
        }
    }

    private func sanitize(urlString: String) -> URL? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let withScheme: String
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            withScheme = trimmed
        } else {
            withScheme = "https://" + trimmed
        }

        guard let url = URL(string: withScheme) else { return nil }
        guard let host = url.host, host.contains(".") else { return nil }
        return url
    }
}

#Preview {
    NavigationStack {
        SettingsView(currentURLString: "https://example.iserv.eu")
    }
}
