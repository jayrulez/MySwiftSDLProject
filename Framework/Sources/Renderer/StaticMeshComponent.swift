import SedulousEngine
import SedulousResources

public class StaticMeshComponent: Component
{
    public var entity: Entity?

    public var mesh: ResourceHandle<MeshResource> = .init(nil)
    public var material: MaterialResource? = nil

    public required init() {
    }
}