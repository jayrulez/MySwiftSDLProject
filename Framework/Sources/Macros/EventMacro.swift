import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct EventMacro: AccessorMacro, PeerMacro {
    
    // AccessorMacro implementation - provides the public subscriber interface
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            return []
        }

        let name = identifier.text
        let backingName = "_\(name)Event"
        
        // Extract the generic type from Event<T>
        /*
        let eventType: TypeSyntax
        if let typeAnnotation = binding.typeAnnotation,
           let identifierType = typeAnnotation.type.as(IdentifierTypeSyntax.self),
           identifierType.name.text == "Event",
           let genericArgs = identifierType.genericArgumentClause?.arguments.first {
            eventType = genericArgs.argument
        } else {
            eventType = TypeSyntax(stringLiteral: "Void")
        }
        */
        
        return [
            """
            get {
                if \(raw: backingName) == nil {
                    \(raw: backingName) = EventSubscriptionManager()
                }
                return \(raw: backingName)!.event
            }
            """,
            """
            set {
                // Events are read-only from outside
            }
            """
        ]
    }
    
    // PeerMacro implementation - provides the private backing storage and publisher
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            return []
        }

        let name = identifier.text
        let backingName = "_\(name)Event"
        let capitalizedName = name.prefix(1).uppercased() + name.dropFirst()
        let raiserName = "raise\(capitalizedName)"
        
        // Extract the generic type from Event<T>
        let eventType: TypeSyntax
        if let typeAnnotation = binding.typeAnnotation,
           let identifierType = typeAnnotation.type.as(IdentifierTypeSyntax.self),
           identifierType.name.text == "Event",
           let genericArgs = identifierType.genericArgumentClause?.arguments.first {
            eventType = genericArgs.argument
        } else {
            eventType = TypeSyntax(stringLiteral: "Void")
        }

        return [
            """
            private var \(raw: backingName): EventSubscriptionManager<\(eventType)>?
            """,
            """
            private func \(raw: raiserName)(_ value: \(eventType)) {
                if \(raw: backingName) == nil {
                    \(raw: backingName) = EventSubscriptionManager()
                }
                \(raw: backingName)!.raise(value)
            }
            """
        ]
    }
}