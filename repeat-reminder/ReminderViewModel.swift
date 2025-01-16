import Foundation
import UserNotifications

class ReminderViewModel: ObservableObject {
    @Published var groups: [ReminderGroup] = []
    private let saveKey = "SavedReminderGroups"
    
    init() {
        loadGroups()
    }
    
    // Grupları yükle
    private func loadGroups() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else {
            // İlk çalıştırmada varsayılan bir grup oluştur
            groups = [ReminderGroup(name: "Genel")]
            saveGroups()
            return
        }
        
        do {
            groups = try JSONDecoder().decode([ReminderGroup].self, from: data)
        } catch {
            print("Gruplar yüklenirken hata oluştu: \(error)")
            // Hata durumunda varsayılan grup oluştur
            groups = [ReminderGroup(name: "Genel")]
            saveGroups()
        }
    }
    
    // Grupları kaydet
    private func saveGroups() {
        do {
            let encodedData = try JSONEncoder().encode(groups)
            UserDefaults.standard.set(encodedData, forKey: saveKey)
        } catch {
            print("Gruplar kaydedilirken hata oluştu: \(error)")
        }
    }

    // Yeni grup oluştur
    func addGroup(name: String) {
        let newGroup = ReminderGroup(name: name)
        groups.append(newGroup)
        saveGroups()
    }
    
    // Gruba anımsatıcı ekle
    func addReminder(title: String, description: String, date: Date, repeatInterval: TimeInterval, groupId: UUID) {
        let reminder = Reminder(title: title, description: description, date: date, repeatInterval: repeatInterval)
        
        // Eğer hiç grup yoksa, yeni bir "Genel" grup oluştur
        if groups.isEmpty {
            let generalGroup = ReminderGroup(name: "Genel")
            groups.append(generalGroup)
        }
        
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].reminders.append(reminder)
            scheduleNotification(for: reminder)
            saveGroups()
        } else {
            // Eğer belirtilen grup bulunamazsa, ilk gruba ekle
            if !groups.isEmpty {
                groups[0].reminders.append(reminder)
                scheduleNotification(for: reminder)
                saveGroups()
            }
        }
    }
    
    // Grubu sil
    func deleteGroup(_ group: ReminderGroup) {
        // Eğer son grup silinmeye çalışılıyorsa, yeni bir "Genel" grup oluştur
        if groups.count <= 1 {
            // Önce eski gruptaki anımsatıcıların bildirimlerini kaldır
            for reminder in group.reminders {
                UNUserNotificationCenter.current().removePendingNotificationRequests(
                    withIdentifiers: ["reminder-\(reminder.id.uuidString)", "reminder-\(reminder.id.uuidString)-repeat"]
                )
            }
            
            // Yeni "Genel" grup oluştur
            groups = [ReminderGroup(name: "Genel")]
            saveGroups()
            return
        }
        
        // Gruptaki tüm anımsatıcıların bildirimlerini kaldır
        for reminder in group.reminders {
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: ["reminder-\(reminder.id.uuidString)", "reminder-\(reminder.id.uuidString)-repeat"]
            )
        }
        
        groups.removeAll { $0.id == group.id }
        saveGroups()
    }
    
    // Bildirim Planlama
    func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.description ?? ""
        content.sound = .defaultCritical
        
        // Bildirim zamanını ayarla
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // İlk bildirim için request oluştur
        let request = UNNotificationRequest(
            identifier: "reminder-\(reminder.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Mevcut bildirimleri temizle
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [request.identifier]
        )
        
        // Bildirimi planla
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim planlanırken hata oluştu: \(error)")
            } else {
                print("Bildirim başarıyla planlandı: \(reminder.title) için \(reminder.date)")
            }
        }
        
        // Tekrarlama varsa
        if let repeatInterval = reminder.repeatInterval, repeatInterval > 0 {
            // Yeni bir content oluştur
            let repeatingContent = UNMutableNotificationContent()
            repeatingContent.title = content.title
            repeatingContent.body = content.body
            repeatingContent.sound = content.sound
            
            let repeatingTrigger = UNTimeIntervalNotificationTrigger(
                timeInterval: repeatInterval,
                repeats: true
            )
            
            let repeatingRequest = UNNotificationRequest(
                identifier: "reminder-\(reminder.id.uuidString)-repeat",
                content: repeatingContent,
                trigger: repeatingTrigger
            )
            
            // Mevcut tekrarlayan bildirimi temizle
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: [repeatingRequest.identifier]
            )
            
            UNUserNotificationCenter.current().add(repeatingRequest) { error in
                if let error = error {
                    print("Tekrarlayan bildirim planlanırken hata oluştu: \(error)")
                } else {
                    print("Tekrarlayan bildirim başarıyla planlandı: \(reminder.title)")
                }
            }
        }
    }
    
    func updateReminder(_ reminder: Reminder, title: String, description: String, date: Date, repeatInterval: TimeInterval) {
        // Eski bildirimi kaldır
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["reminder-\(reminder.id.uuidString)", "reminder-\(reminder.id.uuidString)-repeat"]
        )
        
        // Reminder'ı güncelle
        for groupIndex in groups.indices {
            if let reminderIndex = groups[groupIndex].reminders.firstIndex(where: { $0.id == reminder.id }) {
                groups[groupIndex].reminders[reminderIndex].title = title
                groups[groupIndex].reminders[reminderIndex].description = description
                groups[groupIndex].reminders[reminderIndex].date = date
                groups[groupIndex].reminders[reminderIndex].repeatInterval = repeatInterval
                
                // Yeni bildirimi planla
                scheduleNotification(for: groups[groupIndex].reminders[reminderIndex])
                saveGroups()
                break
            }
        }
    }
    
    func deleteReminder(_ reminder: Reminder) {
        // Bildirimi kaldır
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["reminder-\(reminder.id.uuidString)", "reminder-\(reminder.id.uuidString)-repeat"]
        )
        
        // Tüm gruplarda ara ve bul
        for groupIndex in groups.indices {
            groups[groupIndex].reminders.removeAll { $0.id == reminder.id }
        }
        saveGroups()
    }
    
    // Grup güncelleme
    func updateGroup(_ group: ReminderGroup, newName: String) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index].name = newName
            saveGroups()
        }
    }
    
    // Anımsatıcıyı başka bir gruba taşı
    func moveReminder(_ reminder: Reminder, from sourceGroup: ReminderGroup, to targetGroup: ReminderGroup) {
        guard let sourceIndex = groups.firstIndex(where: { $0.id == sourceGroup.id }),
              let targetIndex = groups.firstIndex(where: { $0.id == targetGroup.id }),
              let reminderIndex = groups[sourceIndex].reminders.firstIndex(where: { $0.id == reminder.id })
        else { return }
        
        let reminderToMove = groups[sourceIndex].reminders.remove(at: reminderIndex)
        groups[targetIndex].reminders.append(reminderToMove)
        saveGroups()
    }
}
