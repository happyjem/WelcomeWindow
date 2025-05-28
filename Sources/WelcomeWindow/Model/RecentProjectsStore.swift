//
//  RecentProjectsUtil.swift
//  CodeEdit
//
//  Created by Khan Winter on 10/22/24.
//

import AppKit

/// A utility store for managing recent project file access using security-scoped bookmarks.
public enum RecentProjectsStore {

    /// The UserDefaults key for storing recent project bookmarks.
    private static let bookmarksKey = "recentProjectBookmarks"

    /// Notification sent when the recent projects list is updated.
    public static let didUpdateNotification = Notification.Name("RecentProjectsStore.didUpdate")

    /// Internal representation of a bookmark entry.
    private struct BookmarkEntry: Codable, Equatable {
        /// The standardized file path of the bookmarked URL.
        let urlPath: String

        /// The bookmark data associated with the URL.
        let bookmarkData: Data

        /// Resolves and returns the `URL` from the bookmark data, or `nil` if resolution fails.
        var url: URL? {
            var isStale = false
            return try? URL(
                resolvingBookmarkData: bookmarkData,
                options: [.withoutUI, .withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
        }

        static func == (lhs: BookmarkEntry, rhs: BookmarkEntry) -> Bool {
            lhs.urlPath == rhs.urlPath
        }
    }

    // MARK: - Public API

    /// Returns an array of all recent project URLs resolved from stored bookmarks.
    ///
    /// - Returns: An array of `URL` representing the recent projects.
    public static func recentProjectURLs() -> [URL] {
        var seen = Set<String>()
        return loadBookmarks().compactMap { entry in
            guard let resolved = entry.url else { return nil }
            let path = resolved.standardized.path
            guard !seen.contains(path) else { return nil }
            seen.insert(path)
            return resolved
        }
    }

    /// Notifies the store that a project was opened.
    ///
    /// This saves a security-scoped bookmark for the URL and moves it to the top of the recent list.
    ///
    /// - Parameter url: The file URL of the opened document.
    public static func documentOpened(at url: URL) {
        do {
            let bookmark = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            var bookmarks = loadBookmarks()

            let standardizedPath = url.standardized.path
            bookmarks.removeAll(where: { $0.urlPath == standardizedPath })
            bookmarks.insert(BookmarkEntry(urlPath: standardizedPath, bookmarkData: bookmark), at: 0)

            saveBookmarks(Array(bookmarks.prefix(100)))
        } catch {
            print("❌ Failed to create bookmark for recent project: \(error)")
        }
    }

    /// Removes specific project URLs from the recent list.
    ///
    /// - Parameter urlsToRemove: A set of URLs to remove from the recent projects list.
    /// - Returns: The updated list of recent project URLs.
    public static func removeRecentProjects(_ urlsToRemove: Set<URL>) -> [URL] {
        var bookmarks = loadBookmarks()
        bookmarks.removeAll(where: { entry in
            urlsToRemove.contains(where: { $0.path == entry.urlPath })
        })
        saveBookmarks(bookmarks)
        return recentProjectURLs()
    }

    /// Clears all stored recent project bookmarks.
    public static func clearList() {
        saveBookmarks([])
    }

    // MARK: - Bookmark Access

    /// Begins accessing a security-scoped resource before opening a project.
    ///
    /// - Parameter url: The URL of the project to access.
    /// - Returns: `true` if access began successfully; otherwise, `false`.
    public static func beginAccessing(_ url: URL) -> Bool {
        url.startAccessingSecurityScopedResource()
    }

    /// Ends access to a previously accessed security-scoped resource.
    ///
    /// - Parameter url: The URL of the project to stop accessing.
    public static func endAccessing(_ url: URL) {
        url.stopAccessingSecurityScopedResource()
    }

    // MARK: - Internal

    /// Loads the stored bookmarks from UserDefaults.
    ///
    /// - Returns: An array of `BookmarkEntry` values decoded from UserDefaults.
    private static func loadBookmarks() -> [BookmarkEntry] {
        guard let data = UserDefaults.standard.data(forKey: bookmarksKey),
              let decoded = try? PropertyListDecoder().decode([BookmarkEntry].self, from: data)
        else { return [] }
        return decoded
    }

    /// Saves an array of bookmark entries to UserDefaults and posts an update notification.
    ///
    /// - Parameter entries: The bookmark entries to save.
    private static func saveBookmarks(_ entries: [BookmarkEntry]) {
        guard let data = try? PropertyListEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: bookmarksKey)
        NotificationCenter.default.post(name: didUpdateNotification, object: nil)
    }
}
