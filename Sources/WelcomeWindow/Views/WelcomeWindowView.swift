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

    private let actions: WelcomeActions
    private let onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)?
    private let customRecentsList: ((_ dismissWindow: @escaping () -> Void) -> RecentsView)?

    init(
        actions: WelcomeActions,
        onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)? = nil,
        customRecentsList: ((_ dismissWindow: @escaping () -> Void) -> RecentsView)? = nil
    ) {
        self.actions = actions
        self.onDrop = onDrop
        self.customRecentsList = customRecentsList
    }

    public var body: some View {
        HStack(spacing: 0) {
            WelcomeView(
                dismissWindow: dismissWindow.callAsFunction,
                actions: actions
            )

            if let customList = customRecentsList {
                customList(dismissWindow.callAsFunction)
            } else {
                RecentProjectsListView(dismissWindow: dismissWindow.callAsFunction)
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
                            onDrop?(url, dismissWindow.callAsFunction)
                        }
                    }
                }
            }
            return true
        }
    }
}
