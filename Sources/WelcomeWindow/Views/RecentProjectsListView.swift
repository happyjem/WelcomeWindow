//
//  RecentProjectsListView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 02/02/2023.
//

import SwiftUI
import CoreSpotlight
import AppKit

public struct RecentProjectsListView: View {

    @Environment(\.colorScheme)
    private var colorScheme

    @FocusState private var isFocused: Bool

    @State private var selection: Set<URL>
    @State private var recentProjects: [URL]
    @State private var eventMonitor: Any?

    private let dismissWindow: () -> Void

    public init(dismissWindow: @escaping () -> Void) {
        self.dismissWindow = dismissWindow
        let urls = RecentProjectsStore.recentProjectURLs()
        self._recentProjects = State(initialValue: urls)
        self._selection = State(initialValue: Set(urls.prefix(1)))
    }

    private var listEmptyView: some View {
        VStack {
            Spacer()
            Text(NSLocalizedString("No Recent Projects", comment: ""))
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    public var body: some View {
        List(recentProjects, id: \.self, selection: $selection) { project in
            RecentProjectListItem(projectPath: project)
        }
        .focused($isFocused)
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .contextMenu(forSelectionType: URL.self) { items in
            if !items.isEmpty {
                Button("Show in Finder") {
                    NSWorkspace.shared.activateFileViewerSelecting(Array(items))
                }

                Button("Copy path\(items.count > 1 ? "s" : "")") {
                    let pasteBoard = NSPasteboard.general
                    pasteBoard.clearContents()
                    pasteBoard.writeObjects(selection.map(\.relativePath) as [NSString])
                }

                Button("Remove from Recents") {
                    removeRecentProjects()
                }
            }
        } primaryAction: { items in
            for url in items {
                NSDocumentController.shared.openDocument(at: url) {
                    dismissWindow()
                }
            }
        }
        .onCopyCommand {
            selection.map { NSItemProvider(object: $0.path(percentEncoded: false) as NSString) }
        }
        .onDeleteCommand {
            removeRecentProjects()
        }
        .background {
            if self.colorScheme == .dark {
                Color(.black).opacity(0.075)
                    .background(.thickMaterial)
            } else {
                Color(.white).opacity(0.6)
                    .background(.regularMaterial)
            }
        }
        .background {
            Button("") {
                selection.forEach { url in
                    NSDocumentController.shared.openDocument(at: url) {
                        dismissWindow()
                    }
                }
            }
            .keyboardShortcut(.defaultAction)
            .hidden()
        }
        .overlay {
            if recentProjects.isEmpty {
                listEmptyView
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: RecentProjectsStore.didUpdateNotification)) { _ in
            updateRecentProjects()
        }
        .onAppear {
            isFocused = true
            self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
                switch event.keyCode {
                case 126: // up arrow
                    return handleArrowUpKeyPressed() == .handled ? nil : event
                case 125: // down arrow
                    return handleArrowDownKeyPressed() == .handled ? nil : event
                case 36, 76: // return/enter
                    return handleReturnKeyPressed() == .handled ? nil : event
                default:
                    return event
                }
            }
        }
    }

    // MARK: - Actions

    private func removeRecentProjects() {
        recentProjects = RecentProjectsStore.removeRecentProjects(selection)
    }

    private func updateRecentProjects() {
        recentProjects = RecentProjectsStore.recentProjectURLs()
        if !recentProjects.isEmpty {
            selection = Set(recentProjects.prefix(1))
        }
    }

    // MARK: - Key Handling

    private enum KeyHandlingResult {
        case handled
        case notHandled
    }

    @discardableResult
    private func handleArrowUpKeyPressed() -> KeyHandlingResult {
        guard let current = currentSelectedIndex() else {
            selection = Set(recentProjects.suffix(1))
            return .handled
        }
        if current > 0 {
            selection = [recentProjects[current - 1]]
            return .handled
        }
        return .handled
    }

    @discardableResult
    private func handleArrowDownKeyPressed() -> KeyHandlingResult {
        guard let current = currentSelectedIndex() else {
            selection = Set(recentProjects.prefix(1))
            return .handled
        }
        if current < recentProjects.count - 1 {
            selection = [recentProjects[current + 1]]
            return .handled
        }
        return .handled
    }

    @discardableResult
    private func handleReturnKeyPressed() -> KeyHandlingResult {
        guard let selected = selection.first else { return .notHandled }
        NSDocumentController.shared.openDocument(at: selected) {
            dismissWindow()
        }
        return .handled
    }

    private func currentSelectedIndex() -> Int? {
        guard let selected = selection.first else { return nil }
        return recentProjects.firstIndex(of: selected)
    }
}
