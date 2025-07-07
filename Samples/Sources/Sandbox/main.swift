import SedulousRuntime
import SedulousPlatform
import SedulousPlatformSDL3
import SedulousEngine
import SedulousRenderer
import SedulousFoundation

class SandboxApplication: Application {
    var scene: Scene? = nil

    override init(_ windowSystem: WindowSystem) {
        super.init(windowSystem)
    }

    override func onInitializing(_ initializer: ContextInitializer) {
    }
    
    override func onInitialized(_ context: Context) {
        scene = Scene()
        if let scene: Scene = scene {
        
            context.scenes.addScene(scene)

            let camera: Entity = scene.createEntity(name: "Camera")
            camera.addComponent(CameraComponent.self)
            camera.transform.position = Vector3(0, 0, -5)

            let player: Entity = scene.createEntity(name: "Player")
            let meshComponent = player.addComponent(StaticMeshComponent.self)
            meshComponent.mesh = StaticMeshResource()
            meshComponent.material = nil

            camera.transform.lookAt(player.transform.position)
        }
    }
    
    override func onShuttingDown() {
        if let scene = scene {
            context.scenes.removeScene(scene)
            self.scene = nil
        }
    }
    
    override func onShutdown() {
    }
}

var windowSystem: WindowSystem = SDL3WindowSystem()
let app = SandboxApplication(windowSystem)
app.run()