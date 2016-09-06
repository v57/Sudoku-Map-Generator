//
//  ViewController.swift
//  Sudoku Map Generator
//
//  Created by LinO_dska on 24.01.15.
//  Copyright (c) 2015 LinO_dska. All rights reserved.
//

import Cocoa

let cores = NSProcessInfo.processInfo().activeProcessorCount

var save = ""
var count = 0
var loadedCount = 0
let queue = NSOperationQueue()

let generator = Generator()

var solving = true

class ViewController: NSViewController {
    @IBOutlet weak var label: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //NSTimer.scheduledTimerWithTimeInterval(0.005, target: self, selector: Selector("generate"), userInfo: nil, repeats: true)
      
        
//        generator.loadMap(File.read("Sudoku/Map.map")!)
        generator.generate()
        solver.loadMap(generator, difficulty: 30)
        
        drawBackground()
        drawPen()
        drawPencil()
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("solve"), userInfo: nil, repeats: true)
    }
    func solve() {
//        if !solving {
//            return
//        }
        let a = solver.solveTurn()
        if !a {
            if solver.numberCount == 81 {
                solving = false
                restartLevel()
            } else {
                solving = false
                restartLevel()
            }
        } else {
            updatePen()
            updatePencil()
        }
    }
    func restartLevel() {
        solver.clear()
        solver.loadMap(generator, difficulty: 70)
        
    }
    @IBAction func fill(sender: AnyObject) {
        var a = 0
        for i in 0...2 {
            for j in 0...2 {
                a += solver.fill(.Chunk)
                a += solver.fill(.Vertical)
                a += solver.fill(.Horisontal)
            }
        }
        print("Filled \(a) numbers", terminator: "")
        if a > 0 {
            updatePen()
            updatePencil()
        }
    }
    @IBAction func check(sender: AnyObject) {
        solver.solve()
        updatePen()
        updatePencil()
    }
    @IBAction func restart(sender: AnyObject) {
        solving = true
        restartLevel()
    }
    @IBAction func twoWay(sender: AnyObject) {
        solver.twoWay()
        updatePen()
        updatePencil()
    }
    func generate() {
        queue.addOperationWithBlock() {
            let g = Generator()
            let a = g.generate()
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                if a {
                    count++
                    self.label.stringValue = "\(loadedCount+count)"
                    for i in 0...8 {
                        for j in 0...8 {
                            let c = Character("\(g.map2[i][j])")
                            save.append(c)
                        }
                    }
                    if count + loadedCount == 1000 {
                        print("completed", terminator: "")
                    }
                }
            }
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

class Generator {
    var map = [[[Bool]]](count: 9, repeatedValue: [[Bool]](count: 9, repeatedValue: [Bool](count: 9, repeatedValue: true)))
    var map2 = [[Int]](count: 9, repeatedValue: [Int](count: 9, repeatedValue: 0))
    var drawEnable = false
    var numberCount = 0
    func generate() -> Bool {
        for i in 0...8 {
            for j in 0...8 {
                var fail = true
                for k in 0...8 {
                    if map[i][j][k] {
                        fail = false
                        break
                    }
                }
                if fail {
                    return false
                }
                var setted = false
                while !setted {
                    setted = setNumber(i, y: j, number: Int(arc4random_uniform(9)))
                }
            }
        }
        return true
    }
    func setNumber(x: Int, y: Int, number: Int) -> Bool {
        if !map[x][y][number] {
            if drawEnable {
                print("Warn: Cannot set number \(number) at \(x),\(y)", terminator: "")
            }
            return false
        }
        let cx = x / 3 * 3
        let cy = y / 3 * 3
        for i in 0...8 {
            map[i][y][number] = false
        }
        for i in 0...8 {
            map[x][i][number] = false
        }
        for i in 0...8 { // MARK: not need in generator
            map[x][y][i] = false
        }
        for i in 0...2 {
            for j in 0...2 {
                map[cx+i][cy+j][number] = false
            }
        }
        map2[x][y] = number + 1
        numberCount++
        return true
    }
    func loadMap(string: String) {
        if string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 81 {
            fatalError("This is not valid map")
        }
        var n = 0
        var array = Array(string.characters)
        for i in 0...8 {
            for j in 0...8 {
                setNumber(i, y: j, number: Int(String(array[n]))! - 1)
                n++
            }
        }
    }
}

class Solver: Generator {
    var state = 0
    
    func clear() {
        numberCount = 0
        state = 0
        map = [[[Bool]]](count: 9, repeatedValue: [[Bool]](count: 9, repeatedValue: [Bool](count: 9, repeatedValue: true)))
        map2 = [[Int]](count: 9, repeatedValue: [Int](count: 9, repeatedValue: 0))
    }
    
    func solve () -> Bool {
        let s = false
        while !s {
        let a = solver.solveTurn()
            print("1", terminator: "")
        if !a {
            if solver.numberCount == 81 {
                return true
            } else {
                return false
            }
        }
        }
    }
    
    func solveTurn() -> Bool {
        var a = 0
        switch state {
        case 0:
            a = fill(.Chunk)
            if a == 0 {
                state = 1
            }
        case 1:
            a = fill(.Vertical)
            a += fill(.Horisontal)
            if a == 0 {
                state = 2
            }
        case 2:
            a = fill(.Chunk)
            if a == 0 {
                state = 0
                return false
            } else {
                state = 0
            }
        default:
            break
        }
        return true
    }
    
    func loadMap(generator: Generator, difficulty: Int) {
        for i in 0...difficulty-1 {
            var placed = false
            while !placed {
                let x = Int(arc4random_uniform(9))
                let y = Int(arc4random_uniform(9))
                print("\(x),\(y)")
                if map2[x][y] == 0 {
                    placed = true
                    setNumber(x, y: y, number: generator.map2[x][y]-1)
                }
            }
        }
    }
    func loadMap(solver: Solver) {
        for i in 0...8 {
            for j in 0...8 {
                if generator.map2[i][j] != 0 {
                    setNumber(i, y: j, number: generator.map2[i][j]-1)
                }
            }
        }
    }
    func fill(type: FillType) -> Int {
        var changed = 0
        var array = [Int](count: 9, repeatedValue: 0)
        var secondArray = [Int]()
        switch type {
        case .Chunk:
            for x in 0...2 {
                for y in 0...2 {
                    for i in x*3...x*3+2 {
                        for j in y*3...y*3+2 {
                            if map2[i][j] == 0 {
                                var pencilCount = 0
                                var pencilNumber = 0
                                for k in 0...8 {
                                    if map[i][j][k] {
                                        pencilCount++
                                        pencilNumber = k
                                        array[k]++
                                    }
                                }
                                if pencilCount == 1 {
                                    setNumber(i, y: j, number: pencilNumber)
                                }
                            }
                        }
                    }
                    for i in 0...8 {
                        if array[i] == 1 {
                            secondArray.append(i)
                        }
                    }
                    for i in x*3...x*3+2 {
                        for j in y*3...y*3+2 {
                            for k in secondArray {
                                if map[i][j][k] {
                                    setNumber(i, y: j, number: k)
                                    changed++
                                    break
                                }
                            }
                        }
                    }
                }
            }
        case .Horisontal:
            for x in 0...8 {
                for i in 0...8 {
                    if map2[x][i] == 0 {
                        for k in 0...8 {
                            if map[x][i][k] {
                                array[k]++
                            }
                        }
                    }
                }
                
                for i in 0...8 {
                    if array[i] == 1 {
                        secondArray.append(i)
                    }
                }
                for i in 0...8 {
                    for k in secondArray {
                        if map[x][i][k] {
                            setNumber(x, y: i, number: k)
                            changed++
                            break
                        }
                    }
                }
            }
        case .Vertical:
            for y in 0...8 {
                for i in 0...8 {
                    if map2[i][y] == 0 {
                        for k in 0...8 {
                            if map[i][y][k] {
                                array[k]++
                            }
                        }
                    }
                }
                
                for i in 0...8 {
                    if array[i] == 1 {
                        secondArray.append(i)
                    }
                }
                for i in 0...8 {
                    for k in secondArray {
                        if map[i][y][k] {
                            setNumber(i, y: y, number: k)
                            changed++
                            break
                        }
                    }
                }
            }
        }
        return changed
    }
    func twoWay() -> Bool {
        for i in 0...8 {
            for j in 0...8 {
                var count = 0
                var numbers = [Int]()
                for k in 0...8 {
                    if map[i][j][k] {
                        count++
                        numbers.append(k)
                    }
                }
                if count == 2 {
                    let solver1 = Solver()
                    solver1.loadMap(self)
                    solver1.setNumber(i, y: j, number: numbers[0])
                    let solved1 = solver1.solve()
                    let solver2 = Solver()
                    solver2.loadMap(self)
                    solver2.setNumber(i, y: j, number: numbers[0])
                    let solved2 = solver2.solve()
                    let solves = Int(solved1) + Int(solved2)
                    if solves == 1 {
                        self.clear()
                        self.loadMap(solved1 ? solver1 : solver2)
                        return true
                    } else if solves == 2 {
                        print("Two solves", terminator: "")
                        return false
                    } else {
                        return false
                    }
                }
            }
        }
        return false
    }
}

enum FillType {
    case Chunk, Vertical, Horisontal
}

