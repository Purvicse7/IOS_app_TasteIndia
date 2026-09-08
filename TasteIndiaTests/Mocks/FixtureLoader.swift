import Foundation

extension Bundle {
    static func testFixtureURL(named name: String) -> URL? {
        if let url = Bundle.module.url(forResource: name, withExtension: "json") {
            return url
        }
        if let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures") {
            return url
        }
        let thisFile = URL(fileURLWithPath: #filePath)
        let localFallback = thisFile.deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Fixtures/\(name).json")
        if FileManager.default.fileExists(atPath: localFallback.path) {
            return localFallback
        }
        return nil
    }
}
