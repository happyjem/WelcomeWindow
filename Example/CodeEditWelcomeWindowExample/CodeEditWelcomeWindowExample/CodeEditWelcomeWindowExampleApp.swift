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

    @Environment(\.openWindow) private var openWindow
    private let handler = TXTDocumentController.shared

    var body: some Scene {
        Group {
            WelcomeWindow(
                content: { dismiss in
                    ( WelcomeActionView(
                        iconName: "circle.fill",
                        title: "New Text Document",
                        action: { handler.createNewDocumentWithDialog(
                            configuration: .init(title: "Create new text document"),
                            onCompletion: { dismiss() }
                        )
                            
                        }
                    ),
//                      WelcomeActionView(
//                        iconName: "square.fill",
//                        title: "Git Clone Text Document",
//                        action: { print("Show some git clone UI") }
//                      ),
                      WelcomeActionView(
                        iconName: "triangle.fill",
                        title: "Open Text Document",
                        action: {
                            handler.openDocumentWithDialog(
                                onDialogPresented: { dismiss() },
                                onCancel: { openWindow(id: "welcome") }
                            )
                        }
                      )
                )
                },
                onDrop: { url, dismiss in
                    print("File dropped at: \(url.path)")
                    
                    Task {
                        handler.openDocument(at: url, onCompletion: { dismiss() })
                    }
                }

            )
        }
    }
}
