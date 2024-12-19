//
//  repeat_reminderApp.swift
//  repeat-reminder
//
//  Created by Kerim Kuşcu on 19.12.2024.
//

import SwiftUI

@main
struct repeat_reminderApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
