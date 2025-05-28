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
    private let contentBuilder: (_ dismissWindow: @escaping () -> Void) -> AnyView
    private let customRecentsList: ((_ dismissWindow: @escaping () -> Void) -> RecentsView)?
    private let onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)?
    private let viewCount: Int

    /// Initializes the welcome window with a single content view.
    ///
    /// - Parameters:
    ///   - content: A closure returning a view to display.
    ///   - onDrop: An optional handler for file drops.
    public init<A: View>(
        content: @escaping (_ dismissWindow: @escaping () -> Void) -> A,
        onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)? = nil
    ) where RecentsView == EmptyView {
        self.contentBuilder = { dismiss in AnyView(content(dismiss)) }
        self.customRecentsList = nil
        self.onDrop = onDrop
        self.viewCount = 1
    }

    /// Initializes the welcome window with a single content view and a custom recents list.
    public init<A: View>(
        content: @escaping (_ dismissWindow: @escaping () -> Void) -> A,
        customRecentsList: @escaping (_ dismissWindow: @escaping () -> Void) -> RecentsView,
        onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)? = nil
    ) {
        self.contentBuilder = { dismiss in AnyView(content(dismiss)) }
        self.customRecentsList = customRecentsList
        self.onDrop = onDrop
        self.viewCount = 1
    }

    /// Initializes the welcome window with two content views.
    public init<A: View, B: View>(
        content: @escaping (_ dismissWindow: @escaping () -> Void) -> (A, B),
        onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)? = nil
    ) where RecentsView == EmptyView {
        self.contentBuilder = { dismiss in
            let views = content(dismiss)
            return AnyView(TupleView((views.0, views.1)))
        }
        self.customRecentsList = nil
        self.onDrop = onDrop
        self.viewCount = 2
    }

    /// Initializes the welcome window with two content views and a custom recents list.
    public init<A: View, B: View>(
        content: @escaping (_ dismissWindow: @escaping () -> Void) -> (A, B),
        customRecentsList: @escaping (_ dismissWindow: @escaping () -> Void) -> RecentsView,
        onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)? = nil
    ) {
        self.contentBuilder = { dismiss in
            let views = content(dismiss)
            return AnyView(TupleView((views.0, views.1)))
        }
        self.customRecentsList = customRecentsList
        self.onDrop = onDrop
        self.viewCount = 2
    }

    /// Initializes the welcome window with three content views.
    public init<A: View, B: View, C: View>(
        // swiftlint:disable:next large_tuple
        content: @escaping (_ dismissWindow: @escaping () -> Void) -> (A, B, C),
        onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)? = nil
    ) where RecentsView == EmptyView {
        self.contentBuilder = { dismiss in
            let views = content(dismiss)
            return AnyView(TupleView((views.0, views.1, views.2)))
        }
        self.customRecentsList = nil
        self.onDrop = onDrop
        self.viewCount = 3
    }

    /// Initializes the welcome window with three content views and a custom recents list.
    public init<A: View, B: View, C: View>(
        // swiftlint:disable:next large_tuple
        content: @escaping (_ dismissWindow: @escaping () -> Void) -> (A, B, C),
        customRecentsList: @escaping (_ dismissWindow: @escaping () -> Void) -> RecentsView,
        onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)? = nil
    ) {
        self.contentBuilder = { dismiss in
            let views = content(dismiss)
            return AnyView(TupleView((views.0, views.1, views.2)))
        }
        self.customRecentsList = customRecentsList
        self.onDrop = onDrop
        self.viewCount = 3
    }

    /// The scene body for the welcome window.
    public var body: some Scene {
        #if swift(>=5.9)
        if #available(macOS 15, *) {
            return Window("Welcome To \(Bundle.displayName)", id: DefaultSceneID.welcome) {
                ContentView(
                    content: contentBuilder,
                    onDrop: onDrop,
                    customRecentsList: customRecentsList,
                    viewCount: viewCount
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

    /// A fallback window definition for older macOS versions.
    private var legacyWindow: some Scene {
        Window("Welcome To \(Bundle.displayName)", id: DefaultSceneID.welcome) {
            ContentView(
                content: contentBuilder,
                onDrop: onDrop,
                customRecentsList: customRecentsList,
                viewCount: viewCount
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

    /// The internal content container used inside the welcome window scene.
    private struct ContentView: View {
        let content: (_ dismissWindow: @escaping () -> Void) -> AnyView
        let onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)?
        let customRecentsList: ((_ dismissWindow: @escaping () -> Void) -> RecentsView)?
        let viewCount: Int

        var body: some View {
            WelcomeWindowView(
                content: content,
                onDrop: onDrop,
                viewCount: viewCount,
                customRecentsList: customRecentsList
            )
        }
    }
}
