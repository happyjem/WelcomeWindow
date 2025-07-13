//
//  WelcomeWindowView.swift
//  CodeEditModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI
import AppKit

public struct WelcomeWindowView<RecentsView: View, SubtitleView: View>: View {

    @Environment(\.dismiss)
    private var dismissWindow

    @Environment(\.colorScheme)
    private var colorScheme

    @FocusState private var focusedField: FocusTarget?

    @State private var recentProjects: [URL] = RecentsStore.recentProjectURLs()
    @State private var selection: Set<URL> = []

    private let buildActions: (_ dismissWindow: @MainActor @Sendable @escaping () -> Void) -> WelcomeActions
    private let onDrop: ((_ url: URL, _ dismiss: @MainActor @Sendable @escaping () -> Void) -> Void)?
    private let customRecentsList: ((_ dismissWindow: @MainActor @Sendable @escaping () -> Void) -> RecentsView)?
    private let subtitleView: (() -> SubtitleView)?

    let iconImage: Image?
    let title: String?

    public init(
        iconImage: Image? = nil,
        title: String? = nil,
        subtitleView: (() -> SubtitleView)? = nil,
        buildActions: @escaping (_ dismissWindow: @Sendable @escaping () -> Void) -> WelcomeActions,
        onDrop: ((_ url: URL, _ dismiss: @Sendable @escaping () -> Void) -> Void)? = nil,
        customRecentsList: ((_ dismissWindow: @Sendable @escaping () -> Void) -> RecentsView)? = nil
    ) {
        self.iconImage = iconImage
        self.title = title
        self.subtitleView = subtitleView
        self.buildActions = buildActions
        self.onDrop = onDrop
        self.customRecentsList = customRecentsList
    }

    public var body: some View {
        let dismiss = dismissWindow.callAsFunction
        let actions = buildActions(dismiss)

        return HStack(spacing: 0) {
            WelcomeView(
                iconImage: iconImage,
                title: title,
                subtitleView: subtitleView,
                actions: actions,
                dismissWindow: dismiss,
                focusedField: $focusedField
            )

            Group {
                if let customList = customRecentsList {
                    customList(dismiss)
                } else {
                    RecentsListView(
                        recentProjects: $recentProjects,
                        selection: $selection,
                        focusedField: $focusedField,
                        dismissWindow: dismiss
                    )
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .background {
                if colorScheme == .dark {
                    Color(.black).opacity(0.075)
                        .background(.thickMaterial)
                } else {
                    Color(.white).opacity(0.6)
                        .background(.regularMaterial)
                }
            }
        }
        .cursor(.current)
        .edgesIgnoringSafeArea(.top)
        .focused($focusedField, equals: FocusTarget.none)
        .onAppear {
            // Set initial selection
            if !recentProjects.isEmpty {
                selection = [recentProjects[0]]
            }

            // Initial focus
            focusedField = .recentProjects
        }

        .onDrop(of: [.fileURL], isTargeted: .constant(true)) { providers in
            NSApp.activate(ignoringOtherApps: true)
            providers.forEach {
                _ = $0.loadDataRepresentation(for: .fileURL) { data, _ in
                    if let data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        Task { @MainActor in
                            onDrop?(url, dismiss)
                        }
                    }
                }
            }
            return true
        }
    }
}
