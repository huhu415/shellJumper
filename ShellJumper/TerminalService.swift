//
//  TerminalService.swift
//  ShellJumper
//
//  Created by 张重言 on 2025/9/24.
//

import Cocoa
import OSLog

private let logger = Logger.shellJumperMain

enum Terminal: String, CaseIterable, Identifiable {
    case terminal, iterm2, ghostty, warp, wezterm

    var id: String { rawValue }

    // 使用工厂方法，根据 enum 返回对应的实现类
    private var implementation: TerminalProtocol {
        switch self {
        case .terminal: SystemTerminal()
        case .iterm2: ITermTerminal()
        case .ghostty: GhosttyTerminal()
        case .warp: WarpTerminal()
        case .wezterm: WezTermTerminal()
        }
    }

    func open(path: String) -> Bool {
        implementation.open(path: path)
    }
}

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

// MARK: - Protocol Definition (类似 Go 的 interface)

protocol TerminalProtocol {
    func open(path: String) -> Bool
}

/// 系统自带的 Terminal.app
class SystemTerminal: TerminalProtocol {
    func open(path: String) -> Bool {
        openWithApp(named: "Terminal", path: path)
    }
}

/// Ghostty 终端
class GhosttyTerminal: TerminalProtocol {
    func open(path: String) -> Bool {
        openWithApp(named: "Ghostty", path: path)
    }
}

/// iTerm2 终端
class ITermTerminal: TerminalProtocol {
    func open(path: String) -> Bool {
        openWithApp(named: "iTerm", path: path)
    }
}

/// Warp 终端
class WarpTerminal: TerminalProtocol {
    func open(path: String) -> Bool {
        // Warp 支持 deep-link
        let encoded = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        if let url = URL(string: "warp-terminal://new?path=\(encoded)") {
            NSWorkspace.shared.open(url)
            return true
        }
        return false
    }
}

/// WezTerm 终端
class WezTermTerminal: TerminalProtocol {
    func open(path: String) -> Bool {
        openWithApp(named: "WezTerm", path: path)
    }
}

private func runAppleScript(_ source: String) -> NSAppleEventDescriptor? {
    var err: NSDictionary?
    let script = NSAppleScript(source: source)
    let result = script?.executeAndReturnError(&err)

    if let error = err {
        logger.error("AppleScript error: \(error)")
    }

    return result
}

private func openWithApp(named appName: String, path: String) -> Bool {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    task.arguments = ["-a", appName, path]
    do {
        try task.run()
        task.waitUntilExit()
        logger.debug("\(appName) open \(path) exit status: \(task.terminationStatus)")
        return task.terminationStatus == 0
    } catch {
        logger.error("Error opening \(appName) in \(path): \(error, privacy: .public)")
        return false
    }
}
