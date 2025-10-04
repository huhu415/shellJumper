//
//  ContentView.swift
//  ShellJumper
//
//  Created by 张重言 on 2025/9/24.
//

import OSLog
import SwiftUI

struct ContentView: View {
    @State private var log = "就绪"
    private let logger = Logger.shellJumperMain

    private func openTerminal(_ terminal: Terminal) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let path = getFrontFinderPath() ?? NSHomeDirectory()
        let midTime = CFAbsoluteTimeGetCurrent()
        let ok = terminal.open(path: path)
        let endTime = CFAbsoluteTimeGetCurrent()

        log = ok ? "✅ 已尝试在 \(terminal.rawValue) 打开：\(path)" : "❌ 打开失败，请确保已安装 \(terminal.rawValue)"

        let totalTime = (endTime - startTime) * 1000
        let getPathTime = (midTime - startTime) * 1000
        let openTime = (endTime - midTime) * 1000
        logger.info("🚀 \(terminal.rawValue, privacy: .public) 性能统计: 总耗时: \(String(format: "%.1f", totalTime), privacy: .public)ms\n路径获取: \(String(format: "%.1f", getPathTime), privacy: .public)ms → 终端启动: \(String(format: "%.1f", openTime), privacy: .public)ms")
    }

    var body: some View {
        VStack(spacing: 16) {
            Button("在当前 Finder 目录打开 \(ConfigManager.shared.terminal.rawValue)") {
                openTerminal(ConfigManager.shared.terminal)
            }
            .buttonStyle(.borderedProminent)

            Divider()

            HStack(spacing: 12) {
                ForEach(Terminal.allCases) { terminal in
                    Button(terminal.rawValue) {
                        openTerminal(terminal)
                    }
                    .buttonStyle(.bordered)
                }
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
