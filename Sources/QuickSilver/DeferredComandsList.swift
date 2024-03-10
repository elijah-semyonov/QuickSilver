import Foundation

struct DeferredComandsList<Command> {
    private let allocator: Allocator
    private var commands: [Command]
    
    init(allocator: Allocator) {
        self.allocator = allocator
        self.commands = []
    }
    
    mutating func append<Args>(_ makeCommandFromPayload: (UnsafePointer<Args>) -> Command, _ args: Args) {
        let ptr = allocator.store(args)
        let command = makeCommandFromPayload(ptr)
        commands.append(command)
    }
    
    mutating func append(_ command: Command) {
        commands.append(command)
    }
}
