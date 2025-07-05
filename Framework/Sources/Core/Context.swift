public class Context
{
    package var subsystems: [Subsystem] = []

    private var accumulator: Double = 0.0
    private let fixedTimeStep: Double = 1.0 / 60.0 // 60 Hz

    private var totalTime: Double = 0.0

    package init() {}

    public func getSubsystem<T: Subsystem>(ofType type: T.Type) -> T? {
        for subsystem in subsystems {
            if let typed = subsystem as? T {
                return typed
            }
        }
        return nil
    }

    package func initialize(_ initializer: ContextInitializer) {
        self.subsystems = initializer.subsystems
        self.subsystems.sort { $0.updatePriority < $1.updatePriority }
        for subsystem in subsystems {
            subsystem.initialize(self)
        }

        totalTime = 0.0
        accumulator = 0.0
    }

    package func update(_ updateTime: UpdateTime) {
        let elapsed = updateTime.elapsedTime
        totalTime = updateTime.totalTime

        // Pre-update step
        for subsystem in subsystems {
            subsystem.preUpdate(updateTime)
        }

        // Variable update step
        for subsystem in subsystems {
            subsystem.variableUpdate(updateTime)
        }

        // Fixed update step
        accumulator += elapsed
        while accumulator >= fixedTimeStep {
            let fixedUpdateTime = UpdateTime(fixedTimeStep, totalTime)
            for subsystem in subsystems {
                subsystem.fixedUpdate(fixedUpdateTime)
            }
            accumulator -= fixedTimeStep
        }

        // Post-update step
        for subsystem in subsystems {
            subsystem.postUpdate(updateTime)
        }
    }

    package func shutdown() {
        for subsystem in subsystems {
            subsystem.shutdown()
        }
    }
}