//
//  ViewController.swift
//  ManageNetworkConnection
//
//  Created by dev03 on 26/07/17.
//  Copyright © 2017 dev03. All rights reserved.
//

import Cocoa
import RealmSwift
import CoreFoundation

class ViewController: NSViewController {

    let realm = try! Realm()

    @IBOutlet weak var rootPassword: NSTextField!
    @IBOutlet weak var defaultLocationName: NSTextField!
    
	@IBOutlet weak var toggleButton: NSButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}
    
    override func viewWillAppear() {
        super.viewWillAppear()
        guard let userData = getUserData() else { return }
        guard let rootPassword = rootPassword, let defaultLocationName = defaultLocationName else { return }
        rootPassword.stringValue = userData.rootPassword 
        defaultLocationName.stringValue = userData.defaultLocationName 
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
	
	func shellBash(launchPath: String, arguments: [String]) -> String
	{
		let task = Process()
		task.launchPath = launchPath
		task.arguments = arguments
		
		let pipe = Pipe()
		task.standardOutput = pipe
		task.launch()
		
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let output = String(data: data, encoding: String.Encoding.utf8)!
		if output.characters.count > 0 {
			//remove newline character.
			let lastIndex = output.index(before: output.endIndex)
			return output[output.startIndex ..< lastIndex]
		}
		return output
	}
	
	func bash(command: String, arguments: [String]) -> String {
		let whichPathForCommand = shellBash(launchPath: "/usr/bin/env", arguments: ["\(command)" ])
		return shellBash(launchPath: whichPathForCommand, arguments: arguments)
	}
	
    private func getUserData() -> UserData? {
        guard let user = realm.objects(UserData.self).first else {
            return nil
        }
        return user
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        let alert: NSAlert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = NSAlertStyle.warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        let res = alert.runModal()
        if res == NSAlertFirstButtonReturn {
            return true
        }
        return false
    }
    
    @IBAction func buttonSaveTapped(button: NSButton) {
        print(rootPassword.stringValue)
        if rootPassword.stringValue != "" && defaultLocationName.stringValue != "" {
            let userData = getUserData()
            if userData != nil {
                try! realm.write {
                    userData?.rootPassword = rootPassword.stringValue
                    userData?.defaultLocationName = defaultLocationName.stringValue
                    try! realm.commitWrite()
                }
            } else {
                let userData = UserData()
                userData.rootPassword = rootPassword.stringValue
                userData.defaultLocationName = defaultLocationName.stringValue
                try! realm.write {
                    realm.add(userData)
                    try! realm.commitWrite()
                }
            }
        } else {
            let alert = NSAlert.init()
            alert.messageText = "Should you fill the fields"
            alert.informativeText = "Please, do it!"
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    @IBAction func buttonTapped(button: NSButton) {
        guard let userData = getUserData() else { return }
        if userData.hasCreated == true {
            if button.state == NSOnState {
				NSAppleScript(source: "do shell script \"networksetup -switchtolocation \(userData.defaultLocationName)\" with administrator privileges password \"\(userData.rootPassword)\"")?.executeAndReturnError(nil)
            } else {
                NSAppleScript(source: "do shell script \"networksetup -switchtolocation AirplaneMode\" with administrator privileges password \"\(userData.rootPassword)\"")?.executeAndReturnError(nil)
            }
        } else {
            let alert = NSAlert.init()
            alert.messageText = "Should you add AirplanMode before change network status."
            alert.informativeText = "Please, do it!"
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    @IBAction func buttonModeTapped(button: NSButton) {
        guard let userData = getUserData() else { return }
        if userData.hasCreated == false {
            shell("sudo", "-S", "<<<", "\(userData.rootPassword)", "networksetup", "-createlocation", "AirplaneMode", "populate")
            shell("sudo", "-S", "<<<", "\(userData.rootPassword)", "networksetup", "-switchtolocation", "AirplaneMode")
            shell("sudo", "-S", "<<<", "\(userData.rootPassword)", "networksetup", "-setv4off", "Ethernet")
            shell("sudo", "-S", "<<<", "\(userData.rootPassword)", "networksetup", "-switchtolocation", "\(userData.defaultLocationName)")
            try! realm.write {
                userData.hasCreated = true
                try! realm.commitWrite()
            }
        } else {
            let answer = dialogOKCancel(question: "You already create this location, do you want continue?", text: "Choose your answer.")
            if answer == true {
                shell("sudo", "-S", "<<<", "\(userData.rootPassword)", "networksetup", "-createlocation", "AirplaneMode", "populate")
                shell("sudo", "-S", "<<<", "\(userData.rootPassword)", "networksetup", "-switchtolocation", "AirplaneMode")
                shell("sudo", "-S", "<<<", "\(userData.rootPassword)", "networksetup", "-setv4off", "Ethernet")
                shell("sudo", "-S", "<<<", "\(userData.rootPassword)", "networksetup", "-switchtolocation", "\(userData.defaultLocationName)")
                try! realm.write {
                    userData.hasCreated = true
                    try! realm.commitWrite()
                }
            }
        }
    }

}

//MARK: - Structs
final class UserData: Object {
    dynamic var rootPassword: String = ""
    dynamic var defaultLocationName: String = "Automatic"
    dynamic var hasCreated: Bool = false
}


