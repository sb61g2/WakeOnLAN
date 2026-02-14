import Foundation
import Network

class WOLSender {
    enum WOLError: Error {
        case invalidMacAddress
        case socketError
        case sendError
        
        var localizedDescription: String {
            switch self {
            case .invalidMacAddress:
                return "Invalid MAC address format"
            case .socketError:
                return "Failed to create socket"
            case .sendError:
                return "Failed to send magic packet"
            }
        }
    }
    
    static func sendMagicPacket(to target: WOLTarget, completion: @escaping (Result<Void, WOLError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let macBytes = try parseMacAddress(target.formattedMacAddress)
                let magicPacket = createMagicPacket(macBytes: macBytes)
                
                try sendUDPPacket(magicPacket, to: target.broadcastAddress)
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch let error as WOLError {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.sendError))
                }
            }
        }
    }
    
    private static func parseMacAddress(_ mac: String) throws -> [UInt8] {
        let cleanMac = mac.replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: "-", with: "")
            .uppercased()
        
        guard cleanMac.count == 12 else {
            throw WOLError.invalidMacAddress
        }
        
        var bytes = [UInt8]()
        var index = cleanMac.startIndex
        
        for _ in 0..<6 {
            let nextIndex = cleanMac.index(index, offsetBy: 2)
            let byteString = cleanMac[index..<nextIndex]
            guard let byte = UInt8(byteString, radix: 16) else {
                throw WOLError.invalidMacAddress
            }
            bytes.append(byte)
            index = nextIndex
        }
        
        return bytes
    }
    
    private static func createMagicPacket(macBytes: [UInt8]) -> Data {
        var packet = Data()
        
        // 6 bytes of 0xFF
        packet.append(contentsOf: [UInt8](repeating: 0xFF, count: 6))
        
        // MAC address repeated 16 times
        for _ in 0..<16 {
            packet.append(contentsOf: macBytes)
        }
        
        return packet
    }
    
    private static func sendUDPPacket(_ packet: Data, to broadcastAddress: String) throws {
        let socket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
        guard socket >= 0 else {
            throw WOLError.socketError
        }
        
        defer {
            close(socket)
        }
        
        // Enable broadcast
        var broadcast = 1
        guard setsockopt(socket, SOL_SOCKET, SO_BROADCAST, &broadcast, socklen_t(MemoryLayout<Int>.size)) >= 0 else {
            throw WOLError.socketError
        }
        
        // Setup destination address
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = in_port_t(9).bigEndian // WOL typically uses port 7 or 9
        addr.sin_addr.s_addr = inet_addr(broadcastAddress)
        
        // Send packet
        let sent = packet.withUnsafeBytes { bufferPointer in
            withUnsafePointer(to: &addr) { addrPointer in
                addrPointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPointer in
                    sendto(socket, bufferPointer.baseAddress, packet.count, 0, sockaddrPointer, socklen_t(MemoryLayout<sockaddr_in>.size))
                }
            }
        }
        
        guard sent >= 0 else {
            throw WOLError.sendError
        }
    }
}
