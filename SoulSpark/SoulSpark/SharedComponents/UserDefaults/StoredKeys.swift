import Foundation

struct StoredKeys<Value> {
    
    let name: String
    
    init(_ name: Keyname) {
        self.name = name.rawValue
    }
    
    static var userDetails: StoredKeys<Bool> {
        return StoredKeys<Bool>(Keyname.userDetails)
    }
}
