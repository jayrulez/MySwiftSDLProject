import Foundation
import SedulousPlatform
import SDL3

public class SDL3WindowSystem: WindowSystem {

    public private(set)var isRunning: Bool = false
    public private(set)var primaryWindow: Window?

    public private(set)var inputSystem: InputSystem = SDL3InputSystem()

    private var startTime: DispatchTime = .now()
    private var lastFrameTime: DispatchTime = .now()

    public init() {
        self.primaryWindow = nil
    }

    public func createWindow(_ title: String, _ width: UInt32, _ height: UInt32) -> Window? {
        let window = SDL3Window(title, width, height)
        if let window = window, self.primaryWindow == nil {
            self.primaryWindow = window
        }
        return window
    }

    private static let eventFilter: @convention(c) (
        UnsafeMutableRawPointer?, UnsafeMutablePointer<SDL_Event>?
    ) -> Bool = { userdata, event in
        guard let userdata = userdata else { return true }
        
        let instance = Unmanaged<SDL3WindowSystem>.fromOpaque(userdata).takeUnretainedValue()
        
        if let event = event {
            print("Event type: \(event.pointee.type)")
        }
        // Return true to allow event, false to filter it out
        return true
    }

    public func startMainLoop() {
        isRunning = true
        
        startTime = .now()
        lastFrameTime = startTime

        let pointer = Unmanaged.passUnretained(self).toOpaque()
        SDL_SetEventFilter(SDL3WindowSystem.eventFilter, pointer)

        SDL_PumpEvents();
    }

    public func stopMainLoop() {
        SDL_SetEventFilter(nil, nil)

        isRunning = false
    }

    public func runOneFrame(_ callback: FrameCallback) {
        var event = SDL_Event()
        while SDL_PollEvent(&event) {
            let eventType = SDL_EventType(Int32(event.type))

            switch eventType {
            case SDL_EVENT_QUIT:
                isRunning = false
                return
            default:
                break
            }
        }

        let now = DispatchTime.now()
        let elapsed = Double(now.uptimeNanoseconds - lastFrameTime.uptimeNanoseconds) / 1_000_000_000
        let total = Double(now.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        lastFrameTime = now
        callback(elapsed, total)
    }

    public func requestExit() {
        isRunning = false
    }
}