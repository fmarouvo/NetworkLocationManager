//
//  ViewController.swift
//  ManageNetworkConnection
//
//  Created by dev03 on 26/07/17.
//  Copyright © 2017 dev03. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	@IBOutlet weak var toggleButton: NSButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	@discardableResult
	func shell(_ args: String...) -> Int32 {
		let task = Process()
		task.launchPath = "/usr/bin/env"
		task.arguments = args
		task.launch()
		task.waitUntilExit()
		return task.terminationStatus
	}
	
	@IBAction func buttonTapped(button: NSButton) {
		if button.state == NSOnState {
			shell("networksetup", "-switchtolocation", "Automatic")
		} else {
			shell("networksetup", "-switchtolocation", "AirplaneMode")
		}
	}

}

