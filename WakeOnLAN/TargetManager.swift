import Foundation
import Combine

class TargetManager: ObservableObject {
    @Published var targets: [WOLTarget] = []
    
    private let saveKey = "WOLTargets"
    
    init() {
        loadTargets()
    }
    
    func addTarget(_ target: WOLTarget) {
        targets.append(target)
        saveTargets()
    }
    
    func updateTarget(_ target: WOLTarget) {
        if let index = targets.firstIndex(where: { $0.id == target.id }) {
            targets[index] = target
            saveTargets()
        }
    }
    
    func deleteTarget(_ target: WOLTarget) {
        targets.removeAll { $0.id == target.id }
        saveTargets()
    }
    
    private func saveTargets() {
        if let encoded = try? JSONEncoder().encode(targets) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadTargets() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([WOLTarget].self, from: data) {
            targets = decoded
        }
    }
}
