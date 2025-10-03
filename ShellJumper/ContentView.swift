//
//  ContentView.swift
//  ShellJumper
//
//  Created by 张重言 on 2025/9/24.
//

import OSLog
import SwiftUI

struct ContentView: View {
    @State private var log: String = "就绪"
    private let terminalService = TerminalService.shared
    private let logger = Logger.shellJumperMain

    private func logTimings(terminalName: String, startTime: CFAbsoluteTime, midTime: CFAbsoluteTime, endTime: CFAbsoluteTime) {
        let getPathTime = (midTime - startTime) * 1000
        let openTime = (endTime - midTime) * 1000
        let totalTime = (endTime - startTime) * 1000

        logger.info("🚀 \(terminalName) 性能统计: 总耗时: \(String(format: "%.1f", totalTime))ms\n路径获取: \(String(format: "%.1f", getPathTime))ms → 终端启动: \(String(format: "%.1f", openTime))ms")
    }

    var body: some View {
        VStack(spacing: 16) {
            Button("在当前 Finder 目录打开 \(ConfigManager.shared.terminal.displayName)") {
                let path = terminalService.getFrontFinderPath() ?? NSHomeDirectory()
                let terminalSelection = ConfigManager.shared.terminal // 使用用户配置
                let ok = terminalService.open(path: path, using: terminalSelection) // 使用 .open 方法
                log = (ok ? "✅ 已尝试在 \(terminalSelection.displayName) 打开：\(path)" : "❌ 打开失败，见 Xcode 控制台日志")
            }
            .buttonStyle(.borderedProminent)

            Divider()

            HStack(spacing: 12) {
                Button("Terminal") {
                    let startTime = CFAbsoluteTimeGetCurrent()
                    let path = terminalService.getFrontFinderPath() ?? NSHomeDirectory()
                    let midTime = CFAbsoluteTimeGetCurrent()
                    let ok = terminalService.openInTerminal(path: path)
                    let endTime = CFAbsoluteTimeGetCurrent()

                    log = (ok ? "✅ 已尝试在 Terminal 打开：\(path)" : "❌ 打开失败，请确保已安装 Terminal")

                    logTimings(terminalName: "Terminal", startTime: startTime, midTime: midTime, endTime: endTime)
                }
                .buttonStyle(.bordered)

                Button("Ghostty") {
                    let startTime = CFAbsoluteTimeGetCurrent()
                    let path = terminalService.getFrontFinderPath() ?? NSHomeDirectory()
                    let midTime = CFAbsoluteTimeGetCurrent()
                    let ok = terminalService.openInGhostty(path: path)
                    let endTime = CFAbsoluteTimeGetCurrent()

                    log = (ok ? "✅ 已尝试在 Ghostty 打开：\(path)" : "❌ 打开失败，请确保已安装 Ghostty")

                    logTimings(terminalName: "Ghostty", startTime: startTime, midTime: midTime, endTime: endTime)
                }
                .buttonStyle(.bordered)

                Button("iTerm2") {
                    let startTime = CFAbsoluteTimeGetCurrent()
                    let path = terminalService.getFrontFinderPath() ?? NSHomeDirectory()
                    let midTime = CFAbsoluteTimeGetCurrent()
                    let ok = terminalService.openInITerm(path: path)
                    let endTime = CFAbsoluteTimeGetCurrent()

                    log = (ok ? "✅ 已尝试在 iTerm2 打开：\(path)": "❌ 打开失败，请确保已安装 iTerm2")

                    logTimings(terminalName: "iTerm2", startTime: startTime, midTime: midTime, endTime: endTime)
                }
                .buttonStyle(.bordered)

                Button("Warp") {
                    let startTime = CFAbsoluteTimeGetCurrent()
                    let path = terminalService.getFrontFinderPath() ?? NSHomeDirectory()
                    let midTime = CFAbsoluteTimeGetCurrent()
                    let ok = terminalService.openInWarp(path: path)
                    let endTime = CFAbsoluteTimeGetCurrent()

                    log = (ok ? "✅ 已尝试在 Warp 打开：\(path)" : "❌ 打开失败，请确保已安装 Warp")

                    logTimings(terminalName: "Warp", startTime: startTime, midTime: midTime, endTime: endTime)
                }
                .buttonStyle(.bordered)

                Button("WezTerm") {
                    let startTime = CFAbsoluteTimeGetCurrent()
                    let path = terminalService.getFrontFinderPath() ?? NSHomeDirectory()
                    let midTime = CFAbsoluteTimeGetCurrent()
                    let ok = terminalService.openInWezTerm(path: path)
                    let endTime = CFAbsoluteTimeGetCurrent()

                    log = (ok ? "✅ 已尝试在 WezTerm 打开：\(path)": "❌ 打开失败，请确保已安装 WezTerm")

                    logTimings(terminalName: "WezTerm", startTime: startTime, midTime: midTime, endTime: endTime)
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
