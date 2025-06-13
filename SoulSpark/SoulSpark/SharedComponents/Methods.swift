import Foundation
import UIKit

class SharedMethods {
    
    static var shared = SharedMethods()
    
    /// Custom logger function
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file where the log is called (default: #file).
    ///   - function: The function where the log is called (default: #function).
    ///   - line: The line number where the log is called (default: #line).
    func debugLog(_ message: String,
                  file: String = #file,
                  function: String = #function,
                  line: Int = #line) {
#if DEBUG
        if let status = VaultInfo.shared.getKeyValue(by: "isConsoleLogsEnable").1 as? Bool,
           status == true {
            let fileName = (file as NSString).lastPathComponent
            print("[\(fileName):\(line)] \(function) - \(message)")
        }
#endif
    }
    
    /// A generic method to retry network requests on failure
    func performWithRetry<T>(maxRetries: Int = 3,
                             delayBase: Double = 2.0, // Base for exponential backoff (2s, 4s, 8s)
                             task: @escaping () async throws -> T) async throws -> T {
        var attempts = 0
        while attempts < maxRetries {
            do {
                return try await task() // ✅ Try the request
            } catch let error as NSError {
                if [NSURLErrorTimedOut,
                    NSURLErrorNetworkConnectionLost,
                    NSURLErrorNotConnectedToInternet].contains(error.code) {
                    attempts += 1
                    let delay = pow(delayBase, Double(attempts)) // 2s, 4s, 8s
                    debugLog("Network error (\(error.code)). Retrying in \(delay) seconds... (Attempt \(attempts) of \(maxRetries))")
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000)) // Convert to nanoseconds
                } else {
                    debugLog("❌ Non-retryable error: \(error.localizedDescription)")
                    throw error // Exit if it's not a network error
                }
            }
        }
        
        debugLog("🚨 Max retries reached. Request failed.")
        throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotConnectToHost, userInfo: [NSLocalizedDescriptionKey: "Max retries reached"])
    }
}
