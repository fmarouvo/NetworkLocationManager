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
			NSAppleScript(source: "do shell script \"networksetup -createlocation AirplaneMode populate\" with administrator privileges password \"\(userData.rootPassword)\"")?.executeAndReturnError(nil)
			NSAppleScript(source: "do shell script \"networksetup -switchtolocation AirplaneMode\" with administrator privileges password \"\(userData.rootPassword)\"")?.executeAndReturnError(nil)
			NSAppleScript(source: "do shell script \"networksetup -setv4off Ethernet\" with administrator privileges password \"\(userData.rootPassword)\"")?.executeAndReturnError(nil)
			NSAppleScript(source: "do shell script \"networksetup -switchtolocation \(userData.defaultLocationName)\" with administrator privileges password \"\(userData.rootPassword)\"")?.executeAndReturnError(nil)
            try! realm.write {
                userData.hasCreated = true
                try! realm.commitWrite()
            }
        } else {
            let answer = dialogOKCancel(question: "You already create this location, do you want continue?", text: "Choose your answer.")
            if answer == true {
				NSAppleScript(source: "do shell script \"networksetup -createlocation AirplaneMode populate\" with administrator privileges password \"\(userData.rootPassword)\"")?.executeAndReturnError(nil)
				NSAppleScript(source: "do shell script \"networksetup -switchtolocation AirplaneMode\" with administrator privileges password \"\(userData.rootPassword)\"")?.executeAndReturnError(nil)
				NSAppleScript(source: "do shell script \"networksetup -setv4off Ethernet\" with administrator privileges password \"\(userData.rootPassword)\"")?.executeAndReturnError(nil)
				NSAppleScript(source: "do shell script \"networksetup -switchtolocation \(userData.defaultLocationName)\" with administrator privileges password \"\(userData.rootPassword)\"")?.executeAndReturnError(nil)
				try! realm.write {
					userData.hasCreated = true
					try! realm.commitWrite()
				}
            }
        }
    }

	@IBAction func teste(_ sender: Any) {
		print("teste")
	}
}

//MARK: - Structs
final class UserData: Object {
    dynamic var rootPassword: String = ""
    dynamic var defaultLocationName: String = "Automatic"
    dynamic var hasCreated: Bool = false
}


