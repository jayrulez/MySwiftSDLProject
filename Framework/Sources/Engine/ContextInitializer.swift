public class ContextInitializer
{
    package var subsystems: [Subsystem] = []

    public init() {}

    public func addSubsystem(_ subsystem: Subsystem) {
        if !subsystems.contains(where: { $0 === subsystem }) {
            subsystems.append(subsystem)
        }
    }
}