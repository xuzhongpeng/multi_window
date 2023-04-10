import Foundation
import FlutterMacOS

public class MyFlutterViewController: FlutterViewController, NSWindowDelegate {
    var key: String = "main"

    open override func viewWillAppear() {
        let window = view.window
        window!.delegate = self
            
        if #available(macOS 10.12, *) {
            let button1 = NSButton(title: StaticSource.message, target: self, action: #selector(click1))
            button1.setButtonType(.momentaryPushIn)
            button1.frame = NSRect(x: 18, y: 200, width: 70, height: 25)
            self.view.addSubview(button1)
        } else {
            // Fallback on earlier versions
        }
       
        super.viewWillAppear()
        // self.engine;
    }
    @objc private func click1(_ sender: NSButton) {
//        mainWC?.close()
    }

    public func windowWillClose(_ notification: Notification) {
//        emit([
//            "event": "windowClose"
//        ])
//
//        for (eventKey, _) in MultiWindowMacosPlugin.multiEventSinks {
//            if eventKey.starts(with: "\(key)/") {
//                MultiWindowMacosPlugin.multiEventSinks.removeValue(forKey: eventKey)
//            }
//        }
    }

    private func emit(_ data: Any?) {
//        MultiWindowMacosPlugin.emitEvent(key, key, "system", data: data)
    }
}
