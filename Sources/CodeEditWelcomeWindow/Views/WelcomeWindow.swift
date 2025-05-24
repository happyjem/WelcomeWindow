//
//  WelcomeWindow.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct WelcomeWindow: Scene {

    let documentHandler: ProjectDocumentHandler

    var body: some Scene {
        Window("Welcome To \(Bundle.displayName)", id: DefaultSceneID.welcome) {
            ContentView(documentHandler: documentHandler)
            .frame(width: 740, height: 432)
            .task {
                if let window = NSApp.findWindow(DefaultSceneID.welcome) {
                    window.standardWindowButton(.closeButton)?.isHidden = true
                    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    window.standardWindowButton(.zoomButton)?.isHidden = true
                    window.isMovableByWindowBackground = true
                }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
    
    private struct ContentView: View {
        @Environment(\.dismiss)
        var dismiss
        
        let documentHandler: ProjectDocumentHandler

        var body: some View {
            WelcomeWindowView(
                documentHandler: documentHandler,
                dismissWindow: { dismiss() }
            )
        }
    }
}
