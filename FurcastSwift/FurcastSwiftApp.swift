//
//  FurcastSwiftApp.swift
//  FurcastSwift
//
//  Created by Somayan Chakrabarti on 6/10/25.
//

import SwiftUI

@main
struct FurcastSwiftApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
