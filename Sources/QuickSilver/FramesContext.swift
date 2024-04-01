import Foundation
import Metal

public final class FramesContext {
    let sharedEvent: MTLSharedEvent
    
    private let instance: Instance
    private let sharedEventDispatchQueue = DispatchQueue(label: "com.quicksilver.sharedEventDispatchQueue")
    private var currentSignalValue: UInt64 = 0
    private let sharedEventListener: MTLSharedEventListener
    
    init(instance: Instance) {
        self.instance = instance
        
        guard let sharedEvent = instance.device.makeSharedEvent() else {
            fatalError()
        }
        self.sharedEvent = sharedEvent
        
        sharedEventListener = MTLSharedEventListener(dispatchQueue: sharedEventDispatchQueue)
    }
    
    func invoke(atSignalValue value: UInt64, _ closure: @escaping () -> UInt64?) {
        sharedEvent.notify(sharedEventListener, atValue: value) { event, value in
            if let newValue = closure() {
                event.signaledValue = max(newValue, value)
            }
        }
    }
    
    func updateSignalValue(to value: UInt64) {
        sharedEvent.signaledValue = max(sharedEvent.signaledValue, value)
    }
    
    func nextSignalValue() -> UInt64 {
        currentSignalValue += 1
        return currentSignalValue
    }
    
    public func executeFrame(_ closure: (Frame) -> Void) async {
        let frame = Frame(instance: instance, framesContext: self)
        
        closure(frame)
        
        await frame.execute()
    }
}
