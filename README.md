<p align="center">
  <img src="https://github.com/CodeEditApp/CodeEditWelcomeWindow/blob/main/.github/WelcomeWindow-Icon-128@2x.png?raw=true" height="128">
  <h1 align="center">CodeEditWelcomeWindow</h1>
</p>

<p align="center">
  <a aria-label="Follow CodeEdit on X" href="https://x.com/CodeEditApp" target="_blank">
    <img alt="" src="https://img.shields.io/badge/Follow%20@CodeEditApp-black.svg?style=for-the-badge&logo=X">
  </a>
  <a aria-label="Join the community on Discord" href="https://discord.gg/vChUXVf9Em" target="_blank">
    <img alt="" src="https://img.shields.io/badge/Join%20the%20community-black.svg?style=for-the-badge&logo=Discord">
  </a>
  <a aria-label="Read the Documentation" href="https://codeeditapp.github.io/CodeEditWelcomeWindow/documentation/codeeditwelcomewindow/" target="_blank">
    <img alt="" src="https://img.shields.io/badge/Documentation-black.svg?style=for-the-badge&logo=readthedocs&logoColor=blue">
  </a>
</p>

A highly customizable welcome window built for `NSDocument`-based macOS applications. Designed to provide a native and elegant onboarding experience for your app, with support for new/open document actions, drag-and-drop, and dynamic layouts.

![GitHub release](https://img.shields.io/github/v/release/CodeEditApp/CodeEditWelcomeWindow?color=orange&label=latest%20release&sort=semver&style=flat-square)
![Github Tests](https://img.shields.io/github/actions/workflow/status/CodeEditApp/CodeEditWelcomeWindow/tests.yml?branch=main&label=tests&style=flat-square)
![Documentation](https://img.shields.io/github/actions/workflow/status/CodeEditApp/CodeEditWelcomeWindow/build-documentation.yml?branch=main&label=docs&style=flat-square)
![GitHub Repo stars](https://img.shields.io/github/stars/CodeEditApp/CodeEditWelcomeWindow?style=flat-square)
![GitHub forks](https://img.shields.io/github/forks/CodeEditApp/CodeEditWelcomeWindow?style=flat-square)
[![Discord Badge](https://img.shields.io/discord/951544472238444645?color=5865F2&label=Discord&logo=discord&logoColor=white&style=flat-square)](https://discord.gg/vChUXVf9Em)

> [!IMPORTANT]
> This package is ideal for macOS apps that use `NSDocument` and want to offer a smooth first-launch experience. It is designed with SwiftUI and integrates easily with modern app lifecycles.

![image](https://github.com/user-attachments/assets/0e0dbaaa-3b2a-4132-b073-5b8971750668)

## Documentation

This package is fully documented [here](https://codeeditapp.github.io/CodeEditWelcomeWindow/documentation/codeeditwelcomewindow/).

## Usage

To use `CodeEditWelcomeWindow`, simply add it to your app.

```swift
WelcomeWindow(
    actions: { dismiss in
        (
            WelcomeActionView(
                iconName: "circle.fill",
                title: "New Text Document",
                action: {
                    handler.createNewDocumentWithDialog(
                        configuration: .init(title: "Create new text document"),
                        onCompletion: { dismiss() }
                    )
                }
            ),
            WelcomeActionView(
                iconName: "triangle.fill",
                title: "Open Text Document",
                action: {
                    handler.openDocumentWithDialog(
                        onDialogPresented: { dismiss() },
                        onCancel: { openWindow(id: "welcome") }
                    )
                }
            )
        )
    },
    onDrop: { url, dismiss in
        Task {
            handler.openDocument(at: url, onCompletion: { dismiss() })
        }
    }
)
```

## License

Licensed under the [MIT license](https://github.com/CodeEditApp/CodeEditWelcomeWindow/blob/main/LICENSE.md)
