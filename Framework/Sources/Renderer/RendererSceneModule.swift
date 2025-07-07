import SedulousEngine

public class RendererSceneModule: SceneModule {
    public override var name: String {
        return "Renderer"
    }

    private var meshes: [StaticMeshComponent] = []

    open override func onAttached(to scene: Scene) {
        super.onAttached(to: scene)
    }

    open override func onDetached() {
        super.onDetached()
    }
}