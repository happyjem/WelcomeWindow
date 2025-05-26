//
//  WelcomeWindowView.swift
//  CodeEditModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI
import AppKit

public struct WelcomeWindowView<Content: View>: View {

    @Environment(\.dismiss) private var dismissWindow

    private let contentBuilder: (_ dismissWindow: @escaping () -> Void) -> Content
    private let onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)?
    private let viewCount: Int

    public init(
        @ViewBuilder content: @escaping (_ dismissWindow: @escaping () -> Void) -> Content,
        onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)? = nil,
        viewCount: Int = 0
    ) {
        self.contentBuilder = content
        self.onDrop = onDrop
        self.viewCount = viewCount
    }

    public var body: some View {
        HStack(spacing: 0) {
            WelcomeView(
                dismissWindow: dismissWindow.callAsFunction,
                content: contentBuilder,
                viewCount: viewCount
            )

            RecentProjectsListView(
                dismissWindow: dismissWindow.callAsFunction
            )
        }
        .clipShape(.rect(cornerRadius: 8))
//        .onAppear {
//            NSApplication.shared.windows.first?.isMovableByWindowBackground = true
//            NSApplication.shared.windows.first?.hasShadow = true
//        }
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
