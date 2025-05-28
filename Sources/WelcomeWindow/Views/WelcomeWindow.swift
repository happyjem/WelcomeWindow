//
//  WelcomeWindow.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

/// A customizable welcome window scene supporting up to three content views
/// and an optional custom recent projects list.
public struct WelcomeWindow<RecentsView: View>: Scene {
    private let buildActions: (_ dismissWindow: @escaping () -> Void) -> WelcomeActions
    private let customRecentsList: ((_ dismissWindow: @escaping () -> Void) -> RecentsView)?
    private let onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)?

    public init(
        @ActionsBuilder actions: @escaping (_ dismissWindow: @escaping () -> Void) -> WelcomeActions,
        customRecentsList: ((_ dismissWindow: @escaping () -> Void) -> RecentsView)? = nil,
        onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)? = nil
    ) {
        self.buildActions = actions
        self.customRecentsList = customRecentsList
        self.onDrop = onDrop
    }

    public var body: some Scene {
        #if swift(>=5.9)
        if #available(macOS 15, *) {
            return Window("Welcome To \(Bundle.displayName)", id: DefaultSceneID.welcome) {
                WelcomeWindowView(
                    buildActions: buildActions,
                    onDrop: onDrop,
                    customRecentsList: customRecentsList
                )
                .frame(width: 740, height: 460)
                .task {
                    if let window = NSApp.findWindow(DefaultSceneID.welcome) {
                        window.standardWindowButton(.closeButton)?.isHidden = true
                        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                        window.standardWindowButton(.zoomButton)?.isHidden = true
                        window.hasShadow = true
                        window.isMovableByWindowBackground = true
                    }
                }
            }
            .windowStyle(.plain)
            .windowResizability(.contentSize)
            .defaultLaunchBehavior(.presented)
        } else {
            return legacyWindow
        }
        #else
        return legacyWindow
        #endif
    }

    private var legacyWindow: some Scene {
        Window("Welcome To \(Bundle.displayName)", id: DefaultSceneID.welcome) {
            WelcomeWindowView(
                buildActions: buildActions,
                onDrop: onDrop,
                customRecentsList: customRecentsList
            )
            .frame(width: 740, height: 432)
            .task {
                if let window = NSApp.findWindow(DefaultSceneID.welcome) {
                    window.styleMask.insert(.borderless)
                    window.standardWindowButton(.closeButton)?.isHidden = true
                    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    window.standardWindowButton(.zoomButton)?.isHidden = true
                    window.backgroundColor = .clear
                    window.isMovableByWindowBackground = true
                }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

extension WelcomeWindow where RecentsView == EmptyView {
    /// Creates a welcome window without a custom recent projects list.
    /// - Parameters:
    ///   - actions: A result builder closure that defines up to three SwiftUI action views.
    ///   - onDrop: An optional closure that handles dropped URLs.
    public init(
        @ActionsBuilder actions: @escaping (_ dismissWindow: @escaping () -> Void) -> WelcomeActions,
        onDrop: ((_ url: URL, _ dismissWindow: @escaping () -> Void) -> Void)? = nil
    ) {
        self.init(
            actions: actions,
            customRecentsList: nil,
            onDrop: onDrop
        )
    }
}
