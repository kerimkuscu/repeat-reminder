import SwiftUI

struct AddReminderView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ReminderViewModel
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var date: Date = Date()
    @State private var repeatInterval: TimeInterval = 0
    @State private var selectedGroupId: UUID?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Hatırlatma Detayları")) {
                    TextField("Başlık", text: $title)
                    TextField("Açıklama", text: $description)
                }
                
                Section(header: Text("Zaman Ayarları")) {
                    // Tarih seçici
                    DatePicker("Tarih",
                             selection: $date,
                             displayedComponents: [.date])
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                    
                    // Saat seçici
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
                
                Section(header: Text("Grup")) {
                    Picker("Grup", selection: $selectedGroupId) {
                        ForEach(viewModel.groups) { group in
                            Text(group.name).tag(group.id as UUID?)
                        }
                    }
                }
            }
            .navigationTitle("Anımsatıcı Ekle")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        if let groupId = selectedGroupId {
                            viewModel.addReminder(
                                title: title,
                                description: description,
                                date: date,
                                repeatInterval: repeatInterval,
                                groupId: groupId
                            )
                        }
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
        .onAppear {
            // Varsayılan olarak ilk grubu seç
            selectedGroupId = viewModel.groups.first?.id
        }
    }
}
