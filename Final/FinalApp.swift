//
//  FinalApp.swift
//  Final
//
//  Created by user12 on 2024/12/5.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct FinalApp: App {
    init() {
        do {
            try Tips.configure()
        } catch {
            print("Failed to configure Tips: \(error)")
        }
    }


    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
