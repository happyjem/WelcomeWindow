//
//  WelcomeWindowView.swift
//  CodeEditModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI
import AppKit

public struct WelcomeWindowView<RecentsView: View>: View {

    @Environment(\.dismiss)
    private var dismissWindow

    private let buildActions: (_ dismissWindow: @escaping () -> Void) -> WelcomeActions
    private let onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)?
    private let customRecentsList: ((_ dismissWindow: @escaping () -> Void) -> RecentsView)?

    public init(
        buildActions: @escaping (_ dismissWindow: @escaping () -> Void) -> WelcomeActions,
        onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)? = nil,
        customRecentsList: ((_ dismissWindow: @escaping () -> Void) -> RecentsView)? = nil
    ) {
        self.buildActions = buildActions
        self.onDrop = onDrop
        self.customRecentsList = customRecentsList
    }

    public var body: some View {
        let dismiss = dismissWindow.callAsFunction
        let actions = buildActions(dismiss)

        return HStack(spacing: 0) {
            WelcomeView(
                actions: actions,
                dismissWindow: dismiss
            )

            if let customList = customRecentsList {
                customList(dismiss)
            } else {
                RecentProjectsListView(dismissWindow: dismiss)
            }
        }
        .clipShape(.rect(cornerRadius: 8))
        .cursor(.current)
        .edgesIgnoringSafeArea(.top)
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
