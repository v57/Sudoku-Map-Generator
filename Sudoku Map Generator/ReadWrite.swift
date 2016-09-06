//
//  ReadWrite.swift
//  Life engine
//
//  Created by Dmitry Kozlov on 11/09/14.
//  Copyright (c) 2014 Dmitry Kozlov. All rights reserved.
//

import Foundation

//class File {
//    
//    class func exists (path: String) -> Bool {
//        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//        let p = paths.stringByAppendingPathComponent(path)
//        return NSFileManager().fileExistsAtPath(p)
//    }
//    
//    class func read (path: String) -> String? {
//        if File.exists(path) {
//            var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//            var p = paths.stringByAppendingPathComponent(path)
//            return String(contentsOfFile: p, encoding: NSUTF8StringEncoding, error: nil)
//        }
//        
//        return nil
//    }
//    
//    class func write (path: String, content: String) -> Bool {
//        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//        var p = paths.stringByAppendingPathComponent(path)
//        return content.writeToFile(p, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
//    }
//    class func readSysPlist(path: String) -> NSDictionary? {
//        let p = NSBundle.mainBundle().pathForResource(path, ofType: "plist")
//        return NSDictionary(contentsOfFile: p!)
//    }
//    class func readPlist(path: String) -> NSMutableDictionary? {
//        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//        let p = paths.stringByAppendingPathComponent(path + ".plist")
//        return NSMutableDictionary(contentsOfFile: p)
//    }
//    class func writePlist(path: String, data: NSDictionary?) {
//        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//        var p = paths.stringByAppendingPathComponent(path + ".plist")
//        var fileManager = NSFileManager.defaultManager()
//        if (!fileManager.fileExistsAtPath(p)) {
//            fileManager.copyItemAtPath(path + ".plist", toPath: p, error:nil)
//        }
//        data?.writeToFile(p, atomically: true)
//    }
//    class func createDirectory(path: String) {
//        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//        let p = paths.stringByAppendingPathComponent(path)
//        print("created \(p)")
//        NSFileManager.defaultManager().createDirectoryAtPath(p, withIntermediateDirectories: true, attributes: nil, error: nil)
//    }
//}
class File {
  class func exists (path: String) -> Bool {
    return NSFileManager().fileExistsAtPath(path)
  }
  class func read (path: String) -> String? {
    return try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
  }
  class func write (path: String, content: String) -> Bool {
    if exists(path) {
      print("Writed: \(path)")
    } else {
      print("Created: \(path)")
    }
    do {
      try content.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
      return true
    } catch {
      return false
    }
  }
  class func readSysPlist(path: String) -> NSDictionary? {
    let p = NSBundle.mainBundle().pathForResource(path, ofType: "plist")
    return NSDictionary(contentsOfFile: p!)
  }
  class func readPlist(path: String) -> NSMutableDictionary? {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let p = (paths as NSString).stringByAppendingPathComponent(path)
    return NSMutableDictionary(contentsOfFile: p)
  }
  class func writePlist(path: String, data: NSDictionary?) {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let p = (paths as NSString).stringByAppendingPathComponent(path)
    let fileManager = NSFileManager.defaultManager()
    if (!fileManager.fileExistsAtPath(p)) {
      do {
        try fileManager.copyItemAtPath(path, toPath: p)
      } catch {
        
      }
    }
    data?.writeToFile(p, atomically: true)
  }
  class func createDirectory(path: String) {
    if exists(path) {
      print("Writed: \(path)")
    } else {
      print("Created: \(path)")
    }
    do {
      try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
    } catch {}
    
  }
}