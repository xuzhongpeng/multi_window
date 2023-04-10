import Cocoa
import FlutterMacOS

@available(macOS 10.12, *)
class MainFlutterWindow: NSWindow {
    
    override func awakeFromNib() {
        let windowFrame = self.frame
        let flutterEngine = (NSApplication.shared.delegate as! AppDelegate).flutterEngine
        let flutterViewController = FlutterViewController.init(engine: flutterEngine, nibName: nil, bundle: nil)
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        
        RegisterGeneratedPlugins(registry: flutterViewController)
        
        let button = NSButton(title: "新建窗口", target: self, action: #selector(click))
        button.setButtonType(.momentaryPushIn)
        button.frame = NSRect(x: 18, y: 100, width: 70, height: 25)
        flutterViewController.view.addSubview(button)
        
        let button1 = NSButton(title: "close", target: self, action: #selector(click1))
        button1.setButtonType(.momentaryPushIn)
        button1.frame = NSRect(x: 18, y: 200, width: 70, height: 25)
        flutterViewController.view.addSubview(button1)
        
        super.awakeFromNib()
    }
    var mainWC: NSWindowController?
    @objc private func click(_ sender: NSButton) {
        print("click button")
        let project = FlutterDartProject.init()
        let key = "secondWindow"
        StaticSource.message = "噗欻"
        project.dartEntrypointArguments = [key]
        
        
        let controller = MyFlutterViewController.init(engine: (NSApplication.shared.delegate as! AppDelegate).flutterEngine, nibName: nil, bundle: nil)
        
//        controller.key = key
        RegisterGeneratedPlugins(registry: controller)
        
        
        
//        let viewC = MyViewController.init(nibName: "MyViewController", bundle: Bundle.main)
        let window = NSWindow(contentViewController: controller)
//        var frame = window.frame
//        frame = NSRect(origin: frame.origin, size: CGSize(width: 300, height: 300))
        window.setFrame(CGRect(x: 10, y: 10, width: 550, height: 650), display: true)
//        controller.view.frame = frame
        mainWC = NSWindowController(window: window)
        //        // 创建窗口，关联控制器
        mainWC?.showWindow(nil)
    }
    
    @objc private func click1(_ sender: NSButton) {
        mainWC?.close()
    }
}
