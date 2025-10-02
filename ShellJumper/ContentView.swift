//
//  ContentView.swift
//  ShellJumper
//
//  Created by 张重言 on 2025/9/24.
//

import SwiftUI

struct ContentView: View {
    @State private var log: String = "就绪"
    private let terminalService = TerminalService.shared

    var body: some View {
        VStack(spacing: 16) {
            Button("在当前 Finder 目录打开 Terminal") {
                let path = terminalService.getFrontFinderPath() ?? NSHomeDirectory()
                let terminalSelection = ConfigManager.shared.terminal // 使用用户配置
                let ok = terminalService.open(path: path, using: terminalSelection) // 使用 .open 方法
                log = (ok ? "✅ 已尝试在 \(terminalSelection.displayName) 打开：\(path)" : "❌ 打开失败，见 Xcode 控制台日志")
            }
            .buttonStyle(.borderedProminent)

            Divider()

            HStack(spacing: 12) {
                Button("Ghostty") {
                    let path =
                        terminalService.getFrontFinderPath()
                            ?? NSHomeDirectory()
                    let ok = terminalService.openInGhostty(path: path)
                    log = (ok ? "✅ 已尝试在 Ghostty 打开：\(path)" : "❌ 打开失败，请确保已安装 Ghostty")
                }
                .buttonStyle(.bordered)

                Button("iTerm2") {
                    let path =
                        terminalService.getFrontFinderPath()
                            ?? NSHomeDirectory()
                    let ok = terminalService.openInITerm(path: path)
                    log =
                        (ok
                            ? "✅ 已尝试在 iTerm2 打开：\(path)"
                            : "❌ 打开失败，请确保已安装 iTerm2")
                }
                .buttonStyle(.bordered)

                Button("Warp") {
                    let path =
                        terminalService.getFrontFinderPath()
                            ?? NSHomeDirectory()
                    let ok = terminalService.openInWarp(path: path)
                    log = (ok ? "✅ 已尝试在 Warp 打开：\(path)" : "❌ 打开失败，请确保已安装 Warp")
                }
                .buttonStyle(.bordered)

                Button("WezTerm") {
                    let path =
                        terminalService.getFrontFinderPath()
                            ?? NSHomeDirectory()
                    let ok = terminalService.openInWezTerm(path: path)
                    log =
                        (ok
                            ? "✅ 已尝试在 WezTerm 打开：\(path)"
                            : "❌ 打开失败，请确保已安装 WezTerm")
                }
                .buttonStyle(.bordered)
            }

            Text(log)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding(24)
        .frame(minWidth: 500)
    }
}

#Preview {
    ContentView()
}
