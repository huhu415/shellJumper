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
                let path =
                    terminalService.getFrontFinderPath() ?? NSHomeDirectory()
                let ok = terminalService.openInTerminal(path: path)
                log =
                    (ok ? "✅ 已尝试在 Terminal 打开：\(path)" : "❌ 打开失败，见 Xcode 控制台日志")
            }
            .buttonStyle(.borderedProminent)

            Button("仅测试：打开 ~ (Home)") {
                let home = NSHomeDirectory()
                let ok = terminalService.openInTerminal(path: home)
                log =
                    (ok ? "✅ 已尝试在 Terminal 打开：\(home)" : "❌ 打开失败，见 Xcode 控制台日志")
            }

            Divider()

            HStack(spacing: 12) {
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

            Button("同时打开 VS Code") {
                let path =
                    terminalService.getFrontFinderPath() ?? NSHomeDirectory()
                let terminalOk = terminalService.openInTerminal(path: path)
                let codeOk = terminalService.openVSCode(path: path)
                log =
                    "Terminal: \(terminalOk ? "✅" : "❌") VS Code: \(codeOk ? "✅" : "❌") 路径：\(path)"
            }
            .buttonStyle(.bordered)

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
