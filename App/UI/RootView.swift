import SwiftUI
import UIKit

struct RootView: View {
    @ObservedObject var settings: AppSettings
    @State private var showScanner = false
    @State private var showSettings = false
    @State private var reloadToken = 0

    private var activeLink: OfficialLink? {
        OfficialLinkParser.parse(settings.officialURL)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            if activeLink != nil, let url = URL(string: settings.officialURL) {
                RemoteWebView(url: url, reloadToken: $reloadToken)
                gear
            } else {
                ConnectView(settings: settings, onScan: { showScanner = true })
            }
        }
        .sheet(isPresented: $showScanner) {
            QRScannerHost(
                onScan: { value in
                    showScanner = false
                    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    if OfficialLinkParser.parse(trimmed) != nil {
                        settings.officialURL = trimmed
                    }
                },
                onCancel: { showScanner = false }
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(settings: settings, onReload: { reloadToken += 1 })
        }
    }

    /// 官方页面右上角旁的小齿轮，不遮官方控件。
    private var gear: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 30, height: 30)
                        .background(.thinMaterial, in: Circle())
                }
                .padding(.trailing, 66)
                .padding(.top, 2)
            }
            Spacer()
        }
    }
}

struct ConnectView: View {
    @ObservedObject var settings: AppSettings
    var onScan: () -> Void
    @State private var paste = ""
    @State private var errorText: String?

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)
            Text("Z")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 76, height: 76)
                .background(Color(.label), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            Text("ZCode 远程控制")
                .font(.system(size: 21, weight: .bold))
                .padding(.top, 20)
            Text("扫描电脑端「移动端远程控制」二维码，或粘贴复制的链接。登录状态会保存在本机。")
                .font(.system(size: 13.5))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 34)
            Spacer(minLength: 10)

            VStack(spacing: 12) {
                Button(action: onScan) {
                    Label("扫描二维码连接", systemImage: "qrcode.viewfinder")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                HStack(spacing: 10) {
                    TextField("https://zcode.z.ai/remote/v4?sid=…", text: $paste)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(.system(size: 13, design: .monospaced))
                    Button("连接") {
                        let trimmed = paste.trimmingCharacters(in: .whitespacesAndNewlines)
                        if OfficialLinkParser.parse(trimmed) != nil {
                            errorText = nil
                            settings.officialURL = trimmed
                        } else {
                            errorText = "这不是 ZCode 远控链接，请检查后重试。"
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                if let errorText, !errorText.isEmpty {
                    Text(errorText)
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 16)
            Text("网页会话由电脑端执行；通知请使用电脑端 Bark。")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 18)
        }
        .onAppear { paste = settings.officialURL }
    }
}

struct SettingsSheet: View {
    @ObservedObject var settings: AppSettings
    var onReload: () -> Void
    @Environment(\.dismiss) private var dismiss

    private var link: OfficialLink? { OfficialLinkParser.parse(settings.officialURL) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("设备", value: link?.deviceName ?? "未知")
                    Button {
                        onReload()
                        dismiss()
                    } label: {
                        Label("刷新网页", systemImage: "arrow.clockwise")
                    }
                    Button(role: .destructive) {
                        settings.officialURL = ""
                        dismiss()
                    } label: {
                        Label("清除链接，重新扫码", systemImage: "link.badge.plus")
                    }
                } header: {
                    Text("连接")
                } footer: {
                    Text("登录信息保存在本机（cookie），重复打开不用重新登录。链接过期时清除后重新扫码。")
                }
                Section {
                    LabeledContent("版本", value: "1.0.0")
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
