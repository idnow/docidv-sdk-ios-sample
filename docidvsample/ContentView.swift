//
//  ContentView.swift
//  docidvsample
//
//  Created by Nabil LAHLOU on 13/04/2026.
//

import SwiftUI
import DocIDV

/// View of the sample
struct ContentView: View {
    // MARK: - Private properties
    @State private var token: String = ""
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false

    // MARK: - View
    var body: some View {
        VStack(spacing: 16) {
            TextField("Enter your token",
                      text: Binding(get: { token },
                                    set: { token = $0 }))
            .frame(height: 48)
            .foregroundColor(.secondary)
            .padding([.horizontal], 16)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.secondary, lineWidth: 1)
            )
            .textInputAutocapitalization(.characters)

            Button(action: {
                startSDK()
            }) {
                Text("Start the SDK")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
}

// MARK: - Private methods
private extension ContentView {
    /// Starts the SDK on a task
    func startSDK() {
        Task { @MainActor in
            guard let viewController = getTopViewController() else {
                print("No view controller available")
                return
            }

            do {
                try await IDnowDocIDV.shared.start(token: token,
                                                   viewController: viewController)
                showAlert(title: "🎉 Success", message: "The SDK session finished successfully.")
            } catch let error as IDnowDocIDVError {
                showAlert(title: "❌ Error", message: "\(error)")
            }
        }
    }

    /// Returns the top view controller of the app
    func getTopViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        guard var topController = keyWindow?.rootViewController else {
            return nil
        }

        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }

    /// Shows the alert with given title and message
    func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
