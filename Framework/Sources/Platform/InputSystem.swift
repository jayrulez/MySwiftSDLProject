import Foundation

public protocol InputDevice: AnyObject {
    var name: String { get }
    var isConnected: Bool { get }
    func update()
}

public protocol Mouse: InputDevice {
    var position: (x: Int, y: Int) { get }
    var delta: (dx: Int, dy: Int) { get }
    var buttons: Set<MouseButton> { get }
    func isButtonPressed(_ button: MouseButton) -> Bool
}

public protocol Keyboard: InputDevice {
    var pressedKeys: Set<KeyCode> { get }
    func isKeyPressed(_ key: KeyCode) -> Bool
}

public protocol Gamepad: InputDevice {
    var buttons: Set<GamepadButton> { get }
    var axes: [GamepadAxis: Float] { get }
    func isButtonPressed(_ button: GamepadButton) -> Bool
    func axisValue(_ axis: GamepadAxis) -> Float
}

public enum MouseButton: Int, CaseIterable {
    case left, right, middle, button4, button5
}

public enum KeyCode: Int, CaseIterable {
    case a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
    case zero, one, two, three, four, five, six, seven, eight, nine
    case escape, space, enter, tab, shift, control, alt, command
}

public enum GamepadButton: Int, CaseIterable {
    case a, b, x, y, leftShoulder, rightShoulder, back, start, guide
    case leftStick, rightStick, dpadUp, dpadDown, dpadLeft, dpadRight
}

public enum GamepadAxis: Int, CaseIterable {
    case leftX, leftY, rightX, rightY, leftTrigger, rightTrigger
}

public protocol InputSystem: AnyObject {
    var mouse: Mouse? { get }
    var keyboard: Keyboard? { get }
    var gamepads: [Gamepad] { get }
    func allDevices() -> [InputDevice]
}