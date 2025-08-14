import SwiftUI
import CoreData

/*class BackupDaoHandlerImpl<T: NSManagedObject & Identifiable>: NSObject, DaoHandler, NSFetchedResultsControllerDelegate {

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \T.id, ascending: true)],
        animation: .default
    )
    private var entitiesResults: FetchedResults<T> {
        didSet {
            entities = entitiesResults.map { $0 }
        }
    }

    @Published private(set) var entities: [T] = []

    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<any NSFetchRequestResult>

    init(persistance: Persistence? = nil) {
        self.context = (persistance ?? Persistence.shared).viewContext

        let fetchRequest = T.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]

        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            self.entities = (fetchedResultsController.fetchedObjects ?? [])
                .compactMap { $0 as? T }
        } catch {
            debugPrint("Fetch failed:", error)
        }
    }

    func insert(populate: (T) -> Void) throws {
        let entity = T(context: context)
        populate(entity)
        try context.save()
    }

    func update(id: UUID, populate: (T) -> Void) throws {
        let request = T.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)

        if let entity = try context.fetch(request).first as? T {
            populate(entity)
            try context.save()
        }
    }

    func get(id: UUID) throws -> T? {
        let request = T.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        return try context.fetch(request).first as? T
    }

    func delete(id: UUID) throws {
        let request = T.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)

        if let entity = try context.fetch(request).first as? T {
            context.delete(entity)
            try context.save()
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let items = controller.fetchedObjects as? [T] else { return }

        self.entities = items
    }
}
*/
