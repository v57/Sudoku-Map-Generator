//
//  Graphics.swift
//  Sudoku Map Generator
//
//  Created by Dmitry Kozlov on 05.02.15.
//  Copyright (c) 2015 LinO_dska. All rights reserved.
//

import Cocoa

// Color settings
let whiteColor = NSColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
let blueColor = NSColor(red: 0.07, green: 0.5, blue: 1.0, alpha: 1.0)
let grayColor = NSColor.lightGrayColor()
let blackColor = NSColor.blackColor()

// Table settings
let numberColor = whiteColor
let blockedNumberColor = blackColor
let pencilColor = whiteColor
let fontName = "ChalkboardSE-Regular"

let tableFirstColor = Color(red: 18, green: 127, blue: 255)
let tableSecondColor = Color(red: 38, green: 147, blue: 255)
let tableGridColor = Color(red: 247, green: 247, blue: 247)

let cellSize = 36
let cellSize3 = 12
let size = 36 * 9

class Color {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
    init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}

var solver = Solver()
var pencilLabels = [[NSTextField]]()
var penLabels = [[NSTextField]]()

extension ViewController {
    func generateAndSolve() {
        var solved = false
        while !solved {
            let generator = Generator()
            let a = generator.generate()
            if a {
                solver.drawEnable = true
                solver.loadMap(generator, difficulty: 40)
                solved = true
            }
        }
    }
    func drawBackground() {
        let uSize = size
        
        let bitmapBytesPerRow = size * 4
        let bitmapByteCount = bitmapBytesPerRow * Int(uSize)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapData = malloc(bitmapByteCount)
        let dataType = UnsafeMutablePointer<UInt8>(bitmapData)
        
        for i: Int in 0..<uSize {
            for j: Int in 0...uSize - 1 {
                let offset = 4*((Int(uSize) * j) + i)
                let line = (i % Int(cellSize) == 0 || j % Int(cellSize) == 0)
                let chunkLine = (i % Int(cellSize*3) == 1 || j % Int(cellSize*3) == 1) || i == uSize - 2 || j == uSize - 2
                let evenBlock = ((i / Int(cellSize))/3 + (j / Int(cellSize))/3) & 1 == 0
                let color: Color = line || chunkLine ? tableGridColor : evenBlock ? tableSecondColor : tableFirstColor
                
                dataType[offset]   = 255
                dataType[offset+1] = color.red
                dataType[offset+2] = color.green
                dataType[offset+3] = color.blue
            }
        }
        let context = CGBitmapContextCreate(bitmapData, uSize, uSize, 8,  bitmapBytesPerRow, colorSpace, CGImageAlphaInfo.PremultipliedFirst.rawValue)
        CGContextSetShouldAntialias(context, false)
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.None)
        let imageRef = CGBitmapContextCreateImage(context)
        
        let imageView = NSImageView(frame: NSRect(x: 0, y: 0, width: size, height: size))
        imageView.image = NSImage(CGImage: imageRef!, size: NSSize(width: size, height: size))
        view.addSubview(imageView)
    }
    func drawPencil() {
        for i in 0...26 {
            var array = [NSTextField]()
            for j in 0...26 {
                let n = ((i % 3) + 1) + 3 * (j % 3)
                
                let label = NSTextField(frame: NSRect(x: i*12, y: j*12, width: 12, height: 14))
                label.stringValue = "\(n)"
                label.hidden = !solver.map[i/3][j/3][n-1]
                
                label.bezeled = false
                label.drawsBackground = false
                label.editable = false
                label.selectable = false
                label.textColor = pencilColor
                label.alignment = .Center
                label.font = NSFont(name: "Chalkboard", size: 10)
                view.addSubview(label)
                array.append(label)
            }
            pencilLabels.append(array)
        }
    }
    func drawPen() {
        for i in 0...8 {
            var array = [NSTextField]()
            for j in 0...8 {
                let label = NSTextField(frame: NSRect(x: i*36, y: j*36, width: 36, height: 36))
                label.stringValue = solver.map2[i][j] == 0 ? "" : "\(solver.map2[i][j])"
                
                label.bezeled = false
                label.drawsBackground = false
                label.editable = false
                label.selectable = false
                label.textColor = pencilColor
                label.alignment = .Center
                label.font = NSFont(name: "Chalkboard", size: 26)
                view.addSubview(label)
                array.append(label)
            }
            penLabels.append(array)
        }
    }
    func updatePencil() {
        for i in 0...26 {
            for j in 0...26 {
                let n = ((i % 3) + 1) + 3 * (j % 3)
                pencilLabels[i][j].hidden = !solver.map[i/3][j/3][n-1]
            }
        }
    }
    func updatePen() {
        for i in 0...8 {
            for j in 0...8 {
                penLabels[i][j].stringValue = solver.map2[i][j] == 0 ? "" : "\(solver.map2[i][j])"
            }
        }
    }
}