import SedulousEngine

public class StaticMeshComponent: Component
{
    public var entity: Entity?

    public var mesh: StaticMeshResource? = nil
    public var material: MaterialResource? = nil

    public required init() {
    }
}