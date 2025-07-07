import SedulousEngine

public class RendererSubsystem: Subsystem {
    public init() {
        super.init("Renderer")
    }

    override func onSceneAdded(_ scene: Scene) {
        super.onSceneAdded(scene)
        scene.addModule(RendererSceneModule())
    }

    override func onSceneRemoved(_ scene: Scene) {
        super.onSceneRemoved(scene)
        scene.removeModule(RendererSceneModule.self)
    }
}