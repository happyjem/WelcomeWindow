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

    private let buildActions: (_ dismissWindow: @Sendable @escaping () -> Void) -> WelcomeActions
    private let customRecentsList: ((_ dismissWindow: @Sendable @escaping () -> Void) -> RecentsView)?
    private let onDrop: ((_ url: URL, _ dismiss: @Sendable @escaping () -> Void) -> Void)?
    private let subtitleView: (() -> SubtitleView)?
    private let openHandler: WelcomeOpenHandler?

    let iconImage: Image?
    let title: String?

    var isMacOS26: Bool {
        if #available(macOS 26, *) {
            return true
        } else {
            return false
        }
    }

    public init(
        iconImage: Image? = nil,
        title: String? = nil,
        @ActionsBuilder actions: @MainActor @escaping @Sendable (_ dismissWindow: @Sendable @escaping () -> Void) -> WelcomeActions,
        customRecentsList: ((_ dismissWindow: @escaping () -> Void) -> RecentsView)? = nil,
        subtitleView: (() -> SubtitleView)? = nil,
        openHandler: WelcomeOpenHandler? = nil,
        onDrop: (@Sendable (_ url: URL, _ dismiss: @Sendable @escaping () -> Void) -> Void)? = nil
    ) {
        self.iconImage = iconImage
        self.title = title
        self.buildActions = actions
        self.customRecentsList = customRecentsList
        self.subtitleView = subtitleView
        self.onDrop = onDrop
        self.openHandler = openHandler
    }

    public var body: some Scene {

        Window("Welcome To \(Bundle.displayName)", id: DefaultSceneID.welcome) {
            WelcomeWindowView(
                iconImage: iconImage,
                title: title,
                subtitleView: subtitleView,
                buildActions: buildActions,
                onDrop: onDrop,
                customRecentsList: customRecentsList,
                openHandler: openHandler
            )
            .frame(width: 740, height: isMacOS26 ? 460 - 28 : 460)
            .task {
                if let window = NSApp.findWindow(DefaultSceneID.welcome) {
                    window.styleMask.insert(.fullSizeContentView)
                    window.standardWindowButton(.closeButton)?.isHidden = true
                    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    window.standardWindowButton(.zoomButton)?.isHidden = true
                    window.backgroundColor = .clear
                    window.isMovableByWindowBackground = true
                }
            }
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}

/// A closure type used to handle opening recent items from the default `RecentsListView`.
///
/// This allows apps to override the default `NSDocumentController` behavior for
/// opening files, making the handling of recent-item URLs fully configurable.
///
/// The closure is executed on the **main actor** to ensure UI safety.
///
/// - Parameters:
///   - urls: The recent-item URLs selected by the user to be opened.
///   - dismiss: A closure to invoke when the opening process is complete and the
///              `RecentsListView` can be dismissed.
///
public typealias WelcomeOpenHandler = @MainActor (_ urls: [URL], _ dismiss: @Sendable @escaping () -> Void) -> Void

// ──────────────────────────────────────────────────────────────
// 1)  NEITHER a custom recents list NOR a subtitle view
// ──────────────────────────────────────────────────────────────
extension WelcomeWindow where RecentsView == EmptyView, SubtitleView == EmptyView {
    /// Creates a welcome window without a custom recent-projects list
    /// *and* without a custom subtitle view.
    public init(
        iconImage: Image? = nil,
        title: String?    = nil,
        @ActionsBuilder actions: @Sendable @escaping (_ dismissWindow: @escaping () -> Void) -> WelcomeActions,
        openHandler: WelcomeOpenHandler? = nil,
        onDrop: (@Sendable(_ url: URL, _ dismissWindow: @escaping () -> Void) -> Void)? = nil
    ) {
        self.init(
            iconImage: iconImage,
            title: title,
            actions: actions,
            customRecentsList: nil,
            subtitleView: nil,
            openHandler: openHandler,
            onDrop: onDrop
        )
    }
}

// ──────────────────────────────────────────────────────────────
// 2)  ONLY a custom subtitle view
// ──────────────────────────────────────────────────────────────
extension WelcomeWindow where RecentsView == EmptyView {
    /// Creates a welcome window that shows a custom subtitle view
    /// but no custom recent-projects list.
    public init(
        iconImage: Image? = nil,
        title: String?    = nil,
        subtitleView: @escaping () -> SubtitleView,
        @ActionsBuilder actions: @Sendable @escaping (_ dismissWindow: @escaping () -> Void) -> WelcomeActions,
        openHandler: WelcomeOpenHandler? = nil,
        onDrop: (@Sendable (_ url: URL, _ dismissWindow: @escaping () -> Void) -> Void)? = nil
    ) {
        self.init(
            iconImage: iconImage,
            title: title,
            actions: actions,
            customRecentsList: nil,
            subtitleView: subtitleView,
            openHandler: openHandler,
            onDrop: onDrop
        )
    }
}

// ──────────────────────────────────────────────────────────────
// 3)  ONLY a custom recent-projects list
// ──────────────────────────────────────────────────────────────
extension WelcomeWindow where SubtitleView == EmptyView {
    /// Creates a welcome window that shows a custom recent-projects list
    /// but no custom subtitle view.
    public init(
        iconImage: Image? = nil,
        title: String?    = nil,
        @ActionsBuilder actions: @Sendable @escaping (_ dismissWindow: @escaping () -> Void) -> WelcomeActions,
        customRecentsList: ((_ dismissWindow: @escaping () -> Void) -> RecentsView)? = nil,
        onDrop: (@Sendable (_ url: URL, _ dismissWindow: @escaping () -> Void) -> Void)? = nil,
        openHandler: WelcomeOpenHandler? = nil
    ) {
        self.init(
            iconImage: iconImage,
            title: title,
            actions: actions,
            customRecentsList: customRecentsList,
            subtitleView: nil,
            openHandler: openHandler,
            onDrop: onDrop
        )
    }
}

