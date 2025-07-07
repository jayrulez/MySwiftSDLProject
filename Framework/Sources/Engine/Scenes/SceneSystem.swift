import SedulousFoundation
import Foundation

public class SceneSystem {
    @Event public var onSceneAdded: Event<Scene>
    @Event public var onSceneRemoved: Event<Scene>
    
    private var scenes: [UUID: Scene] = [:]
    private var activeScenes: [Scene] = []

    internal init() {
    }

    internal func startup() {
    }

    internal func shutdown() {
        // Clean up all scenes
        for scene in scenes.values {
            removeScene(scene)
        }
        scenes.removeAll()
        activeScenes.removeAll()
    }

    internal func update(_ updateTime: UpdateTime) {
        for scene in activeScenes {
            scene.update(updateTime)
        }
    }
    
    // MARK: - Scene Management
    
    /// Add a new scene to the system
    public func addScene(_ scene: Scene) {
        scenes[scene.id] = scene
        raiseOnSceneAdded(scene)
    }
    
    /// Remove a scene from the system
    public func removeScene(_ scene: Scene) {
        scenes.removeValue(forKey: scene.id)
        activeScenes.removeAll { $0.id == scene.id }
        raiseOnSceneRemoved(scene)
    }
    
    /// Remove scene by ID
    public func removeScene(id: UUID) {
        if let scene = scenes[id] {
            removeScene(scene)
        }
    }
}