@attached(accessor)
@attached(peer, names: prefixed(_), arbitrary)
public macro Event() = #externalMacro(module: "SedulousMacros", type: "EventMacro")