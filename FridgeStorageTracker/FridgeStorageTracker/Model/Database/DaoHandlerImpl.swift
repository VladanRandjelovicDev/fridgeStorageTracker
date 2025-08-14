import Combine
import CoreData

class DaoHandlerImpl<T: NSManagedObject>: NSObject, DaoHandler, NSFetchedResultsControllerDelegate {

    @Published private var _entities: [T] = []

    var entities: AnyPublisher<[T], Never> {
        $_entities.eraseToAnyPublisher()
    }

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
            self._entities = (fetchedResultsController.fetchedObjects ?? [])
                .compactMap { $0 as? T }
        } catch {
            debugPrint("Fetch failed:", error)
        }
    }

    func insertAll(count: Int, populate: @escaping ([T]) -> Void) throws {
        Task { @MainActor in
            guard count > 0 else {
                return
            }

            var entities: [T] = []
            for _ in 0..<count {
                entities.append(T(context: context))
            }

            populate(entities)
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            try context.save()
        }
    }

    func insert(populate: @escaping (T) -> Void) throws {
        Task { @MainActor in
            let entity = T(context: context)
            populate(entity)
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            try context.save()
        }
    }

    func update(id: UUID, populate: @escaping (T) -> Void) throws {
        Task { @MainActor in
            let request = T.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id.uuidString)

            if let entity = try context.fetch(request).first as? T {
                populate(entity)
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                try context.save()
            }
        }
    }

    func get(id: UUID) throws -> T? {
        let request = T.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        return try context.fetch(request).first as? T
    }

    func delete(id: UUID) throws {
        Task { @MainActor in
            let request = T.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id.uuidString)

            if let entity = try context.fetch(request).first as? T {
                context.delete(entity)
                try context.save()
            }
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let items = controller.fetchedObjects as? [T] else { return }

        self._entities = items
    }
}
