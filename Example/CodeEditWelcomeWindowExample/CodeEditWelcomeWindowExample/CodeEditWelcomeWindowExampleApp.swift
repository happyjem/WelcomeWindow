//
//  CodeEditWelcomeWindowExampleApp.swift
//  CodeEditWelcomeWindowExample
//
//  Created by Giorgi Tchelidze on 24.05.25.
//

import SwiftUI
import CodeEditWelcomeWindow

@main
struct CodeEditWelcomeWindowExampleApp: App {

    private let handler = TXTDocumentController.shared

    var body: some Scene {
        Group {
            WelcomeWindow(
                onDrop: { url, dismiss in
                    print("File dropped at: \(url.path)")

                    Task {
//                        handler.openDocument(at: url) {
//                            Task { @MainActor in
//                                dismiss()
//                            }
//                        }
                    }
                },
                content: { dismiss in
                    WelcomeActionView(
                        iconName: "circle.fill",
                        title: "New Text Document",
                        action: { handler.createNewDocumentWithDialog(onCompletion: { dismiss() }) }
                    )
                    WelcomeActionView(
                        iconName: "square.fill",
                        title: "Git Clone Text Document",
                        action: { print("Show some git clone UI") }
                    )
                    WelcomeActionView(
                        iconName: "triangle.fill",
                        title: "Open Text Document",
                        action: {
                            handler.openDocument(nil)
//                            {
//                                print("Document opened successfully")
//                                dismiss()
//                            }
                        }
                    )
                }
            )

            WindowGroup("Hello world") {
                VStack {
                    Text("Jello")
                }
            }
        }
    }
}
