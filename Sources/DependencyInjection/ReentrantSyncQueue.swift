import Dispatch

final class ReentrantSyncQueue {
    private static let key = DispatchSpecificKey<DispatchQueue>()
    private let queue: DispatchQueue

    init(label: String) {
        queue = DispatchQueue(label: label)
        queue.setSpecific(key: Self.key, value: queue)
    }

    func sync<T>(execute block: () -> T) -> T {
        DispatchQueue.getSpecific(key: Self.key) == queue
            ? block()
            : queue.sync(execute: block)
    }
}
