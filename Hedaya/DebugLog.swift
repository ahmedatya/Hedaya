// MARK: - Debug logger — writes to file for inspection (DEBUG only)
// Log file: Documents/hedaya_debug.log (in app sandbox)
// To copy to project after running: ./copy-debug-log.sh
// In release builds, log() and logFilePath are no-ops to avoid disk I/O and console output.

import Foundation

enum DebugLog {
#if DEBUG
    private static let queue = DispatchQueue(label: "com.hedaya.debuglog")
    private static var fileURL: URL?
    private static var hasLoggedPath = false

    static func log(_ category: String, _ message: String) {
        let line = "\(ISO8601DateFormatter().string(from: Date())) [\(category)] \(message)\n"
        queue.async {
            let url = urlForLogFile()
            if !hasLoggedPath {
                hasLoggedPath = true
                print("HEDAYA DEBUG LOG: \(url.path)")
                print("Run ./copy-debug-log.sh to copy to project root")
            }
            if let data = line.data(using: .utf8) {
                if FileManager.default.fileExists(atPath: url.path) {
                    if let handle = try? FileHandle(forWritingTo: url) {
                        handle.seekToEndOfFile()
                        handle.write(data)
                        try? handle.close()
                    }
                } else {
                    try? data.write(to: url)
                }
            }
            print(message)
        }
    }

    private static func urlForLogFile() -> URL {
        if let url = fileURL { return url }
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = dir.appendingPathComponent("hedaya_debug.log")
        fileURL = url
        return url
    }

    /// Path to log file (for display)
    static var logFilePath: String {
        urlForLogFile().path
    }
#else
    static func log(_ category: String, _ message: String) {
        // No-op in release: avoid disk I/O, console output, and log file growth
    }

    static var logFilePath: String { "" }
#endif
}
