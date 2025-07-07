import SedulousEngine

public class RendererSubsystem: Subsystem {
    public init() {
        super.init("Renderer")
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