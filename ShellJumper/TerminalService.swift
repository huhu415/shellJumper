//
//  TerminalService.swift
//  ShellJumper
//
//  Created by 张重言 on 2025/9/24.
//

import Cocoa

class TerminalService {
    static let shared = TerminalService()

    private init() {}

    // MARK: - Finder 前台路径获取

    func getFrontFinderPath() -> String? {
        // 1) 前台窗口
        let s1 = """
        tell application "Finder"
            if (count of windows) > 0 then
                return POSIX path of (target of front window as alias)
            else
                return ""
            end if
        end tell
        """
        if let r1 = runAppleScript(s1), let p = r1.stringValue, !p.isEmpty {
            return p
        }

        // 2) 选中项（无窗口时）
        let s2 = """
        tell application "Finder"
            set sel to selection
            if sel is {} then return POSIX path of (desktop as alias)
            set firstItem to item 1 of sel
            if (class of firstItem is folder) then
                return POSIX path of (firstItem as alias)
            else
                return POSIX path of (container of firstItem as alias)
            end if
        end tell
        """
        return runAppleScript(s2)?.stringValue
    }

    // MARK: - 打开不同终端

    @discardableResult
    func openInTerminal(path: String) -> Bool {
        let scpt = """
        tell application "Terminal"
            activate
            do script "cd \\\"\(path)\\\""
        end tell
        """
        return runAppleScript(scpt) != nil
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
            print("Error opening WezTerm: \(error)")
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
            print("Error opening VS Code: \(error)")
            return false
        }
    }

    // MARK: - AppleScript 执行

    private func runAppleScript(_ source: String) -> NSAppleEventDescriptor? {
        var err: NSDictionary?
        let script = NSAppleScript(source: source)
        let result = script?.executeAndReturnError(&err)

        if let error = err {
            print("AppleScript error: \(error)")
        }

        return result
    }
}
