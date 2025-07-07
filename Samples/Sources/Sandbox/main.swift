import SedulousRuntime
import SedulousPlatform
import SedulousPlatformSDL3
import SedulousEngine

class SandboxApplication: Application {
    init(_ windowSystem: WindowSystem) {
        super.init(windowSystem)
    }

    override func onInitializing(_ initializer: ContextInitializer) {
    }
    
    override func onInitialized(_ context: Context) {
    }
    
    override func onShuttingDown() {
    }
    
    override func onShutdown() {
    }
}

var windowSystem: WindowSystem = SDL3WindowSystem()
let app = SandboxApplication(windowSystem)
app.run()