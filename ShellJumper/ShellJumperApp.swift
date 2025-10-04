//
//  ShellJumperApp.swift
//  ShellJumper
//
//  Created by 张重言 on 2025/9/24.
//

import AppKit
import Combine
import OSLog
import SwiftUI

extension Logger {
    static let shellJumperMain = Logger(subsystem: "com.huhu.ShellJumper", category: "main")
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }
}

@main
struct ShellJumperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let logger = Logger.shellJumperMain
    let showVisualInterface: Bool

    init() {
        let currentModifiers = NSEvent.modifierFlags.cleaned
        logger.info("App launched with modifiers: \(currentModifiers.debugSummary, privacy: .public)")

        showVisualInterface = currentModifiers.rawValue == 1_179_648
        if showVisualInterface {
            return
        }

        let terminalSelection = ConfigManager.shared.terminal
        let path = getFrontFinderPath() ?? NSHomeDirectory()
        let ok = terminalSelection.open(path: path)
        if !ok {
            logger.error("Failed to open \(terminalSelection.rawValue, privacy: .public); no fallback applied")
        } else {
            logger.info("Opening \(terminalSelection.rawValue, privacy: .public) in \(path, privacy: .public)")
        }

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
            SettingsView()
        }
    }
}

struct SettingsView: View {
    @ObservedObject private var configManager = ConfigManager.shared

    var body: some View {
        Form {
            Picker("默认终端", selection: $configManager.terminal) {
                ForEach(Terminal.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.radioGroup)
        }
        .padding(20)
        .frame(width: 320)
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
