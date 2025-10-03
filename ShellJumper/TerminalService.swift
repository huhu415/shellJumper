//
//  TerminalService.swift
//  ShellJumper
//
//  Created by 张重言 on 2025/9/24.
//

import Cocoa
import OSLog

class TerminalService {
    static let shared = TerminalService()
    private let logger = Logger.shellJumperMain

    private init() {}

    // MARK: - Finder 前台路径获取

    func getFrontFinderPath() -> String? {
        // 1) 前台窗口
        let scpt = """
        tell application "Finder"
            if (count of windows) > 0 then
                return POSIX path of (target of front window as alias)
            end if
        end tell
        """
        let result = runAppleScript(scpt)?.stringValue
        return result?.isEmpty == true ? nil : result // nil || "" return nil
    }

    // MARK: - 打开不同终端

    @discardableResult
    func openInTerminal(path: String) -> Bool {
        let scpt = """
        tell application "Terminal"
            do script "cd \\\"\(path)\\\""
            activate
        end tell
        """
        return runAppleScript(scpt) != nil
    }

    @discardableResult
    func openInGhostty(path: String) -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-lc", "open -a 'Ghostty' \(path)"]
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            logger.error("Error opening Ghostty: \(error)")
            return false
        }
    }

    @discardableResult
    func openInITerm(path: String) -> Bool {
        let scpt = """
        tell application "iTerm2"
            activate
            if (count of windows) = 0 then
                create window with default profile
            end if
            tell current window
                create tab with default profile
                tell current session to write text "cd \\\"\(path)\\\""
            end tell
        end tell
        """
        return runAppleScript(scpt) != nil
    }

    @discardableResult
    func openInWezTerm(path: String) -> Bool {
        // WezTerm 支持 open -a 打开到该目录
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["-a", "WezTerm", path]
        do {
            try task.run()
            return true
        } catch {
            logger.error("Error opening WezTerm: \(error)")
            return false
        }
    }

    @discardableResult
    func openInWarp(path: String) -> Bool {
        // Warp 支持 deep-link
        let encoded =
            path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
                ?? path
        if let url = URL(string: "warp-terminal://new?path=\(encoded)") {
            NSWorkspace.shared.open(url)
            return true
        }
        return false
    }

    @discardableResult
    func open(path: String, using selection: Terminal) -> Bool {
        switch selection {
        case .terminal:
            openInTerminal(path: path)
        case .iterm2:
            openInITerm(path: path)
        case .ghostty:
            openInGhostty(path: path)
        case .warp:
            openInWarp(path: path)
        case .wezterm:
            openInWezTerm(path: path)
        }
    }

    // （可选）VS Code
    @discardableResult
    func openVSCode(path: String) -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        task.arguments = [
            "bash", "-lc",
            "cd \"\(path)\" && command -v code >/dev/null && code . || open -a 'Visual Studio Code' \"\(path)\"",
        ]
        do {
            try task.run()
            return true
        } catch {
            logger.error("Error opening VS Code: \(error)")
            return false
        }
    }

    // MARK: - AppleScript 执行

    private func runAppleScript(_ source: String) -> NSAppleEventDescriptor? {
        var err: NSDictionary?
        let script = NSAppleScript(source: source)
        let result = script?.executeAndReturnError(&err)

        if let error = err {
            logger.error("AppleScript error: \(error)")
        }

        return result
    }
}
