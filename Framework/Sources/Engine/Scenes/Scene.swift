import Foundation

public class Scene {
    public let id = UUID()
    private var modules: [SceneModule] = []

    @discardableResult
    public func addModule<T: SceneModule>(_ module: T) -> T {
        // Check if module of this type already exists
        if getModule(ofType: T.self) != nil {
            return getModule(ofType: T.self)!
        }
        
        modules.append(module)
        module.scene = self
        module.onAttached()
        
        return module
    }
    
    public func removeModule<T: SceneModule>(ofType type: T.Type) {
        if let index = modules.firstIndex(where: { $0 is T }) {
            let module = modules.remove(at: index)
            module.onDetached()
            module.scene = nil
        }
    }
    
    public func getModule<T: SceneModule>(ofType type: T.Type) -> T? {
        return modules.first { $0 is T } as? T
    }

    public func update(_ updateTime: UpdateTime) {
    }
}