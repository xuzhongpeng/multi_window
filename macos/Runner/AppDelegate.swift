import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    lazy var project = FlutterDartProject.init()
    lazy var flutterEngine = FlutterEngine(name: "my flutter engine", project: project)

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
      flutterEngine.run(withEntrypoint: "main");
    return true
  }
}
