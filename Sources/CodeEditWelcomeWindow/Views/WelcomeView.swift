//
//  WelcomeView.swift
//  CodeEditModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI
import AppKit
import Foundation

public struct WelcomeView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.controlActiveState) var controlActiveState

    @State private var isHoveringCloseButton = false

    private let dismissWindow: () -> Void
    private let contentBuilder: (_ dismissWindow: @escaping () -> Void) -> Content

    public init(
        dismissWindow: @escaping () -> Void,
        @ViewBuilder content: @escaping (_ dismissWindow: @escaping () -> Void) -> Content
    ) {
        self.dismissWindow = dismissWindow
        self.contentBuilder = content
    }

    private var appVersion: String { Bundle.versionString ?? "" }
    private var appBuild: String { Bundle.buildString ?? "" }
    private var appVersionPostfix: String { Bundle.versionPostfix ?? "" }

    private var macOSVersion: String {
        let url = URL(fileURLWithPath: "/System/Library/CoreServices/SystemVersion.plist")
        guard let dict = NSDictionary(contentsOf: url),
              let version = dict["ProductUserVisibleVersion"],
              let build = dict["ProductBuildVersion"] else {
            return ProcessInfo.processInfo.operatingSystemVersionString
        }
        return "\(version) (\(build))"
    }

    private var xcodeVersion: String? {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.dt.Xcode"),
              let bundle = Bundle(url: url),
              let infoDict = bundle.infoDictionary,
              let version = infoDict["CFBundleShortVersionString"] as? String,
              let buildURL = URL(string: "\(url)Contents/version.plist"),
              let buildDict = try? NSDictionary(contentsOf: buildURL, error: ()),
              let build = buildDict["ProductBuildVersion"]
        else {
            return nil
        }
        return "\(version) (\(build))"
    }

    private func copyInformation() {
        var copyString = "\(Bundle.displayName): \(appVersion)\(appVersionPostfix) (\(appBuild))\n"
        copyString.append("macOS: \(macOSVersion)\n")
        if let xcodeVersion { copyString.append("Xcode: \(xcodeVersion)") }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(copyString, forType: .string)
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            mainContent
            dismissButton
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 32)
            ZStack {
                if colorScheme == .dark {
                    Rectangle()
                        .frame(width: 104, height: 104)
                        .foregroundColor(.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .blur(radius: 64)
                        .opacity(0.5)
                }
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 128, height: 128)
            }
            Text(Bundle.displayName)
                .font(.system(size: 36, weight: .bold))
            Text(String(format: NSLocalizedString("Version %@%@ (%@)", comment: ""),
                        appVersion, appVersionPostfix, appBuild))
                .textSelection(.enabled)
                .foregroundColor(.secondary)
                .font(.system(size: 13.5))
                .onHover { $0 ? NSCursor.pointingHand.push() : NSCursor.pop() }
                .onTapGesture { copyInformation() }
                .help("Copy System Information to Clipboard")

            Spacer().frame(height: 40)

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    contentBuilder(dismissWindow)
                }
            }
            Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal, 56)
        .padding(.bottom, 16)
        .frame(width: 460)
        .background(
            colorScheme == .dark
            ? Color(.black).opacity(0.2)
            : Color(.white).opacity(controlActiveState == .inactive ? 1.0 : 0.5)
        )
    }

    private var dismissButton: some View {
        Button(
            action: dismissWindow,
            label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(isHoveringCloseButton ? Color(.secondaryLabelColor) : Color(.tertiaryLabelColor))
            }
        )
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Close"))
        .onHover { hover in
            withAnimation(.linear(duration: 0.15)) {
                isHoveringCloseButton = hover
            }
        }
        .padding(10)
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.25)))
    }
}
