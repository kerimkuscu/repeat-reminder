import SwiftUI

struct ReminderEditView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ReminderViewModel
    
    let reminder: Reminder
    @State private var title: String
    @State private var description: String
    @State private var date: Date
    @State private var repeatInterval: TimeInterval
    
    init(reminder: Reminder, viewModel: ReminderViewModel) {
        self.reminder = reminder
        self.viewModel = viewModel
        _title = State(initialValue: reminder.title)
        _description = State(initialValue: reminder.description ?? "")
        _date = State(initialValue: reminder.date)
        _repeatInterval = State(initialValue: reminder.repeatInterval ?? 0)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Hatırlatma Detayları")) {
                    TextField("Başlık", text: $title)
                    TextField("Açıklama", text: $description)
                }
                
                Section(header: Text("Zaman Ayarları")) {
                    DatePicker("Tarih",
                             selection: $date,
                             displayedComponents: [.date])
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                    
                    DatePicker("Saat",
                             selection: $date,
                             displayedComponents: [.hourAndMinute])
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                    
                    Picker("Tekrarlama", selection: $repeatInterval) {
                        ForEach(RepeatOption.allCases, id: \.rawValue) { option in
                            Text(option.title).tag(option.rawValue)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        viewModel.deleteReminder(reminder)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Anımsatıcıyı Sil")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Hatırlatmayı Düzenle")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        viewModel.updateReminder(
                            reminder,
                            title: title,
                            description: description,
                            date: date,
                            repeatInterval: repeatInterval
                        )
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
    }
}
