//
//  MyViewController.swift
//  Runner
//
//  Created by admin on 2022/3/13.
//

import Cocoa

@available(macOS 10.12, *)
class MyViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let button1 = NSButton(title: "close", target: self, action: #selector(click1))
        button1.setButtonType(.momentaryPushIn)
        button1.frame = NSRect(x: 18, y: 200, width: 70, height: 25)
        self.view.addSubview(button1)
    }
    @objc private func click1(_ sender: NSButton) {
        print("哈哈哈")
    }
}
