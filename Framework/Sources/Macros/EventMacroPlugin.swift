import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct EventMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EventMacro.self
    ]
}