import Foundation

extension Date {
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
    
    func isThisWeek() -> Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    func isInNext30Days() -> Bool {
        let calendar = Calendar.current
        guard let daysFromNow = calendar.dateComponents([.day], from: Date(), to: self).day else {
            return false
        }
        return daysFromNow >= 0 && daysFromNow <= 30
    }
    
    func formattedShort() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    func formattedRelative() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
