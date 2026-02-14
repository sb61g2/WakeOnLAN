import Foundation

struct WOLTarget: Identifiable, Codable {
    let id: UUID
    var name: String
    var ipAddress: String
    var subnetMask: String
    var macAddress: String
    
    init(id: UUID = UUID(), name: String, ipAddress: String, subnetMask: String, macAddress: String) {
        self.id = id
        self.name = name
        self.ipAddress = ipAddress
        self.subnetMask = subnetMask
        self.macAddress = macAddress
    }
    
    var formattedMacAddress: String {
        macAddress.replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: "-", with: "")
            .uppercased()
    }
    
    var broadcastAddress: String {
        calculateBroadcastAddress(ip: ipAddress, subnet: subnetMask)
    }
    
    private func calculateBroadcastAddress(ip: String, subnet: String) -> String {
        let ipComponents = ip.split(separator: ".").compactMap { UInt8($0) }
        let subnetComponents = subnet.split(separator: ".").compactMap { UInt8($0) }
        
        guard ipComponents.count == 4, subnetComponents.count == 4 else {
            return "255.255.255.255"
        }
        
        var broadcast = [UInt8]()
        for i in 0..<4 {
            broadcast.append(ipComponents[i] | (~subnetComponents[i]))
        }
        
        return broadcast.map { String($0) }.joined(separator: ".")
    }
}
