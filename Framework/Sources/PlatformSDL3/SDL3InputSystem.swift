import Foundation
import SDL3
import SedulousPlatform

public class SDL3Mouse: Mouse {
    public let name = "SDL Mouse"
    public var isConnected: Bool { true }

    private(set) public var position: (x: Int, y: Int) = (0, 0)
    private(set) public var delta: (dx: Int, dy: Int) = (0, 0)
    private(set) public var buttons: Set<MouseButton> = []

    public func update() {
        var x: Float = 0, y: Float = 0
        let state = SDL_GetMouseState(&x, &y)
        let newPosition = (x: Int(x), y: Int(y))
        delta = (dx: newPosition.x - position.x, dy: newPosition.y - position.y)
        position = newPosition

        buttons.removeAll()
        
        if (state & (1 << ((SDL_BUTTON_LEFT)-1))) != 0 { buttons.insert(.left) }
        if (state & (1 << ((SDL_BUTTON_RIGHT)-1))) != 0 { buttons.insert(.right) }
        if (state & (1 << ((SDL_BUTTON_MIDDLE)-1))) != 0 { buttons.insert(.middle) }
        if (state & (1 << ((SDL_BUTTON_X1)-1))) != 0 { buttons.insert(.button4) }
        if (state & (1 << ((SDL_BUTTON_X2)-1))) != 0 { buttons.insert(.button5) }
    }

    public func isButtonPressed(_ button: MouseButton) -> Bool {
        return buttons.contains(button)
    }
}

public class SDL3Keyboard: Keyboard {
    public let name = "SDL Keyboard"
    public var isConnected: Bool { true }
    private(set) public var pressedKeys: Set<KeyCode> = []

    public func update() {
        // SDL3_GetKeyboardState returns a pointer to the current key states
        /*
        guard let statePtr = SDL_GetKeyboardState(nil) else { return }
        pressedKeys.removeAll()
        for key in KeyCode.allCases {
            let sdlScancode = SDL_Scancode(key.rawValue)
            if statePtr[Int(sdlScancode)] != 0 {
                pressedKeys.insert(key)
            }
        }*/
    }

    public func isKeyPressed(_ key: KeyCode) -> Bool {
        return pressedKeys.contains(key)
    }
}

public class SDL3Gamepad: Gamepad {
    public let name: String
    public var isConnected: Bool { true }
    private(set) public var buttons: Set<GamepadButton> = []
    private(set) public var axes: [GamepadAxis: Float] = [:]

    public init(name: String) {
        self.name = name
    }

    public func update() {
    }

    public func isButtonPressed(_ button: GamepadButton) -> Bool {
        return buttons.contains(button)
    }

    public func axisValue(_ axis: GamepadAxis) -> Float {
        return axes[axis] ?? 0.0
    }
}

public class SDL3InputSystem: InputSystem {
    public private(set) var mouse: Mouse?
    public private(set) var keyboard: Keyboard?
    public private(set) var gamepads: [Gamepad] = []

    public init() {
        self.mouse = SDL3Mouse()
        self.keyboard = SDL3Keyboard()
        // todo: setup gamepads
    }

    package func initialize(){
        
    }

    public func update() {
        mouse?.update()
        keyboard?.update()
        for gamepad in gamepads {
            gamepad.update()
        }
    }

    public func allDevices() -> [InputDevice] {
        var devices: [InputDevice] = []
        if let mouse = mouse { devices.append(mouse) }
        if let keyboard = keyboard { devices.append(keyboard) }
        devices.append(contentsOf: gamepads)
        return devices
    }
}