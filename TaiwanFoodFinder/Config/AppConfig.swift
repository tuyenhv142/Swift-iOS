import Foundation

enum AppConfig {
    static var apiKey: String {
        // 1. Try Secrets.plist (gitignored)
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["API_KEY"] as? String, !key.isEmpty {
            return key
        }
        // 2. Fallback to Info.plist (can be overridden via xcconfig at build time)
        if let key = Bundle.main.infoDictionary?["API_KEY"] as? String, !key.isEmpty {
            return key
        }
        fatalError("Missing API_KEY. Add Secrets.plist or set API_KEY in build settings.")
    }
}
