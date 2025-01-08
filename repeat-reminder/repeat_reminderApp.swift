import SwiftUI
import UserNotifications

@main
struct repeat_reminderApp: App {
    init() {
        // Bildirim izinlerini iste
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, error in
            if granted {
                print("Bildirim izni verildi")
                // Bildirim ayarlarını yapılandır
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.delegate = NotificationDelegate.shared
            } else {
                print("Bildirim izni reddedildi: \(error?.localizedDescription ?? "")")
            }
        }
        
        // Varsayılan locale'i Türkçe yap
        UserDefaults.standard.set(["tr_TR"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Bildirim delegesi
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Uygulama açıkken de bildirimleri göster
        completionHandler([.banner, .sound, .badge])
    }
}
