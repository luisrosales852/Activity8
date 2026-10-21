//
//  Activity8App.swift
//  Activity8
//
//  Created by Luis on 20/10/26.
//

import SwiftUI
import SwiftData

@main
struct Activity8App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Song.self)
    }
}
