import SedulousEngine

@MainActor
public class RendererSubsystem: Subsystem {
    private var meshResourceManager: MeshResourceManager?
    public init() {
        super.init("Renderer")
    }

    open override func onInitialize(_ context: Context) {
        super.onInitialize(context)
        meshResourceManager = MeshResourceManager()
        context.resources.addResourceManager(meshResourceManager!)
    }

    open override func onShutdown() {
        super.onShutdown()
        if let meshResourceManager = meshResourceManager {
            self.context?.resources.removeResourceManager(meshResourceManager)
            self.meshResourceManager = nil
        }
    }

    open override func onSceneAdded(_ scene: Scene) {
        super.onSceneAdded(scene)
        scene.addModule(RendererSceneModule())
    }

    open override func onSceneRemoved(_ scene: Scene) {
        super.onSceneRemoved(scene)
        scene.removeModule(ofType: RendererSceneModule.self)
    }
}