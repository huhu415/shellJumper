//
//  ShellJumperApp.swift
//  ShellJumper
//
//  Created by 张重言 on 2025/9/24.
//

import AppKit
import OSLog
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }
}

@main
struct ShellJumperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    let logger = Logger(subsystem: "com.huhu.ShellJumper", category: "main")
    let showVisualInterface: Bool

    init() {
        let currentModifiers = NSEvent.modifierFlags.cleaned
        logger.info("App launched with modifiers: \(currentModifiers.debugSummary, privacy: .public)")

        showVisualInterface = currentModifiers.rawValue == 1_179_648
        if showVisualInterface {
            return
        }

        let terminalService = TerminalService.shared
        let path = terminalService.getFrontFinderPath() ?? NSHomeDirectory()

        // 选择终端
        terminalService.openInTerminal(path: path)
        // terminalService.openInGhostty(path: path)
        // terminalService.openInITerm(path: path)
        // terminalService.openInWarp(path: path)
        // terminalService.openInWezTerm(path: path)

        // （可选）顺带打开 VS Code
        // terminalService.openVSCode(path: path)

        // 退出应用
        DispatchQueue.main.async {
            NSApplication.shared.terminate(nil)
        }
    }

    var body: some Scene {
        WindowGroup {
            if showVisualInterface {
                ContentView()
                    .frame(minWidth: 500, minHeight: 400)
            } else {
                EmptyView()
            }
        }
        .windowResizability(.contentSize)
        Settings {
            EmptyView()
        }
    }
}

// for debug
extension NSEvent.ModifierFlags {
    var cleaned: NSEvent.ModifierFlags {
        intersection(.deviceIndependentFlagsMask)
    }

    var humanDescription: String {
        var parts: [String] = []
        if contains(.command) { parts.append("Command") } // ⌘
        if contains(.option) { parts.append("Option") } // ⌥
        if contains(.shift) { parts.append("Shift") } // ⇧
        if contains(.control) { parts.append("Control") } // ⌃
        if contains(.function) { parts.append("Fn") }
        if contains(.capsLock) { parts.append("CapsLock") }
        return parts.isEmpty ? "None" : parts.joined(separator: " + ")
    }

    var debugSummary: String {
        let raw = rawValue
        let hex = String(raw, radix: 16, uppercase: true)
        return "\(humanDescription) [raw:\(raw) 0x\(hex)]"
    }
}
