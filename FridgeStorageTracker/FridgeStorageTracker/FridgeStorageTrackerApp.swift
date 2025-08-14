import SwiftUI

@main
struct FridgeStorageTrackerApp: App {
    let persistenceController = Persistence.shared

    var body: some Scene {
        WindowGroup {
            FridgeContentView(viewModel: FridgeContentViewModelImpl())
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
