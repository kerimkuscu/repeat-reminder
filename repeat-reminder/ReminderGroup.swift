import Foundation

struct ReminderGroup: Identifiable, Codable {
    let id: UUID
    var name: String
    var reminders: [Reminder]
    
    init(id: UUID = UUID(), name: String, reminders: [Reminder] = []) {
        self.id = id
        self.name = name
        self.reminders = reminders
        
        
    }
} 
