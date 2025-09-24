//
//  ShellJumperApp.swift
//  ShellJumper
//
//  Created by 张重言 on 2025/9/24.
//

import SwiftUI

@main
struct ShellJumperApp: App {
    init() {
        // 应用初始化时直接执行逻辑
        let terminalService = TerminalService.shared
        let path = terminalService.getFrontFinderPath() ?? NSHomeDirectory()

        // 选择终端
        terminalService.openInTerminal(path: path)
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
        // 无UI应用，返回空场景
        Settings {
            EmptyView()
        }
    }
}
