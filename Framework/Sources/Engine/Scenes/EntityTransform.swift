import SedulousFoundation

public class EntityTransform {
    // Reference to the entity that owns this transform
    public weak var entity: Entity?
    public weak var parent: EntityTransform?
    
    // Private backing fields
    private var mPosition = Vector3.zero
    private var mRotation = Quaternion.identity
    private var mScale = Vector3.one
    
    // World space cached values
    private var mWorldMatrix = Matrix4x4.identity
    private var mWorldMatrixDirty = true
    private var mTransformChanged = false
    private var mLocalMatrixDirty = true
    private var mLocalMatrix = Matrix4x4.identity
    
    // MARK: - Properties with dirty tracking
    
    public var position: Vector3 {
        get { mPosition }
        set {
            if mPosition != newValue {
                mPosition = newValue
                markDirty()
            }
        }
    }
    
    public var rotation: Quaternion {
        get { mRotation }
        set {
            if mRotation != newValue {
                mRotation = newValue
                markDirty()
            }
        }
    }
    
    public var scale: Vector3 {
        get { mScale }
        set {
            if mScale != newValue {
                mScale = newValue
                markDirty()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Local transformation matrix (TRS)
    public var localMatrix: Matrix4x4 {
        if mLocalMatrixDirty {
            updateLocalMatrix()
        }
        return mLocalMatrix
    }
    
    /// World transformation matrix
    public var worldMatrix: Matrix4x4 {
        if mWorldMatrixDirty {
            updateWorldMatrix()
        }
        return mWorldMatrix
    }
    
    /// Forward vector in world space (typically -Z in right-handed systems)
    public var forward: Vector3 {
        Vector3.transform(Vector3.forward, worldRotation)
    }
    
    /// Right vector in world space (typically +X)
    public var right: Vector3 {
        Vector3.transform(Vector3.right, worldRotation)
    }
    
    /// Up vector in world space (typically +Y)
    public var up: Vector3 {
        Vector3.transform(Vector3.up, worldRotation)
    }
    
    // MARK: - World space properties
    
    public var worldPosition: Vector3 {
        let m = worldMatrix
        return Vector3(m.m41, m.m42, m.m43)
    }
    
    public var worldRotation: Quaternion {
        if let parent = parent {
            return parent.worldRotation * rotation
        }
        return rotation
    }
    
    public var worldScale: Vector3 {
        if let parent = parent {
            let parentScale = parent.worldScale
            return Vector3(
                scale.x * parentScale.x,
                scale.y * parentScale.y,
                scale.z * parentScale.z
            )
        }
        return scale
    }
    
    // MARK: - Initialization
    
    public init(entity: Entity? = nil) {
        self.entity = entity
    }
    
    // MARK: - Public Methods
    
    /// Look at a target position with optional up vector
    public func lookAt(_ target: Vector3, up: Vector3 = Vector3.up) {
        let forward = (target - worldPosition).normalized
        let right = Vector3.cross(up, forward).normalized
        let actualUp = Vector3.cross(forward, right)
        
        // Create rotation matrix (world space)
        let rotMatrix = Matrix4x4(
            right.x,    actualUp.x,    -forward.x,    0,
            right.y,    actualUp.y,    -forward.y,    0,
            right.z,    actualUp.z,    -forward.z,    0,
            0,          0,             0,             1
        )
        
        // Convert to world rotation
        let worldRot = Quaternion.createFromRotationMatrix(rotMatrix)
        
        // Convert to local rotation if we have a parent
        if let parent = parent {
            let parentWorldRot = parent.worldRotation
            rotation = parentWorldRot.conjugate * worldRot
        } else {
            rotation = worldRot
        }
    }
    
    /// Translate in local space
    public func translate(_ delta: Vector3) {
        position = position + delta
    }
    
    /// Translate in world space
    public func translateWorld(_ delta: Vector3) {
        if let parent = parent {
            // Convert world delta to local space
            let parentInverse = parent.worldRotation.conjugate
            let localDelta = Vector3.transform(delta, parentInverse)
            position = position + localDelta
        } else {
            position = position + delta
        }
    }
    
    /// Rotate around local axes (euler angles in degrees)
    public func rotate(_ eulerDegrees: Vector3) {
        let radians = Vector3(
            eulerDegrees.x * Float.pi / 180,
            eulerDegrees.y * Float.pi / 180,
            eulerDegrees.z * Float.pi / 180
        )
        
        // Create quaternion from euler angles (ZYX order)
        let deltaRotation = Quaternion.createFromEuler(radians)
        rotation = rotation * deltaRotation
    }
    
    /// Rotate around world axes
    public func rotateWorld(_ eulerDegrees: Vector3) {
        let radians = Vector3(
            eulerDegrees.x * Float.pi / 180,
            eulerDegrees.y * Float.pi / 180,
            eulerDegrees.z * Float.pi / 180
        )
        
        let deltaRotation = Quaternion.createFromEuler(radians)
        
        if let parent = parent {
            let parentInverse = parent.worldRotation.conjugate
            let localDelta = parentInverse * deltaRotation * parent.worldRotation
            rotation = rotation * localDelta
        } else {
            rotation = rotation * deltaRotation
        }
    }
    
    /// Scale uniformly
    public func scaleUniform(_ factor: Float) {
        scale = scale * factor
    }
    
    /// Reset to identity transform
    public func reset() {
        position = Vector3.zero
        rotation = Quaternion.identity
        scale = Vector3.one
    }
    
    // MARK: - Transform to/from world space
    
    /// Transform a point from local to world space
    public func transformPoint(_ localPoint: Vector3) -> Vector3 {
        let worldMat = worldMatrix
        let point4 = Vector4(localPoint, 1.0)
        let result = Matrix4x4.transform(point4, worldMat)
        return result.xyz
    }
    
    /// Transform a direction from local to world space
    public func transformDirection(_ localDirection: Vector3) -> Vector3 {
        return Vector3.transform(localDirection, worldRotation)
    }
    
    /// Transform a point from world to local space
    public func inverseTransformPoint(_ worldPoint: Vector3) -> Vector3 {
        // This would require matrix inversion - simplified implementation
        let relativePoint = worldPoint - worldPosition
        return Vector3.transform(relativePoint, worldRotation.conjugate)
    }
    
    /// Transform a direction from world to local space
    public func inverseTransformDirection(_ worldDirection: Vector3) -> Vector3 {
        return Vector3.transform(worldDirection, worldRotation.conjugate)
    }
    
    // MARK: - Internal Methods
    
    internal func updateTransform() {
        if mWorldMatrixDirty {
            updateWorldMatrix()
        }
    }
    
    internal func wasTransformChanged() -> Bool {
        return mTransformChanged
    }
    
    internal func resetChangedFlag() {
        mTransformChanged = false
    }
    
    // MARK: - Private Methods
    
    private func updateLocalMatrix() {
        mLocalMatrix = Matrix4x4.createScale(scale) *
                      Matrix4x4.createFromQuaternion(rotation) *
                      Matrix4x4.createTranslation(position)
        mLocalMatrixDirty = false
    }
    
    private func updateWorldMatrix() {
        if mLocalMatrixDirty {
            updateLocalMatrix()
        }
        
        if let parent = parent {
            mWorldMatrix = localMatrix * parent.worldMatrix
        } else {
            mWorldMatrix = localMatrix
        }
        
        mWorldMatrixDirty = false
    }
    
    private func markDirty() {
        mWorldMatrixDirty = true
        mLocalMatrixDirty = true
        mTransformChanged = true
        
        // Mark all children as dirty recursively
        if let entity = entity {
            for child in entity.children {
                child.transform.markDirty()
            }
        }
    }
}