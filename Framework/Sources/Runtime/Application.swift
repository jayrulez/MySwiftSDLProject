import SedulousPlatform
import SedulousCore

import SedulousAudioSDL3
import SedulousInput
import SedulousRenderer

open class Application
{
    public private(set)var windowSystem: WindowSystem;
    public private(set)var context: Context;

    public init(_ windowSystem: WindowSystem)
    {
        self.windowSystem = windowSystem;
        self.context = Context();
    }

    open func onInitializing(_ initializer: ContextInitializer) { }
    open func onInitialized(_ context: Context) { }
    open func onShuttingDown() { }
    open func onShutdown() { }

    public func run()
    {
        // Create a window.
        guard self.windowSystem.createWindow("My SDL3 Window", 800, 600) != nil else {
            print("Failed to create window.")
            return
        }

        let initializer = ContextInitializer();

        initializer.addSubsystem(AudioSubsystemSDL3());
        initializer.addSubsystem(InputSubsystem());
        initializer.addSubsystem(RendererSubsystem());

        self.onInitializing(initializer);
        self.context.initialize(initializer);
        self.onInitialized(context);

        self.windowSystem.startMainLoop();
        while self.windowSystem.isRunning {
            self.windowSystem.runOneFrame { elapsed, total in
                context.update(UpdateTime(elapsed, total));
                //print("Running frame at time: \(elapsed) s, total time: \(total) s");
            }
        }
        self.windowSystem.stopMainLoop();
        self.onShuttingDown();
        self.context.shutdown();
        self.onShutdown();
    }
}