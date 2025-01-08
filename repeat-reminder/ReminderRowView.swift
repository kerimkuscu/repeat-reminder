import SwiftUI

struct ReminderRowView: View {
    let reminder: Reminder
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(reminder.title)
                        .font(.headline)
                    
                    Spacer()
                    
                    // Tekrarlama göstergesi
                    if reminder.repeatInterval ?? 0 > 0 {
                        Image(systemName: "repeat")
                            .foregroundColor(.blue)
                    }
                }
                
                HStack {
                    // Tarih
                    Text(reminder.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    // Saat
                    Text(reminder.date, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let description = reminder.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 4)
    }
}

#Preview {
    ReminderRowView(reminder: Reminder(
        title: "Örnek Anımsatıcı",
        description: "Bu bir örnek açıklamadır",
        date: Date(),
        repeatInterval: 86400
    )) {
        // Tıklama işlemi için placeholder
    }
    .previewLayout(.sizeThatFits)
    .padding()
} 