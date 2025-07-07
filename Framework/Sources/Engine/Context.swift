import Foundation

import SedulousFoundation
import SedulousJobs
import SedulousResources

public typealias ContextInitializingCallback = (_ initializer: ContextInitializer) -> Void;
public typealias ContextInitializedCallback = (_ context: Context) -> Void;
public typealias ContextShuttingDownCallback = (_ context: Context) -> Void;

public enum ContextUpdateStage : CaseIterable
{
    case preUpdate
    case postUpdate
    case variableUpdate
    case fixedUpdate
}

public struct ContextUpdateInfo
{
    public var context: Context;
    public var time: UpdateTime;
}

public typealias ContextUpdateFunction = (_ info : ContextUpdateInfo) -> Void

public struct ContextUpdateFunctionInfo
{
    public var priority : Int;
    public var stage : ContextUpdateStage;
    public var function : ContextUpdateFunction;

    public init(function: @escaping ContextUpdateFunction, priority: Int = 0, stage: ContextUpdateStage = .variableUpdate)
    {
        self.priority = priority;
        self.stage = stage;
        self.function = function;
    }
}

public typealias RegisteredUpdateFunctionID = UUID

public class Context
{
    public private(set) var scenes: SceneSystem
    public private(set) var jobs: JobSystem  
    public private(set) var resources: ResourceSystem

    package var subsystems: [Subsystem] = []

    private var accumulator: Double = 0.0
    private let fixedTimeStep: Double = 1.0 / 60.0 // 60 Hz

    private var totalTime: Double = 0.0

    public struct RegisteredUpdateFunctionInfo
	{
        public var id: UUID
        public var stage: ContextUpdateStage
		public var priority: Int;
		public var function: ContextUpdateFunction;
	}

    private var updateFunctions: Dictionary<ContextUpdateStage, Array<RegisteredUpdateFunctionInfo>> = .init()
	private var updateFunctionsToRegister: Array<RegisteredUpdateFunctionInfo> = .init()
	private var updateFunctionsToUnregister: Array<RegisteredUpdateFunctionInfo> = .init()

    package init() {
        jobs = JobSystem()
        resources = ResourceSystem(jobSystem: jobs)
        scenes = SceneSystem()

        for stage: ContextUpdateStage in ContextUpdateStage.allCases
        {
            updateFunctions[stage] = .init();
        }
    }

    deinit {
    }

    public func getSubsystem<T: Subsystem>(ofType type: T.Type) -> T? {
        for subsystem in subsystems {
            if let typed = subsystem as? T {
                return typed
            }
        }
        return nil
    }

    package func initialize(_ initializer: ContextInitializer) {
        jobs.startup()
        resources.startup()
        scenes.startup()

        self.subsystems = initializer.subsystems
        for subsystem in subsystems {
            subsystem.initialize(self)
            print("Initialized subsystem: \(subsystem.name)")
        }

        totalTime = 0.0
        accumulator = 0.0
    }

    package func update(_ updateTime: UpdateTime) {
        jobs.update()
        resources.update()

        let elapsed = updateTime.elapsedTime
        totalTime = updateTime.totalTime

        // Process registration/unregistration queues
        processUpdateFunctionsToRegister()
        processUpdateFunctionsToUnregister()

        // Pre-update
        let preUpdateInfo = ContextUpdateInfo(context: self, time: updateTime)
        runUpdateFunctions(stage: .preUpdate, info: preUpdateInfo)

        // Fixed update
        accumulator += elapsed
        while accumulator >= fixedTimeStep {
            let fixedUpdateTime = UpdateTime(fixedTimeStep, totalTime)
            let fixedUpdateInfo = ContextUpdateInfo(context: self, time: fixedUpdateTime)
            runUpdateFunctions(stage: .fixedUpdate, info: fixedUpdateInfo)
            accumulator -= fixedTimeStep
        }

        do {
            scenes.update(updateTime)
        }

        // Variable update
        let variableUpdateInfo = ContextUpdateInfo(context: self, time: updateTime)
        runUpdateFunctions(stage: .variableUpdate, info: variableUpdateInfo)

        // Post-update
        let postUpdateInfo = ContextUpdateInfo(context: self, time: updateTime)
        runUpdateFunctions(stage: .postUpdate, info: postUpdateInfo)
    }

    package func shutdown() {
        for subsystem in subsystems.reversed() {
            subsystem.shutdown()
            print("Shutdown subsystem: \(subsystem.name)")
        }

        scenes.shutdown()
        resources.shutdown()
        jobs.shutdown()
    }

    public func registerUpdateFunction(info: ContextUpdateFunctionInfo) -> RegisteredUpdateFunctionInfo {
        let registration = RegisteredUpdateFunctionInfo(
            id: UUID(),
            stage: info.stage,
            priority: info.priority,
            function: info.function
        )
        updateFunctionsToRegister.append(registration)
        return registration
    }

    public func registerUpdateFunctions(_ infos: [ContextUpdateFunctionInfo]) -> [RegisteredUpdateFunctionInfo] {
        return infos.map { registerUpdateFunction(info: $0) }
    }

    public func unregisterUpdateFunction(_ registration: RegisteredUpdateFunctionInfo) {
        updateFunctionsToUnregister.append(registration)
    }

    public func unregisterUpdateFunctions(_ registrations: [RegisteredUpdateFunctionInfo]) {
        for reg in registrations {
            updateFunctionsToUnregister.append(reg)
        }
    }

    private func sortUpdateFunctions() {
        for stage in ContextUpdateStage.allCases {
            updateFunctions[stage]?.sort { lhs, rhs in
                if lhs.priority == rhs.priority {
                    return false
                }
                return lhs.priority < rhs.priority
            }
        }
    }

    private func processUpdateFunctionsToRegister() {
        guard !updateFunctionsToRegister.isEmpty else { return }
        for info in updateFunctionsToRegister {
            updateFunctions[info.stage]?.append(info)
        }
        updateFunctionsToRegister.removeAll()
        sortUpdateFunctions()
    }

    private func processUpdateFunctionsToUnregister() {
        guard !updateFunctionsToUnregister.isEmpty else { return }
        for fn in updateFunctionsToUnregister {
            for stage in ContextUpdateStage.allCases {
                if let idx = updateFunctions[stage]?.firstIndex(where: { $0.id == fn.id }) {
                    updateFunctions[stage]?.remove(at: idx)
                }
            }
        }
        updateFunctionsToUnregister.removeAll()
        sortUpdateFunctions()
    }

    private func runUpdateFunctions(stage: ContextUpdateStage, info: ContextUpdateInfo) {
        for updateFunctionInfo in updateFunctions[stage] ?? [] {
            updateFunctionInfo.function(info)
        }
    }
}