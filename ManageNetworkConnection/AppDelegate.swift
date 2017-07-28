//
//  AppDelegate.swift
//  ManageNetworkConnection
//
//  Created by dev03 on 26/07/17.
//  Copyright © 2017 dev03. All rights reserved.
//

import Cocoa
import RealmSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationDidFinishLaunching(_ aNotification: Notification) {
        #if DEBUG
            print(Realm.Configuration.defaultConfiguration.fileURL!.absoluteString)
        #endif
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}


}

