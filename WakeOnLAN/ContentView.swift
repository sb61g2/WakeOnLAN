import SwiftUI

private enum ActiveSheet: Identifiable {
    case add
    case edit(WOLTarget)
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let t): return t.id.uuidString
        }
    }
}

struct MenuBarContentView: View {
    @EnvironmentObject var targetManager: TargetManager
    @Environment(\.closePopover) private var closePopover
    @State private var activeSheet: ActiveSheet?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Text("Wake on LAN")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                
                Button(action: { activeSheet = .add }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .help("Add device")
                
                Button(action: { closePopover() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Close")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Target List
            if targetManager.targets.isEmpty {
                // Empty State
                VStack(spacing: 12) {
                    Image(systemName: "network")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    VStack(spacing: 4) {
                        Text("No Devices")
                            .font(.system(size: 14, weight: .medium))
                        Text("Add a device to get started")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Target List
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(targetManager.targets) { target in
                            CompactTargetRow(
                                target: target,
                                onWake: { sendWakePacket(to: target) },
                                onEdit: {
                                    activeSheet = .edit(target)
                                },
                                onDelete: { targetManager.deleteTarget(target) }
                            )
                            
                            if target.id != targetManager.targets.last?.id {
                                Divider()
                                    .padding(.leading, 40)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(width: 320, height: 400)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .add:
                TargetEditorView(mode: .add) { target in
                    targetManager.addTarget(target)
                }
                .environmentObject(targetManager)
            case .edit(let target):
                TargetEditorView(mode: .edit(target)) { updatedTarget in
                    targetManager.updateTarget(updatedTarget)
                }
                .environmentObject(targetManager)
            }
        }
    }
    
    private func sendWakePacket(to target: WOLTarget) {
        WOLSender.sendMagicPacket(to: target) { _ in
            // Silent - no confirmation dialog
        }
    }
}

struct CompactTargetRow: View {
    let target: WOLTarget
    let onWake: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 28, height: 28)
                
                Image(systemName: "desktopcomputer")
                    .font(.system(size: 13))
                    .foregroundColor(.accentColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(target.name)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                
                HStack(spacing: 3) {
                    Text(target.ipAddress)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer(minLength: 8)
            
            // Actions - Always visible
            HStack(spacing: 6) {
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Edit")
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red.opacity(0.7))
                }
                .buttonStyle(.plain)
                .help("Delete")
                
                Button(action: onWake) {
                    Text("Wake")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 24)
                        .background(Color.accentColor)
                        .cornerRadius(5)
                }
                .buttonStyle(.plain)
                .help("Send magic packet")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

// Environment key for closing popover
struct ClosePopoverKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var closePopover: () -> Void {
        get { self[ClosePopoverKey.self] }
        set { self[ClosePopoverKey.self] = newValue }
    }
}
