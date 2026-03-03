//
//  ContentView.swift
//  IServ
//
//  Created by Farin Altenhöner on 02.03.26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("iservURL") private var iservURLString: String = ""
    @State private var tempURL: String = ""
    @State private var validationError: String?

    var body: some View {
        NavigationStack {
            Group {
                if let url = currentURL {
                    IServWebView(url: url)
                        .navigationTitle(hostTitle(from: url))
                        .toolbar {
                            NavigationLink(destination: SettingsView(currentURLString: iservURLString)) {
                                Image(systemName: "gear")
                            }
                            .accessibilityLabel("Einstellungen")
                        }
                } else {
                    setupView
                        .navigationTitle("IServ einrichten")
                }
            }
        }
        .onAppear {
            // Initialize tempURL with stored value when present
            if !iservURLString.isEmpty && tempURL.isEmpty {
                tempURL = iservURLString
            }
        }
    }

    private var currentURL: URL? {
        guard let sanitized = sanitize(urlString: iservURLString) else { return nil }
        return sanitized
    }

    private var setupView: some View {
        VStack(spacing: 16) {
            Image(systemName: "network")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("Bitte gib die Adresse deines IServ-Servers ein.")
                .multilineTextAlignment(.center)

            TextField("z. B. https://dein-gymnasium.de/iserv", text: $tempURL)
                .onSubmit {
                    // Mirror the Weiter button action on Return
                    if let sanitized = sanitize(urlString: tempURL) {
                        iservURLString = sanitized.absoluteString
                        validationError = nil
                    } else {
                        validationError = "Bitte eine gültige URL eingeben."
                    }
                }

            if let validationError {
                Text(validationError)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button("Weiter") {
                if let sanitized = sanitize(urlString: tempURL) {
                    iservURLString = sanitized.absoluteString
                    validationError = nil
                } else {
                    validationError = "Bitte eine gültige URL eingeben."
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func sanitize(urlString: String) -> URL? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Prepend https if missing scheme
        let withScheme: String
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            withScheme = trimmed
        } else {
            withScheme = "https://" + trimmed
        }

        guard let url = URL(string: withScheme) else { return nil }
        // Very basic validation: require host and a dot in host
        guard let host = url.host, host.contains(".") else { return nil }
        return url
    }

    private func hostTitle(from url: URL) -> String {
        url.host ?? "IServ"
    }
}

#Preview {
    ContentView()
}
