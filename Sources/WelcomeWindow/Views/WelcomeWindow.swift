//
//  WelcomeWindow.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

/// A customizable welcome window scene supporting up to three content views
/// and an optional custom recent projects list.
public struct WelcomeWindow<RecentsView: View, SubtitleView: View>: Scene {

    private let buildActions: (_ dismissWindow: @escaping () -> Void) -> WelcomeActions
    private let customRecentsList: ((_ dismissWindow: @escaping () -> Void) -> RecentsView)?
    private let onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)?
    private let subtitleView: (() -> SubtitleView)?

    let iconImage: Image?
    let title: String?

    public init(
        iconImage: Image? = nil,
        title: String? = nil,
        @ActionsBuilder actions: @escaping (_ dismissWindow: @escaping () -> Void) -> WelcomeActions,
        customRecentsList: ((_ dismissWindow: @escaping () -> Void) -> RecentsView)? = nil,
        subtitleView: (() -> SubtitleView)? = nil,
        onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)? = nil
    ) {
        self.iconImage = iconImage
        self.title = title
        self.buildActions = actions
        self.customRecentsList = customRecentsList
        self.subtitleView = subtitleView
        self.onDrop = onDrop
    }

    public var body: some Scene {
        #if swift(>=5.9)
        if #available(macOS 15, *) {
            return Window("Welcome To \(Bundle.displayName)", id: DefaultSceneID.welcome) {
                WelcomeWindowView(
                    iconImage: iconImage,
                    title: title,
                    subtitleView: subtitleView,
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
                iconImage: iconImage,
                title: title,
                subtitleView: subtitleView,
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
    ///   - iconImage: An optional override for icon image.
    ///   - title: An optional title override.
    ///   - subtitle: An optional subtitle override.
    ///   - actions: A result builder closure that defines up to three SwiftUI action views.
    ///   - onDrop: An optional closure that handles dropped URLs.
    public init(
        iconImage: Image? = nil,
        title: String? = nil,
        @ActionsBuilder actions: @escaping (_ dismissWindow: @escaping () -> Void) -> WelcomeActions,
        onDrop: ((_ url: URL, _ dismissWindow: @escaping () -> Void) -> Void)? = nil
    ) {
        self.init(
            iconImage: iconImage,
            title: title,
            actions: actions,
            customRecentsList: nil,
            onDrop: onDrop
        )
    }
}

// ONLY SUBTITLE VIEW
extension WelcomeWindow where RecentsView == EmptyView {
    /// Initializer for only subtitle view.
    public init(
        iconImage: Image? = nil,
        title: String? = nil,
        subtitleView: @escaping () -> SubtitleView,
        @ActionsBuilder actions: @escaping (_ dismissWindow: @escaping () -> Void) -> WelcomeActions,
        onDrop: ((_ url: URL, _ dismissWindow: @escaping () -> Void) -> Void)? = nil
    ) {
        self.init(
            iconImage: iconImage,
            title: title,
            actions: actions,
            customRecentsList: nil,
            subtitleView: subtitleView,
            onDrop: onDrop
        )
    }
}

// ONLY RECENTS LIST
extension WelcomeWindow where SubtitleView == EmptyView {
    /// Initializer for only recents list view.
    public init(
        iconImage: Image? = nil,
        title: String? = nil,
        @ActionsBuilder actions: @escaping (_ dismissWindow: @escaping () -> Void) -> WelcomeActions,
        customRecentsList: ((_ dismissWindow: @escaping () -> Void) -> RecentsView)? = nil,
        onDrop: ((_ url: URL, _ dismissWindow: @escaping () -> Void) -> Void)? = nil
    ) {
        self.init(
            iconImage: iconImage,
            title: title,
            actions: actions,
            customRecentsList: customRecentsList,
            subtitleView: nil,
            onDrop: onDrop
        )
    }
}

// NEITHER OPTIONAL VIEW
extension WelcomeWindow where RecentsView == EmptyView, SubtitleView == EmptyView {
    /// Initializer for neither of optionals provided.
    public init(
        iconImage: Image? = nil,
        title: String? = nil,
        @ActionsBuilder actions: @escaping (_ dismissWindow: @escaping () -> Void) -> WelcomeActions,
        onDrop: ((_ url: URL, _ dismissWindow: @escaping () -> Void) -> Void)? = nil
    ) {
        self.init(
            iconImage: iconImage,
            title: title,
            actions: actions,
            customRecentsList: nil,
            subtitleView: nil,
            onDrop: onDrop
        )
    }
}
