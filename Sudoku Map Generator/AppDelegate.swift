//
//  AppDelegate.swift
//  Sudoku Map Generator
//
//  Created by LinO_dska on 24.01.15.
//  Copyright (c) 2015 LinO_dska. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        var pSave = File.read("Sudoku/Sudoku.map")
        if pSave == nil {
            pSave = ""
        }
        loadedCount = pSave!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) / 81
        print("Loaded \(loadedCount) maps", terminator: "")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        
        print("Saved \(count) maps", terminator: "")
        
        var pSave = File.read("Sudoku/Sudoku.map")
        if pSave == nil {
            pSave = ""
        }
        pSave? += save
        File.write("Sudoku/Sudoku.map", content: pSave!)
    }


}

