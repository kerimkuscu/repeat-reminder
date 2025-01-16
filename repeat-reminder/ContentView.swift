import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ReminderViewModel()
    @State private var showingAddReminder = false
    @State private var showingAddGroup = false
    @State private var showingEditGroup = false
    @State private var showingEditReminder = false
    @State private var newGroupName = ""
    @State private var selectedGroup: ReminderGroup?
    @State private var selectedReminder: Reminder?
    @State private var editingGroupName = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.groups) { group in
                    Section(header: GroupHeaderView(group: group,
                                                  onEdit: {
                        selectedGroup = group
                        editingGroupName = group.name
                        showingEditGroup = true
                    },
                                                  onDelete: {
                        viewModel.deleteGroup(group)
                    })) {
                        ForEach(group.reminders) { reminder in
                            ReminderRowView(reminder: reminder) {
                            // Önce reminder'ı seçelim
                            withAnimation {
                                // Önce sheet'i aç
                                showingEditReminder = true
                                // Sonra reminder'ı seç
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    selectedReminder = reminder
                                }
                            }
                        }
                            .contextMenu {
                                ForEach(viewModel.groups.filter { $0.id != group.id }) { targetGroup in
                                    Button {
                                        viewModel.moveReminder(reminder, from: group, to: targetGroup)
                                    } label: {
                                        Label("'\(targetGroup.name)' grubuna taşı", systemImage: "folder")
                                    }
                                }
                                
                                Button(role: .destructive) {
                                    viewModel.deleteReminder(reminder)
                                } label: {
                                    Label("Sil", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Anımsatıcılar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddReminder = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingAddGroup = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingEditReminder) {
                if let reminder = selectedReminder {
                    ReminderEditView(reminder: reminder, viewModel: viewModel)
                }
            }
            .alert("Yeni Grup", isPresented: $showingAddGroup) {
                TextField("Grup Adı", text: $newGroupName)
                Button("İptal", role: .cancel) {}
                Button("Ekle") {
                    if !newGroupName.isEmpty {
                        viewModel.addGroup(name: newGroupName)
                        newGroupName = ""
                    }
                }
            }
            .alert("Grubu Düzenle", isPresented: $showingEditGroup) {
                TextField("Grup Adı", text: $editingGroupName)
                Button("İptal", role: .cancel) {}
                Button("Kaydet") {
                    if let group = selectedGroup, !editingGroupName.isEmpty {
                        viewModel.updateGroup(group, newName: editingGroupName)
                    }
                }
            }
        }
    }
}

// Grup başlığı için özel view
struct GroupHeaderView: View {
    let group: ReminderGroup
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(group.name)
            Spacer()
            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}

