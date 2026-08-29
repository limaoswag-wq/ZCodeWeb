import Foundation
import Combine

final class AppSettings: ObservableObject {
    @Published var officialURL: String {
        didSet { UserDefaults.standard.set(officialURL, forKey: "officialURL") }
    }

    init() {
        officialURL = UserDefaults.standard.string(forKey: "officialURL") ?? ""
    }
}
