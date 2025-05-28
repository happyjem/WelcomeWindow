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

    @FocusState private var focusedField: FocusTarget?

    @State private var eventMonitor: Any?
    @State private var recentProjects: [URL] = RecentProjectsStore.recentProjectURLs()
    @State private var selection: Set<URL> = []
    @State private var actionCount: Int = 0

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
                dismissWindow: dismiss,
                focusedField: $focusedField
            )

            if let customList = customRecentsList {
                customList(dismiss)
            } else {
                RecentProjectsListView(
                    recentProjects: $recentProjects,
                    selection: $selection,
                    focusedField: $focusedField,
                    dismissWindow: dismiss
                )
            }
        }
        .clipShape(.rect(cornerRadius: 8))
        .cursor(.current)
        .edgesIgnoringSafeArea(.top)
        .focused($focusedField, equals: FocusTarget.none)
        .onAppear {
            // Set initial selection
            if !recentProjects.isEmpty {
                selection = [recentProjects[0]]
            }

            // Determine how many actions are defined
            switch actions {
            case .none:
                actionCount = 0
            case .one:
                actionCount = 1
            case .two:
                actionCount = 2
            case .three:
                actionCount = 3
            }

            // Initial focus
            focusedField = .recentProjects

            // Monitor key input
            self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
                return handleKeyDown(event)
            }
        }
        .onDisappear {
            if let monitor = eventMonitor {
                NSEvent.removeMonitor(monitor)
                eventMonitor = nil
            }
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

    // MARK: - Keyboard Handling

    private func handleKeyDown(_ event: NSEvent) -> NSEvent? {
        switch event.keyCode {
        case 126: // Arrow Up
            if focusedField == .recentProjects {
                return handleArrowUp() ? nil : event
            }
        case 125: // Arrow Down
            if focusedField == .recentProjects {
                return handleArrowDown() ? nil : event
            }
        case 36, 76: // Return / Enter
            if focusedField == .recentProjects {
                return handleReturnKey() ? nil : event
            } else if focusedField == .dismissButton {
                dismissWindow()
                return nil
            }
        case 48: // Tab
            switchFocus()
            return nil
        default:
            break
        }
        return event
    }

    private func handleArrowUp() -> Bool {
        guard let current = selection.first.flatMap({ recentProjects.firstIndex(of: $0) }) else {
            selection = Set(recentProjects.suffix(1))
            return true
        }
        if current > 0 {
            selection = [recentProjects[current - 1]]
        }
        return true
    }

    private func handleArrowDown() -> Bool {
        guard let current = selection.first.flatMap({ recentProjects.firstIndex(of: $0) }) else {
            selection = Set(recentProjects.prefix(1))
            return true
        }
        if current < recentProjects.count - 1 {
            selection = [recentProjects[current + 1]]
        }
        return true
    }

    private func handleReturnKey() -> Bool {
        guard let selected = selection.first else { return false }
        NSDocumentController.shared.openDocument(at: selected) {
            dismissWindow()
        }
        return true
    }

    private func switchFocus() {
        let focusOrder: [FocusTarget] = {
            var order: [FocusTarget] = [.dismissButton]
            if actionCount >= 1 { order.append(.action1) }
            if actionCount >= 2 { order.append(.action2) }
            if actionCount >= 3 { order.append(.action3) }
            order.append(.recentProjects)
            return order
        }()

        guard let current = focusedField,
              let currentIndex = focusOrder.firstIndex(of: current) else {
            focusedField = .dismissButton // start at dismiss
            return
        }

        let nextIndex = (currentIndex + 1) % focusOrder.count
        focusedField = focusOrder[nextIndex]
    }

}
