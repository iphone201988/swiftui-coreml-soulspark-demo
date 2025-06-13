import UIKit

class DateUtil {
    
    static let shared = DateUtil()
    
    // 📆 Date formatter for displaying entry timestamps nicely
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}
