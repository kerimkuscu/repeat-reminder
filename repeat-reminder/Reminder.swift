import Foundation

struct Reminder: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var date: Date
    var repeatInterval: TimeInterval?
    
    init(id: UUID = UUID(), title: String, description: String?, date: Date, repeatInterval: TimeInterval?) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.repeatInterval = repeatInterval
    }
}
