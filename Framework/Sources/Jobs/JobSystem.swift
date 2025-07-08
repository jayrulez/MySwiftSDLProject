import Foundation
import Dispatch
import Logging

// MARK: - Job States and Flags
public enum JobState: Sendable {
    case pending
    case running
    case succeeded
    case canceled
}

public struct JobFlags: OptionSet, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let none = JobFlags([])
    public static let runOnMainThread = JobFlags(rawValue: 1 << 0)
    public static let autoRelease = JobFlags(rawValue: 1 << 1)
}

public enum JobPriority: Sendable {
    case normal
    case critical
}

// MARK: - Worker States and Flags
public enum WorkerState: Sendable {
    case idle
    case busy
    case paused
    case dead
}

public struct WorkerFlags: OptionSet, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let none = WorkerFlags([])
    public static let persistent = WorkerFlags(rawValue: 1 << 0)
}

// MARK: - Job Base Class
open class JobBase: @unchecked Sendable {
    public let name: String
    public let flags: JobFlags
    private let stateQueue = DispatchQueue(label: "job.state", attributes: .concurrent)
    private var _state: JobState = .pending
    public let priority: JobPriority
    
    private var dependencies: [JobBase] = []
    private var dependents: [JobBase] = []
    
    public var state: JobState {
        return stateQueue.sync { _state }
    }
    
    public var hasDependents: Bool {
        return !dependents.isEmpty
    }
    
    public init(name: String? = nil, flags: JobFlags = .none, priority: JobPriority = .normal) {
        self.name = name ?? "Unnamed Job"
        self.flags = flags
        self.priority = priority
    }
    
    deinit {
        // Dependencies are automatically cleaned up by ARC
    }
    
    public func addDependency(_ dependency: JobBase) {
        guard dependency !== self else {
            fatalError("Job cannot depend on itself")
        }
        
        guard !dependency.dependencies.contains(where: { $0 === self }) else {
            fatalError("The dependency already depends on the current job")
        }
        
        dependencies.append(dependency)
        dependency.dependents.append(self)
    }
    
    public func isPending() -> Bool {
        return state == .pending
    }
    
    public func isReady() -> Bool {
        guard isPending() else { return false }
        
        for dependency in dependencies {
            if dependency.state != .succeeded {
                return false
            }
        }
        return true
    }
    
    public func cancel() {
        stateQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if self._state != .succeeded && self._state != .canceled {
                self._state = .canceled
                
                // Cancel all dependents
                for dependent in self.dependents {
                    dependent.cancel()
                }
            }
        }
    }
    
    public func isCompleted() -> Bool {
        let currentState = state
        return currentState == .canceled || currentState == .succeeded
    }
    
    // Protected methods for subclasses
    open func execute() {
        // Override in subclasses
    }
    
    open func onCompleted() {
        // Override in subclasses
    }
    
    internal func run() {
        guard isReady() else {
            return
        }
        
        stateQueue.async(flags: .barrier) { [weak self] in
            self?._state = .running
        }
        
        execute()
        
        stateQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            // Job could have been canceled in execute method
            if self._state != .canceled {
                self._state = .succeeded
            }
        }
        
        onCompleted()
    }
    
    private func setState(_ newState: JobState) {
        stateQueue.async(flags: .barrier) { [weak self] in
            self?._state = newState
        }
    }
}

// MARK: - Simple Job (no return value)
open class Job: JobBase, @unchecked Sendable {
    public override init(name: String? = nil, flags: JobFlags = .none, priority: JobPriority = .normal) {
        super.init(name: name, flags: flags, priority: priority)
    }
    
    open override func execute() {
        onExecute()
    }
    
    open func onExecute() {
        // Override in subclasses
    }
}

// MARK: - Generic Job (with return value)
open class ResultJob<T: Sendable>: JobBase, @unchecked Sendable {
    private var _result: T?
    private let resultQueue = DispatchQueue(label: "job.result", attributes: .concurrent)
    private let onCompletedCallback: (@Sendable (T) -> Void)?
    
    public var result: T? {
        // Wait for completion and return result
        return getResult()
    }
    
    public init(
        name: String? = nil,
        flags: JobFlags = .none,
        priority: JobPriority = .normal,
        onCompletedCallback: (@Sendable (T) -> Void)? = nil
    ) {
        self.onCompletedCallback = onCompletedCallback
        super.init(name: name, flags: flags, priority: priority)
    }
    
    open override func execute() {
        let result = onExecute()
        resultQueue.async(flags: .barrier) { [weak self] in
            self?._result = result
        }
    }
    
    open func onExecute() -> T {
        fatalError("Must override onExecute() in subclass")
    }
    
    open override func onCompleted() {
        if let result = _result {
            onCompletedCallback?(result)
        }
    }
    
    private func getResult() -> T? {
        while !isCompleted() {
            Thread.sleep(forTimeInterval: 0.001) // Small sleep to avoid busy waiting
        }
        return resultQueue.sync { _result }
    }
}

// MARK: - Delegate Jobs
public class DelegateJob: Job, @unchecked Sendable {
    private let jobClosure: @Sendable () -> Void
    
    public init(
        _ jobClosure: @escaping @Sendable () -> Void,
        name: String? = nil,
        flags: JobFlags = .none
    ) {
        self.jobClosure = jobClosure
        super.init(name: name, flags: flags)
    }
    
    public override func onExecute() {
        jobClosure()
    }
}

public class DelegateResultJob<T: Sendable>: ResultJob<T>, @unchecked Sendable {
    private let jobClosure: @Sendable () -> T
    
    public init(
        _ jobClosure: @escaping @Sendable () -> T,
        name: String? = nil,
        flags: JobFlags = .none,
        onCompletedCallback: (@Sendable (T) -> Void)? = nil
    ) {
        self.jobClosure = jobClosure
        super.init(name: name, flags: flags, onCompletedCallback: onCompletedCallback)
    }
    
    public override func onExecute() -> T {
        return jobClosure()
    }
}

// MARK: - Job Group
public class JobGroup: Job, @unchecked Sendable {
    private var jobs: [JobBase] = []
    
    public init(name: String? = nil, flags: JobFlags = .none) {
        super.init(name: name, flags: flags)
    }
    
    public override func cancel() {
        if state == .running {
            // Do not cancel a job that is already running
            return
        }
        
        for job in jobs {
            job.cancel()
        }
        super.cancel()
    }
    
    public override func onExecute() {
        for job in jobs {
            job.run()
        }
    }
    
    public func addJob(_ job: JobBase) {
        guard state == .pending else {
            fatalError("Cannot add job to JobGroup unless the State is pending")
        }
        
        jobs.append(job)
    }
}

// MARK: - Worker Base Class
internal class Worker: @unchecked Sendable {
    nonisolated let jobSystem: JobSystem
    nonisolated let name: String
    nonisolated let flags: WorkerFlags
    internal let stateQueue = DispatchQueue(label: "worker.state", attributes: .concurrent)
    internal var _state: WorkerState = .paused
    internal var _isRunning = false
    
    internal let jobsQueue = DispatchQueue(label: "worker.jobs", attributes: .concurrent)
    internal var jobs: [JobBase] = []
    
    nonisolated var state: WorkerState {
        return stateQueue.sync { _state }
    }
    
    nonisolated var isRunning: Bool {
        return stateQueue.sync { _isRunning }
    }
    
    init(jobSystem: JobSystem, name: String, flags: WorkerFlags = .none) {
        self.jobSystem = jobSystem
        self.name = name
        self.flags = flags
    }
    
    deinit {
        // Jobs are cleaned up by ARC
    }
    
    // Virtual methods for subclasses
    func onStarting() {
        // Override in subclasses
    }
    
    func start() {
        stateQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if self._isRunning {
                Task { @MainActor in
                    self.jobSystem.logger?.error("Start called on a worker '\(self.name)' that is already running.")
                }
                return
            }
            
            self.onStarting()
            self._isRunning = true
        }
    }
    
    func onStopping() {
        // Override in subclasses
    }
    
    func stop() {
        stateQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if !self._isRunning {
                Task { @MainActor in
                    self.jobSystem.logger?.error("Stop called on a worker '\(self.name)' that is not running.")
                }
                return
            }
            
            self._isRunning = false
        }
        
        // Ensure the last task is completed
        waitForIdle()
        
        onStopping()
        
        jobsQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            // Return remaining jobs to the job system
            Task { @MainActor in
                for job in self.jobs {
                    await self.jobSystem.addJob(job)
                }
            }
            self.jobs.removeAll()
            
            self.stateQueue.async(flags: .barrier) {
                self._state = .dead
            }
        }
    }
    
    func waitForIdle() {
        while state != .idle {
            if state == .paused {
                resume()
            }
            update()
            Thread.sleep(forTimeInterval: 0.001)
        }
    }
    
    func onPausing() {
        // Override in subclasses
    }
    
    func pause() {
        jobsQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if self.state == .idle && self.jobs.isEmpty {
                self.onPausing()
                self.stateQueue.async(flags: .barrier) {
                    self._state = .paused
                }
            } else {
                Task { @MainActor in
                    self.jobSystem.logger?.warning("Pause called on worker that is not idle. The worker will not be paused.")
                }
            }
        }
    }
    
    func onResuming() {
        // Override in subclasses
    }
    
    func resume() {
        stateQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if self._state == .paused {
                self.onResuming()
                self._state = .idle
            } else {
                Task { @MainActor in
                    self.jobSystem.logger?.warning("Resume called on worker that is not paused.")
                }
            }
        }
    }
    
    func queueJob(_ job: JobBase) -> Result<Void, Error> {
        if state == .dead {
            return .failure(JobSystemError.workerDead)
        }
        
        if state == .paused {
            resume()
        }
        
        jobsQueue.async(flags: .barrier) { [weak self] in
            self?.jobs.append(job)
        }
        
        return .success(())
    }
    
    func queueJobs(_ jobsToQueue: [JobBase]) -> Result<Void, Error> {
        if state == .dead {
            return .failure(JobSystemError.workerDead)
        }
        
        if state == .paused {
            resume()
        }
        
        jobsQueue.async(flags: .barrier) { [weak self] in
            self?.jobs.append(contentsOf: jobsToQueue)
        }
        
        return .success(())
    }
    
    func update() {
        // Override in subclasses
    }
    
    func processJobs() {
        while !jobs.isEmpty {
            if !isRunning {
                break
            }
            
            stateQueue.async(flags: .barrier) { [weak self] in
                self?._state = .busy
            }
            
            let job: JobBase? = jobsQueue.sync(flags: .barrier) { [weak self] in
                guard let self = self else { return nil }
                return jobs.isEmpty ? nil : jobs.removeFirst()
            }
            
            guard let job = job else { break }
            
            if !job.isReady() {
                // If the job is not ready to run, re-queue with the job system
                Task { @MainActor in
                    await jobSystem.addJob(job)
                }
                continue
            }
            
            Task { @MainActor in
                jobSystem.logger?.info("Worker: \(name) - Running job: \(job.name)")
            }
            job.run()
            
            Task { @MainActor in
                await jobSystem.handleProcessedJob(job, worker: self)
            }
        }
        
        stateQueue.async(flags: .barrier) { [weak self] in
            self?._state = .idle
        }
    }
}

// MARK: - Background Worker
internal class BackgroundWorker: Worker, @unchecked Sendable {
    private var workerThread: Thread?
    
    override init(jobSystem: JobSystem, name: String, flags: WorkerFlags = .none) {
        super.init(jobSystem: jobSystem, name: name, flags: flags)
    }
    
    deinit {
        if let thread = workerThread, !thread.isFinished {
            thread.cancel()
        }
    }
    
    override func onStarting() {
        workerThread = Thread { [weak self] in
            self?.processJobsAsync()
        }
        workerThread?.name = name
        workerThread?.start()
    }
    
    override func onStopping() {
        workerThread?.cancel()
        workerThread = nil
    }
    
    override func onPausing() {
        // Note: Thread suspend/resume is deprecated in modern systems
        // We'll handle pausing through the job processing loop instead
    }
    
    override func onResuming() {
        // Handled through the job processing loop
    }
    
    private func processJobsAsync() {
        while !Thread.current.isCancelled {
            if !isRunning {
                return
            }
            
            processJobs()
            
            // Small sleep to prevent busy waiting when no jobs are available
            Thread.sleep(forTimeInterval: 0.001)
        }
    }
    
    override func update() {
        if let thread = workerThread, thread.isFinished {
            // The worker needs to be stopped
            stateQueue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }
                self._isRunning = false
                self._state = .dead
            }
        }
        
        if !isRunning {
            // Return any pending jobs to the job system if the worker dies
            jobsQueue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }
                Task { @MainActor in
                    for job in self.jobs {
                        await self.jobSystem.addJob(job)
                    }
                }
                self.jobs.removeAll()
            }
        }
    }
}

// MARK: - Main Thread Worker
internal class MainThreadWorker: Worker, @unchecked Sendable {
    init(jobSystem: JobSystem, name: String) {
        super.init(jobSystem: jobSystem, name: name, flags: .persistent)
    }
    
    override func update() {
        processJobs()
    }
}

// MARK: - Job System Errors
public enum JobSystemError: Error {
    case notRunning
    case alreadyRunning
    case workerDead
}

extension Result {
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    var isFailure: Bool {
        return !isSuccess
    }
}

// MARK: - Job System
@MainActor
public class JobSystem {
    private let minimumBackgroundWorkers: Int
    private var workers: [BackgroundWorker] = []
    private var mainThreadWorker: MainThreadWorker?
    
    private nonisolated let jobsQueue = DispatchQueue(label: "jobsystem.jobs", attributes: .concurrent)
    private var jobsToRun: [JobBase] = []
    
    private nonisolated let completedJobsQueue = DispatchQueue(label: "jobsystem.completed", attributes: .concurrent)
    private var completedJobs: [JobBase] = []
    
    private nonisolated let cancelledJobsQueue = DispatchQueue(label: "jobsystem.cancelled", attributes: .concurrent)
    private var cancelledJobs: [JobBase] = []
    
    private var isRunning = false
    
    public var workerCount: Int { workers.count }
    public let logger: Logger?
    
    public init(logger: Logger? = nil, workerCount: Int = 0) {
        self.logger = logger
        
        let coreCount = ProcessInfo.processInfo.processorCount
        self.minimumBackgroundWorkers = min(max(0, workerCount), coreCount - 1)
    }
    
    deinit {
        // Remove the problematic async shutdown from deinit
        // The user should call shutdown() explicitly before deallocation
    }
    
    private func createWorkers() {
        mainThreadWorker = MainThreadWorker(jobSystem: self, name: "Main Thread Worker")
        
        for i in 0..<minimumBackgroundWorkers {
            let worker = BackgroundWorker(jobSystem: self, name: "Worker \(i)", flags: .persistent)
            workers.append(worker)
        }
    }
    
    private func destroyWorkers() {
        mainThreadWorker = nil
        workers.removeAll()
    }
    
    private func onJobCompleted(_ job: JobBase, worker: Worker?) {
        completedJobs.append(job)
    }
    
    private func onJobCancelled(_ job: JobBase, worker: Worker?) {
        cancelledJobs.append(job)
    }
    
    internal func handleProcessedJob(_ job: JobBase, worker: Worker?) async {
        switch job.state {
        case .succeeded:
            onJobCompleted(job, worker: worker)
        case .canceled:
            onJobCancelled(job, worker: worker)
        default:
            break
        }
    }
    
    public func startup() {
        guard !isRunning else {
            logger?.error("Startup called on JobSystem that is already running.")
            return
        }
        
        createWorkers()
        
        mainThreadWorker?.start()
        
        for worker in workers {
            if !worker.isRunning {
                worker.start()
            }
        }
        
        isRunning = true
    }
    
    public func shutdown() {
        guard isRunning else {
            logger?.error("Shutdown called on JobSystem that is not running.")
            return
        }
        
        for worker in workers {
            if worker.state == .paused {
                worker.resume()
            }
            worker.stop()
        }
        
        mainThreadWorker?.stop()
        
        // Cancel remaining jobs
        for job in jobsToRun {
            job.cancel()
            onJobCancelled(job, worker: nil)
        }
        jobsToRun.removeAll()
        
        clearCompletedJobs()
        clearCancelledJobs()
        
        isRunning = false
        destroyWorkers()
    }
    
    public func update() {
        guard isRunning else {
            logger?.error("Update called on JobSystem that is not running.")
            return
        }
        
        // Get jobs to run
        let jobsToProcess = jobsToRun
        jobsToRun.removeAll()
        
        for job in jobsToProcess {
            if !job.isReady() {
                // Requeue job
                Task {
                    await addJob(job)
                }
                continue
            }
            
            // Queue the job on the main thread worker if it has the RunOnMainThread flag
            // or no background workers exist
            if job.flags.contains(.runOnMainThread) || workers.isEmpty {
                if mainThreadWorker?.queueJob(job).isFailure == true {
                    logger?.error("Failed to queue job on main thread worker '\(mainThreadWorker?.name ?? "unknown")'.")
                    // Re-queue the job
                    Task {
                        await addJob(job)
                    }
                }
                continue
            }
            
            // Try to get an available worker
            if let worker = getAvailableWorker() {
                switch job.state {
                case .canceled:
                    onJobCancelled(job, worker: nil)
                case .succeeded:
                    onJobCompleted(job, worker: nil)
                default:
                    if worker.queueJob(job).isFailure {
                        logger?.error("Failed to queue job on worker '\(worker.name)'.")
                        Task {
                            await addJob(job) // Re-queue the job
                        }
                    }
                }
            } else {
                // No available workers, re-queue the job
                Task {
                    await addJob(job)
                }
            }
        }
        
        // Update and replace dead workers
        var deadWorkers: [BackgroundWorker] = []
        for worker in workers {
            worker.update()
            if worker.state == .dead {
                deadWorkers.append(worker)
            }
        }
        
        // Replace dead workers
        for deadWorker in deadWorkers {
            if let index = workers.firstIndex(where: { $0 === deadWorker }) {
                workers.remove(at: index)
                
                if deadWorker.flags.contains(.persistent) {
                    let newWorker = BackgroundWorker(
                        jobSystem: self,
                        name: deadWorker.name,
                        flags: deadWorker.flags
                    )
                    workers.append(newWorker)
                    newWorker.start()
                }
            }
        }
        
        // Process main thread jobs
        mainThreadWorker?.update()
        
        clearCompletedJobs()
        clearCancelledJobs()
    }
    
    public func addJob(_ job: JobBase) async {
        guard isRunning else {
            fatalError("JobSystem is not running.")
        }
        
        jobsToRun.append(job)
    }
    
    public func addJobs(_ jobs: [JobBase]) async {
        guard isRunning else {
            fatalError("JobSystem is not running.")
        }
        
        jobsToRun.append(contentsOf: jobs)
    }
    
    public func addJob(
        _ jobClosure: @escaping @Sendable () -> Void,
        name: String? = nil,
        flags: JobFlags = .none
    ) async {
        guard isRunning else {
            fatalError("JobSystem is not running.")
        }
        
        let job = DelegateJob(jobClosure, name: name, flags: flags.union(.autoRelease))
        await addJob(job)
    }
    
    public func addJob<T: Sendable>(
        _ jobClosure: @escaping @Sendable () -> T,
        name: String? = nil,
        flags: JobFlags = .none,
        onCompletedCallback: (@Sendable (T) -> Void)? = nil
    ) async {
        guard isRunning else {
            fatalError("JobSystem is not running.")
        }
        
        let job = DelegateResultJob<T>(
            jobClosure,
            name: name,
            flags: flags.union(.autoRelease),
            onCompletedCallback: onCompletedCallback
        )
        await addJob(job)
    }
    
    private func getAvailableWorker() -> BackgroundWorker? {
        return workers.first { worker in
            worker.state == .idle || worker.state == .paused
        }
    }
    
    private func clearCancelledJobs() {
        cancelledJobs.removeAll()
    }
    
    private func clearCompletedJobs() {
        completedJobs.removeAll()
    }
}