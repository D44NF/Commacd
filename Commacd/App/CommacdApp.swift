import SwiftUI

@main
struct CommacdApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .commands {
            TabCommands()
        }
    }
}
