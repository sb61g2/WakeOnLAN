import SwiftUI

struct TargetEditorView: View {
    enum Mode {
        case add
        case edit(WOLTarget)
    }
    
    let mode: Mode
    let onSave: (WOLTarget) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var ipAddress: String = ""
    @State private var subnetMask: String = "255.255.255.0"
    @State private var macAddress: String = ""
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, ip, subnet, mac
    }
    
    init(mode: Mode, onSave: @escaping (WOLTarget) -> Void) {
        self.mode = mode
        self.onSave = onSave
        
        if case .edit(let target) = mode {
            _name = State(initialValue: target.name)
            _ipAddress = State(initialValue: target.ipAddress)
            _subnetMask = State(initialValue: target.subnetMask)
            _macAddress = State(initialValue: target.macAddress)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(mode.title)
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .keyboardShortcut(.cancelAction)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(nsColor: .controlBackgroundColor))
            
            // Form Content
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    // Name Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Device Name")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        TextField("e.g., Living Room PC", text: $name)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(6)
                            .focused($focusedField, equals: .name)
                    }
                    
                    // IP Address Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("IP Address")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        TextField("192.168.1.100", text: $ipAddress)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(6)
                            .focused($focusedField, equals: .ip)
                    }
                    
                    // Subnet Mask Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Subnet Mask")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        TextField("255.255.255.0", text: $subnetMask)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(6)
                            .focused($focusedField, equals: .subnet)
                    }
                    
                    // MAC Address Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("MAC Address")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        TextField("AA:BB:CC:DD:EE:FF", text: $macAddress)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(6)
                            .focused($focusedField, equals: .mac)
                    }
                }
                .padding(16)
            }
            
            Divider()
            
            // Footer with Save Button
            HStack {
                Spacer()
                Button(action: saveTarget) {
                    Text("Save")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 70, height: 28)
                        .background(isValid ? Color.accentColor : Color.gray)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .frame(width: 360, height: 400)
        .onAppear {
            focusedField = .name
        }
        .alert("Invalid Input", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty && !ipAddress.isEmpty && !subnetMask.isEmpty && !macAddress.isEmpty
    }
    
    private func saveTarget() {
        // Validate inputs
        guard validateIP(ipAddress) else {
            errorMessage = "Invalid IP address format"
            showingError = true
            return
        }
        
        guard validateIP(subnetMask) else {
            errorMessage = "Invalid subnet mask format"
            showingError = true
            return
        }
        
        guard validateMAC(macAddress) else {
            errorMessage = "Invalid MAC address format. Use format: AA:BB:CC:DD:EE:FF"
            showingError = true
            return
        }
        
        let target: WOLTarget
        if case .edit(let existing) = mode {
            target = WOLTarget(
                id: existing.id,
                name: name.trimmingCharacters(in: .whitespaces),
                ipAddress: ipAddress.trimmingCharacters(in: .whitespaces),
                subnetMask: subnetMask.trimmingCharacters(in: .whitespaces),
                macAddress: macAddress.trimmingCharacters(in: .whitespaces)
            )
        } else {
            target = WOLTarget(
                name: name.trimmingCharacters(in: .whitespaces),
                ipAddress: ipAddress.trimmingCharacters(in: .whitespaces),
                subnetMask: subnetMask.trimmingCharacters(in: .whitespaces),
                macAddress: macAddress.trimmingCharacters(in: .whitespaces)
            )
        }
        
        onSave(target)
        dismiss()
    }
    
    private func validateIP(_ ip: String) -> Bool {
        let parts = ip.split(separator: ".")
        guard parts.count == 4 else { return false }
        
        for part in parts {
            guard let num = Int(part), num >= 0, num <= 255 else {
                return false
            }
        }
        return true
    }
    
    private func validateMAC(_ mac: String) -> Bool {
        let cleaned = mac.replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: "-", with: "")
        
        guard cleaned.count == 12 else { return false }
        
        let hexCharacters = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
        return cleaned.unicodeScalars.allSatisfy { hexCharacters.contains($0) }
    }
}

extension TargetEditorView.Mode {
    var title: String {
        switch self {
        case .add: return "Add Target"
        case .edit: return "Edit Target"
        }
    }
}
