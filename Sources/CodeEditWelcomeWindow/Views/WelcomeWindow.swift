//
//  WelcomeWindow.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

public struct WelcomeWindow<Content: View>: Scene {

    let content: (_ dismissWindow: @escaping () -> Void) -> Content
    let onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)?

    public init(
        onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)? = nil,
        @ViewBuilder content: @escaping (_ dismissWindow: @escaping () -> Void) -> Content
    ) {
        self.content = content
        self.onDrop = onDrop
    }

    public var body: some Scene {
        Window("Welcome To \(Bundle.displayName)", id: DefaultSceneID.welcome) {
            ContentView(
                content: content,
                onDrop: onDrop
            )
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

        let content: (_ dismissWindow: @escaping () -> Void) -> Content
        let onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)?

        var body: some View {
            WelcomeWindowView(
                onDrop: onDrop,
                content: { dismissWindow in
                    content(dismissWindow)
                }
            )
        }
    }
}
