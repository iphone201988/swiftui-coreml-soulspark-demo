import Foundation

// Singleton class to access values from AppVault.plist
final class VaultInfo {
    
    // Shared static instance (Singleton)
    static var shared = VaultInfo()
    
    /// Fetches a value by key from AppVault.plist
    /// - Parameter key: The key to look up in the plist
    /// - Returns: A tuple containing the full dictionary and the requested value
    func getKeyValue(by key: String) -> (NSDictionary?, Any?) {
        // Tries to find the path for AppVault.plist in the main bundle
        guard let path = Bundle.main.path(forResource: "AppVault", ofType: "plist")
        else { return (nil, nil) }
        
        // Loads the plist into an NSDictionary
        let dict = NSDictionary(contentsOfFile: path)
        
        // Safely attempts to extract the value for the given key
        let keyValue = dict?[key] as? Any
        
        return (dict, keyValue)
    }
}
