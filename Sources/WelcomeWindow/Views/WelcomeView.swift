//
//  WelcomeView.swift
//  CodeEditModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI
import AppKit
import Foundation

public struct WelcomeView: View {

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.controlActiveState)
    private var controlActiveState

    @State private var isHoveringCloseButton = false
    @FocusState.Binding var focusedField: FocusTarget?

    private let dismissWindow: () -> Void
    private let actions: WelcomeActions

    public init(
        actions: WelcomeActions,
        dismissWindow: @escaping () -> Void,
        focusedField: FocusState<FocusTarget?>.Binding
    ) {
        self.actions = actions
        self.dismissWindow = dismissWindow
        self._focusedField = focusedField
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

            Text(String(
                format: NSLocalizedString("Version %@%@ (%@)", comment: ""),
                appVersion, appVersionPostfix, appBuild
            ))
                .textSelection(.enabled)
                .foregroundColor(.secondary)
                .font(.system(size: 13.5))
                .onHover { $0 ? NSCursor.pointingHand.push() : NSCursor.pop() }
                .onTapGesture { copyInformation() }
                .help("Copy System Information to Clipboard")

            Spacer().frame(height: 40)

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    switch actions {
                    case .none:
                        EmptyView()
                    case .one(let view1):
                        Spacer()
                        view1
                            .focused($focusedField, equals: .action1)
                            .contentShape(Rectangle())
                        Spacer()
                    case let .two(view1, view2):
                        Spacer()
                        view1
                            .focused($focusedField, equals: .action1)
                            .contentShape(Rectangle())
                        view2
                            .focused($focusedField, equals: .action2)
                            .contentShape(Rectangle())
                        Spacer()
                    case let .three(view1, view2, view3):
                        view1
                            .focused($focusedField, equals: .action1)
                            .contentShape(Rectangle())
                        view2
                            .focused($focusedField, equals: .action2)
                            .contentShape(Rectangle())
                        view3
                            .focused($focusedField, equals: .action3)
                            .contentShape(Rectangle())
                    }

                }
            }

            Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal, 56)
        .padding(.bottom, 16)
        .frame(width: 460)
        .frame(maxHeight: .infinity)
        .background {
            if colorScheme == .dark {
                Color(.black).opacity(0.275)
                    .background(.ultraThickMaterial)
            } else {
                Color(.white)
                    .background(.regularMaterial)
            }
        }
    }

    private var dismissButton: some View {
        Button(action: dismissWindow) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(isHoveringCloseButton ? Color(.secondaryLabelColor) : Color(.tertiaryLabelColor))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Close"))
        .focused($focusedField, equals: .dismissButton)
        .modifier(FocusRingModifier(isFocused: focusedField == .dismissButton, shape: .circle))
        .onHover { hover in
            withAnimation(.linear(duration: 0.15)) {
                isHoveringCloseButton = hover
            }
        }
        .padding(10)
        .transition(.opacity.animation(.easeInOut(duration: 0.25)))
    }
}
