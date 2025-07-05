import SDL3
import SedulousPlatform

public class SDL3Window : Window {

public private(set) var id: UInt32;

    private var window: OpaquePointer?;

    public init?(_ title: String, _ width: UInt32, _ height: UInt32) {
        self.id = 0;
        self.window = nil;

        //super.init();

        // Create the SDL window.
        self.window = SDL_CreateWindow(title, Int32(width), Int32(height), SDL_WindowFlags(0));
        if self.window == nil {
            return nil;
            //fatalError("Failed to create SDL window: \(String(cString: SDL_GetError()))");
        }

        // Get the window ID.
        self.id = SDL_GetWindowID(self.window);
    }

    deinit {
        if let window = self.window {
            SDL_DestroyWindow(window);
            self.window = nil;
        }
    }
}