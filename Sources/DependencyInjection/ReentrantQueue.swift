import Dispatch

final class ReentrantQueue {
    private let key = DispatchSpecificKey<DispatchQueue>()
    private let queue: DispatchQueue

    init(label: String) {
        queue = DispatchQueue(label: label)
        queue.setSpecific(key: key, value: queue)
    }

    deinit {
        queue.setSpecific(key: key, value: nil)
    }

    func sync<T>(execute block: () -> T) -> T {
        DispatchQueue.getSpecific(key: key) == queue
            ? block()
            : queue.sync(execute: block)
    }
}
