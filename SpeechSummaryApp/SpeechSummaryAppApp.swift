//
//  SpeechSummaryAppApp.swift
//  SpeechSummaryApp
//
//  Created by Mohandas Palatshaha on 12/08/24.
//

import SwiftUI

@main
struct SpeechSummaryAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
