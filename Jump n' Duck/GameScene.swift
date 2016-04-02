//
//  GameScene.swift
//  Jump n' Duck
//
//  Created by Daniel Theobald on 1/21/16.
//  Copyright (c) 2016 Daniel Theobald. All rights reserved.
//

import SpriteKit

func myRandom(min: Int, max: Int) -> CGFloat {
    return CGFloat(arc4random_uniform(UInt32(max - min)) + UInt32(min))
}

enum BodyType: UInt32
{
    case sprite1 = 1
    case sprite2 = 2
    case sprite3 = 4
    case sprite4 = 8
    case lane1 = 16
    case lane2 = 32
    case lane3 = 64
    case lane4 = 128
    case duckbox1 = 256
    case jumpbox1 = 512
    case duckbox2 = 1024
    case jumpbox2 = 2048
    case duckbox3 = 4096
    case jumpbox3 = 8192
    case duckbox4 = 16384
    case jumpbox4 = 32768
}

class Player {
    var sprite: SKSpriteNode!
    
    var runningAnim: [SKTexture]!
    
    var alive: Bool = true
    var inAir: Bool = true
    var inDuck: Bool = false
    var damaged: Bool = false
    
    var lane: Int = 0
    var knockbackPos: Int = 0
    
    var duckTimer: Double = 0.0
    var damageTimer: Double = 0.0
    
    init(sceneframe: CGRect, newLane: Int)
    {
        // animation setup
        let runningAnimatedAtlas = SKTextureAtlas(named: "running_5")
        var walkFrames = [SKTexture]()
        
        let numImages = runningAnimatedAtlas.textureNames.count
        for var i = 0; i < numImages; i++
        {
            let bearTextureName = "running_" + String(i)
            walkFrames.append(runningAnimatedAtlas.textureNamed(bearTextureName))
        }
        
        runningAnim = walkFrames
        
        // collision setup
        let spriteCol = SKPhysicsBody(rectangleOfSize: (runningAnim.first?.size())!)
        switch(newLane)
        {
        case 0:
            spriteCol.categoryBitMask = BodyType.sprite1.rawValue
            spriteCol.contactTestBitMask = BodyType.lane1.rawValue | BodyType.jumpbox1.rawValue | BodyType.duckbox1.rawValue
            spriteCol.collisionBitMask = BodyType.lane1.rawValue
            break
        case 1:
            spriteCol.categoryBitMask = BodyType.sprite2.rawValue
            spriteCol.contactTestBitMask = BodyType.lane2.rawValue | BodyType.jumpbox2.rawValue | BodyType.duckbox2.rawValue
            spriteCol.collisionBitMask = BodyType.lane2.rawValue
            break
        case 2:
            spriteCol.categoryBitMask = BodyType.sprite3.rawValue
            spriteCol.contactTestBitMask = BodyType.lane3.rawValue | BodyType.jumpbox3.rawValue | BodyType.duckbox3.rawValue
            spriteCol.collisionBitMask = BodyType.lane3.rawValue
            break
        case 3:
            spriteCol.categoryBitMask = BodyType.sprite4.rawValue
            spriteCol.contactTestBitMask = BodyType.lane4.rawValue | BodyType.jumpbox4.rawValue | BodyType.duckbox4.rawValue
            spriteCol.collisionBitMask = BodyType.lane4.rawValue
            break
        default:
            print("player collision setup: switch index wrong")
            break
        }
        sprite = SKSpriteNode(texture: runningAnim.first)
        sprite.position = CGPoint(x: CGRectGetMaxX(sceneframe) * 0.6, y: CGRectGetMidY(sceneframe))
        sprite.physicsBody = spriteCol
        
        
        sprite.runAction(SKAction.scaleBy(1.75, duration: 0.0))
        
        lane = newLane
        
        sprite.name = "sprite_" + String(lane)
    }
    
    init(newSprite: SKSpriteNode, newCollidable: SKPhysicsBody, newAnim: [SKTexture], newLane: Int)
    {
        lane = newLane
        runningAnim = newAnim
        sprite = newSprite
        sprite.physicsBody = newCollidable
    }
    
    func getCollidable() -> SKPhysicsBody
    {
        return sprite.physicsBody!
    }
    
    func runningAnimation()
    {
        sprite.runAction(SKAction.repeatActionForever(
            SKAction.animateWithTextures(runningAnim,
                timePerFrame: 0.1,
                resize: false,
                restore: true)),
            withKey:"runningAnimation")
    }
    
    func jumpingAnimation()
    {
        sprite.removeActionForKey("runningAnimation")
        sprite.texture = runningAnim.first
    }
    
    func duckingAnimation()
    {
        sprite.removeActionForKey("runningAnimation")
        sprite.texture = runningAnim.last
    }
    
    func damageAnimation()
    {
        let blink = SKAction.sequence([SKAction.hide(), SKAction.waitForDuration(0.15), SKAction.unhide(), SKAction.waitForDuration(0.15)])
        sprite.runAction(SKAction.repeatAction(blink, count: 2))
    }
    
    func damage(KBD: CGFloat)
    {
        damageAnimation()
        switch(lane)
        {
        case 0:
            sprite.physicsBody?.contactTestBitMask = BodyType.lane1.rawValue
            break
        case 1:
            sprite.physicsBody?.contactTestBitMask = BodyType.lane2.rawValue
            break
        case 2:
            sprite.physicsBody?.contactTestBitMask = BodyType.lane3.rawValue
            break
        case 3:
            sprite.physicsBody?.contactTestBitMask = BodyType.lane4.rawValue
            break
        default:
            print("func damage: wrong lane")
            break
        }
        
        damaged = true
        knockbackPos++
        sprite.runAction(SKAction.moveByX(KBD, y: 0.0, duration: 0.3))
        damageAnimation()
        damageTimer = 0.0
    }
    
    func endDamage()
    {
        damaged = false
        damageTimer = 0.0
        switch(lane)
        {
        case 0:
            sprite.physicsBody?.contactTestBitMask = BodyType.lane1.rawValue | BodyType.duckbox1.rawValue | BodyType.jumpbox1.rawValue
            break
        case 1:
            sprite.physicsBody?.contactTestBitMask = BodyType.lane2.rawValue | BodyType.duckbox2.rawValue | BodyType.jumpbox2.rawValue
            break
        case 2:
            sprite.physicsBody?.contactTestBitMask = BodyType.lane3.rawValue | BodyType.duckbox3.rawValue | BodyType.jumpbox3.rawValue
            break
        case 3:
            sprite.physicsBody?.contactTestBitMask = BodyType.lane4.rawValue | BodyType.duckbox4.rawValue | BodyType.jumpbox4.rawValue
            break
        default:
            print("func endDamage: wrong lane")
            break
        }
        runningAnimation()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var colSize: CGSize!
    struct Box
    {
        var shape: SKShapeNode
        var lane: Int = 0
        
        init()
        {
            shape = SKShapeNode(rectOfSize: CGSize(width: 0, height: 0))
        }
        
        init(newShape: SKShapeNode)
        {
            shape = newShape
        }
    }
    var boxes: [Box]!
    var boxDist = 400
    var knockbackDist = 0
    
    var boxSpeed: Double = 400.0
    
    var duckSequence: SKAction!
    var jumpSequence: SKAction!
    
    var floorLanes: [SKShapeNode]!
    var floorCol: SKPhysicsBody!
    
    let jumpVel = 1000.0
    var jumpDecay = 1.0
    var jumpHeld = false
    
    var lastUpdateTimeInterval: Double = 0.0
    
    var baseY: CGFloat = 0.0
    
    var beginTimer: Double = 5.0
    var deltaStartTimer: Double = 0.0
    var start: Bool = false
    var startShapeIndex: Int = 4
    
    // start timer textures
    var startShapes: [SKSpriteNode]!
    
    // screen lines
    var screenLines: [SKShapeNode]!
    var screenLineButton: SKShapeNode!
    var screenLineOption: ScreenLineOptions!
    var optionIndex: Int = 0
    struct ScreenLineOptions : OptionSetType {
        let rawValue: Int
        static let count = 9
        
        static let None       = ScreenLineOptions(rawValue: 0)
        static let Mid_X = ScreenLineOptions(rawValue: 1 << 0)
        static let Mid_Y = ScreenLineOptions(rawValue: 1 << 1)
        static let OF_X  = ScreenLineOptions(rawValue: 1 << 2)
        static let OF_Y  = ScreenLineOptions(rawValue: 1 << 3)
        static let TF_X  = ScreenLineOptions(rawValue: 1 << 4)
        static let TF_Y  = ScreenLineOptions(rawValue: 1 << 5)
        
        // Aux values
        static let upperBoxLine  = ScreenLineOptions(rawValue: 1 << 6)
        static let lowerBoxLine  = ScreenLineOptions(rawValue: 1 << 7)
    }
    
    func ActivateScreenLines(SLO: ScreenLineOptions)
    {
        let Lengthwise = CGSize(width: CGRectGetMaxX(self.frame), height: 10)
        let HeightWise = CGSize(width: 10, height: CGRectGetMaxY(self.frame))
        let color = SKColor.yellowColor()
        
        let midx = CGRectGetMidX(self.frame)
        let midy = CGRectGetMidY(self.frame)
        
        if(screenLines.count != 0)
        {
            self.removeChildrenInArray(screenLines)
        }
        
        screenLines = []
        
        if( SLO.contains(ScreenLineOptions.None) )
        {
            //return
        }
        if( SLO.contains(ScreenLineOptions.Mid_X) )
        {
            let line = SKShapeNode(rectOfSize: Lengthwise)
            line.fillColor = color
            line.position = CGPoint(x: midx, y: midy)
            screenLines.append(line)
        }
        if( SLO.contains(ScreenLineOptions.Mid_Y) )
        {
            let line = SKShapeNode(rectOfSize: HeightWise)
            line.fillColor = color
            line.position = CGPoint(x: midx, y: midy)
            screenLines.append(line)
        }
        if( SLO.contains(ScreenLineOptions.OF_X) )
        {
            let line = SKShapeNode(rectOfSize: Lengthwise)
            line.fillColor = color
            line.position = CGPoint(x: midx, y: midy * 1.5)
            screenLines.append(line)
        }
        if( SLO.contains(ScreenLineOptions.OF_Y) )
        {
            let line = SKShapeNode(rectOfSize: HeightWise)
            line.fillColor = color
            line.position = CGPoint(x: midx * 0.5, y: midy)
            screenLines.append(line)
        }
        if( SLO.contains(ScreenLineOptions.TF_X) )
        {
            let line = SKShapeNode(rectOfSize: Lengthwise)
            line.fillColor = color
            line.position = CGPoint(x: midx, y: midy * 0.5)
            screenLines.append(line)
        }
        if( SLO.contains(ScreenLineOptions.TF_Y) )
        {
            let line = SKShapeNode(rectOfSize: HeightWise)
            line.fillColor = color
            line.position = CGPoint(x: midx * 1.5, y: midy)
            screenLines.append(line)
        }
        if( SLO.contains(ScreenLineOptions.upperBoxLine) )
        {
            let line = SKShapeNode(rectOfSize: Lengthwise)
            line.fillColor = SKColor.whiteColor()
            line.position = CGPoint(x: midx, y: midy + 250)
            screenLines.append(line)
        }
        if( SLO.contains(ScreenLineOptions.lowerBoxLine) )
        {
            let line = SKShapeNode(rectOfSize: Lengthwise)
            line.fillColor = SKColor.whiteColor()
            line.position = CGPoint(x: midx, y: midy + 150)
            screenLines.append(line)
        }
        
        for line in screenLines
        {
            self.addChild(line)
        }
    }
    
    // sprites
    var sprites: [Player]!
    
    
    
    override func didMoveToView(view: SKView) {
        
        physicsWorld.contactDelegate = self
        baseY = CGRectGetMidY(self.frame) - 75
        knockbackDist = Int(CGRectGetMaxX(self.frame) * 0.1)
        
        
        /* Setup your scene here */
        
        /*topBox = SKShapeNode(rectOfSize: colSize)
        topBox.name = "topBox"
        topBox.fillColor = SKColor.whiteColor()
        topBox.position = CGPoint(x: CGRectGetMidX(self.frame) + (CGRectGetMidX(self.frame) * 0.5), y: CGRectGetMidY(self.frame))
        
        topCol = SKPhysicsBody(rectangleOfSize: colSize)
        topCol.affectedByGravity = false
        topCol.categoryBitMask = BodyType.topBox.rawValue
        topCol.contactTestBitMask = BodyType.sprite1.rawValue | BodyType.sprite2.rawValue | BodyType.sprite3.rawValue | BodyType.sprite4.rawValue
        topCol.collisionBitMask = 0
        
        topBox.physicsBody = topCol*/
        floorLanes = []
        for var index = 0; index < 4; index++
        {
            let floor = SKShapeNode(rectOfSize: CGSize(width: CGRectGetMaxX(self.frame), height: 10))
            floor.name = "lane_" + String("index")
            floor.fillColor = SKColor(colorLiteralRed: 0.1, green: Float(0.6 + (Double(index) * 0.1)), blue: 0.1, alpha: 1.0)
            floor.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGFloat(baseY) + CGFloat(50 * index))
            
            floorCol = SKPhysicsBody(rectangleOfSize: CGSize(width: CGRectGetMaxX(self.frame), height: 10))
            floorCol.affectedByGravity = false
            floorCol.dynamic = false
            switch(index)
            {
            case 0:
                floorCol.categoryBitMask = BodyType.lane1.rawValue
                floorCol.contactTestBitMask = BodyType.sprite1.rawValue
                floorCol.collisionBitMask = BodyType.sprite1.rawValue
                break
            case 1:
                floorCol.categoryBitMask = BodyType.lane2.rawValue
                floorCol.contactTestBitMask = BodyType.sprite2.rawValue
                floorCol.collisionBitMask = BodyType.sprite2.rawValue
                break
            case 2:
                floorCol.categoryBitMask = BodyType.lane3.rawValue
                floorCol.contactTestBitMask = BodyType.sprite3.rawValue
                floorCol.collisionBitMask = BodyType.sprite3.rawValue
                break
            case 3:
                floorCol.categoryBitMask = BodyType.lane4.rawValue
                floorCol.contactTestBitMask = BodyType.sprite4.rawValue
                floorCol.collisionBitMask = BodyType.sprite4.rawValue
                break
            default:
                print("lane creation index wrong")
                break
            }
            floor.physicsBody = floorCol
            
            self.addChild(floor)
        }
        
        let Left = SKShapeNode(rectOfSize: CGSize(width: CGRectGetMidX(self.frame), height: CGRectGetMidY(self.frame)))
        Left.name = "Left"
        Left.fillColor = SKColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.3)
        Left.position = CGPoint(x: CGRectGetMidX(self.frame)*0.5, y: CGRectGetMidY(self.frame)*0.5)
        
        self.addChild(Left)
        
        let Right = SKShapeNode(rectOfSize: CGSize(width: CGRectGetMidX(self.frame), height: CGRectGetMidY(self.frame)))
        Right.name = "Right"
        Right.fillColor = SKColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.3)
        Right.position = CGPoint(x: CGRectGetMidX(self.frame)*1.5, y: CGRectGetMidY(self.frame)*0.5)
        
        self.addChild(Right)
        
        let SLB = SKShapeNode(rectOfSize: CGSize(width: CGRectGetMidX(self.frame)*0.15, height: CGRectGetMidY(self.frame) * 0.15))
        SLB.name = "ScreenLineButton"
        SLB.fillColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
        SLB.position = CGPoint(x: CGRectGetMidX(self.frame)*0.3, y: CGRectGetMidY(self.frame)*1.7)
        
        //self.addChild(SLB)
        screenLineOption = ScreenLineOptions.None
        screenLines = []
        ActivateScreenLines(screenLineOption)
        
        // duck sequence : USLESS NOW
        var scaleDown = SKAction.scaleYTo(0.45, duration: 0.1)
        var waitDown = SKAction.waitForDuration(0.1)
        let scaleUp = SKAction.scaleYTo(1.0, duration: 0.2)
        
        duckSequence = SKAction.sequence([scaleDown, waitDown, scaleUp])
        
        scaleDown = SKAction.scaleYTo(0.75, duration: 0.2)
        waitDown = SKAction.waitForDuration(0.2)
        
        jumpSequence = SKAction.sequence([scaleDown, waitDown, scaleUp])
        
        
        // box setup
        boxes = []
        colSize = CGSize(width: 60, height: 20)
        
        for var i = 0; i < 4; i++
        {
            for var j = 0; j < 4; j++
            {
                var box = Box(newShape: SKShapeNode(rectOfSize: colSize))
                box.shape.name = "box_l" + String(i+1) + "_" + String(j+1)
                box.shape.position = CGPoint(x: (CGRectGetMaxX(self.frame) * 0.6) - CGFloat(i * 30) + CGFloat(j * boxDist), y: (baseY + CGFloat(50 * i)))
                box.shape.fillColor = SKColor(colorLiteralRed: 0.2 + (Float(i) * 0.2), green: 0.2, blue: 0.2 + (Float(i) * 0.2), alpha: 1.0)
                box.lane = i
                let boxcol = SKPhysicsBody(rectangleOfSize: colSize)
                boxcol.affectedByGravity = false
                boxcol.dynamic = false
                boxcol.contactTestBitMask = 0//BodyType.sprite1.rawValue | BodyType.sprite2.rawValue | BodyType.sprite3.rawValue | BodyType.sprite4.rawValue
                boxcol.collisionBitMask = 0
                switch(i)
                {
                case 0:
                    boxcol.categoryBitMask = BodyType.jumpbox1.rawValue
                    break
                case 1:
                    boxcol.categoryBitMask = BodyType.jumpbox2.rawValue
                    break
                case 2:
                    boxcol.categoryBitMask = BodyType.jumpbox3.rawValue
                    break
                case 3:
                    boxcol.categoryBitMask = BodyType.jumpbox4.rawValue
                    break
                default:
                    print("box setup: wrong index")
                    break
                }
                box.shape.physicsBody = boxcol
                boxes.append(box)
                
                self.addChild(box.shape)
            }
        }


        // player setup
        sprites = []
        for var index = 0; index < 4; index++
        {
            let newsprite = Player(sceneframe: self.frame, newLane: index)
            newsprite.sprite.position.x -= CGFloat(30 * index)
            newsprite.sprite.position.y += CGFloat(70 * index)
            sprites.append(newsprite)
            self.addChild(newsprite.sprite)
        }
        
        startShapes = []
        for var i = 0; i < 5; i++
        {
            let newshape = SKSpriteNode(imageNamed: String(i+1) + ".png")
            newshape.name = "Start_Shape_" + String(i+1)
            newshape.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
            startShapes.append(newshape)
        }
        
        startShapes[3].runAction(SKAction.scaleBy(0.5, duration: 0.0))
        
        // add five for start timer
        self.addChild(startShapes[4])
    }
    
    
    
    func boxMovement(deltaTime: CFTimeInterval)
    {
        // TODO: make boxes move in groups based on lanes so that the rand change affects each lane at the same time
        
        //   L1 L2 L3 L4
        // B1 0  4  8 12
        // B2 1  5  9 13
        // B3 2  6 10 14
        // B4 3  7 11 15
        
        // rand == 0 jumpBox
        // else      duckBox
        
        if(boxes.count == 0)
        {
            return
        }
        
        let deltaVel = CGFloat(boxSpeed * deltaTime)
        
        //B1
        for (var firstCounter = 1, laneIndex = 0; laneIndex <= 15; firstCounter++, laneIndex += 4)
        {
            if(boxes[laneIndex].shape.name?.lowercaseString.rangeOfString("l" + String(firstCounter)) == nil)
            {
                print("boxMovement B1 wrong box updated: laneIndex = " + String(laneIndex))
            }
            
            boxes[laneIndex].shape.position.x -= deltaVel
            if(laneIndex == 12)
            {
                if(boxes[laneIndex].shape.position.x <= 30)
                {
                    // reset set of boxes
                    let rand = myRandom(0, max: 2)
                    let resetDist = CGFloat(boxDist * 4)
                    for (var counter = 0, boxIndex = 0; boxIndex <= 15; counter++, boxIndex += 4)
                    {
                        boxes[boxIndex].shape.position.x += resetDist
                        if(rand == 0)
                        {
                            boxes[boxIndex].shape.position.y = baseY + CGFloat(60 * counter)
                            boxes[boxIndex].shape.fillColor = SKColor.purpleColor()
                            switch(boxes[boxIndex].lane)
                            {
                            case 0:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox1.rawValue
                                break
                            case 1:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox2.rawValue
                                break
                            case 2:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox3.rawValue
                                break
                            case 3:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox4.rawValue
                                break
                            default:
                                print("boxMovement B1 jumpBox switch out of range")
                                break
                            }
                        }
                        else
                        {
                            boxes[boxIndex].shape.position.y = baseY + CGFloat(60 * counter) + 80
                            boxes[boxIndex].shape.fillColor = SKColor.brownColor()
                            switch(boxes[boxIndex].lane)
                            {
                            case 0:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox1.rawValue
                                break
                            case 1:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox2.rawValue
                                break
                            case 2:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox3.rawValue
                                break
                            case 3:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox4.rawValue
                                break
                            default:
                                print("boxMovement B1 duckBox switch out of range")
                                break
                            }
                        }
                    }
                }
            }
        }
        
        //B2
        for (var firstCounter = 1, laneIndex = 1; laneIndex <= 15; firstCounter++, laneIndex += 4)
        {
            if(boxes[laneIndex].shape.name?.lowercaseString.rangeOfString("l" + String(firstCounter)) == nil)
            {
                print("boxMovement B2 wrong box updated: laneIndex = " + String(laneIndex))
            }
            
            boxes[laneIndex].shape.position.x -= deltaVel
            if(laneIndex == 13)
            {
                if(boxes[laneIndex].shape.position.x <= 30)
                {
                    // reset set of boxes
                    let rand = myRandom(0, max: 2)
                    let resetDist = CGFloat(boxDist * 4)
                    for (var counter = 0, boxIndex = 1; boxIndex <= 15; counter++, boxIndex += 4)
                    {
                        boxes[boxIndex].shape.position.x += resetDist
                        if(rand == 0)
                        {
                            boxes[boxIndex].shape.position.y = baseY + CGFloat(60 * counter)
                            boxes[boxIndex].shape.fillColor = SKColor.purpleColor()
                            switch(boxes[boxIndex].lane)
                            {
                            case 0:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox1.rawValue
                                break
                            case 1:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox2.rawValue
                                break
                            case 2:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox3.rawValue
                                break
                            case 3:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox4.rawValue
                                break
                            default:
                                print("boxMovement B2 jumpBox switch out of range")
                                break
                            }
                        }
                        else
                        {
                            boxes[boxIndex].shape.position.y = baseY + CGFloat(60 * counter) + 80
                            boxes[boxIndex].shape.fillColor = SKColor.brownColor()
                            switch(boxes[boxIndex].lane)
                            {
                            case 0:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox1.rawValue
                                break
                            case 1:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox2.rawValue
                                break
                            case 2:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox3.rawValue
                                break
                            case 3:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox4.rawValue
                                break
                            default:
                                print("boxMovement B2 duckBox switch out of range")
                                break
                            }
                        }
                    }
                }
            }
        }
        
        //B3
        for (var firstCounter = 1, laneIndex = 2; laneIndex <= 15; firstCounter++, laneIndex += 4)
        {
            if(boxes[laneIndex].shape.name?.lowercaseString.rangeOfString("l" + String(firstCounter)) == nil)
            {
                print("boxMovement B3 wrong box updated: laneIndex = " + String(laneIndex))
            }
            
            boxes[laneIndex].shape.position.x -= deltaVel
            if(laneIndex == 14)
            {
                if(boxes[laneIndex].shape.position.x <= 30)
                {
                    // reset set of boxes
                    let rand = myRandom(0, max: 2)
                    let resetDist = CGFloat(boxDist * 4)
                    for (var counter = 0, boxIndex = 2; boxIndex <= 15; counter++, boxIndex += 4)
                    {
                        boxes[boxIndex].shape.position.x += resetDist
                        if(rand == 0)
                        {
                            boxes[boxIndex].shape.position.y = baseY + CGFloat(60 * counter)
                            boxes[boxIndex].shape.fillColor = SKColor.purpleColor()
                            switch(boxes[boxIndex].lane)
                            {
                            case 0:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox1.rawValue
                                break
                            case 1:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox2.rawValue
                                break
                            case 2:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox3.rawValue
                                break
                            case 3:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox4.rawValue
                                break
                            default:
                                print("boxMovement B3 jumpBox switch out of range")
                                break
                            }
                        }
                        else
                        {
                            boxes[boxIndex].shape.position.y = baseY + CGFloat(60 * counter) + 80
                            boxes[boxIndex].shape.fillColor = SKColor.brownColor()
                            switch(boxes[boxIndex].lane)
                            {
                            case 0:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox1.rawValue
                                break
                            case 1:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox2.rawValue
                                break
                            case 2:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox3.rawValue
                                break
                            case 3:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox4.rawValue
                                break
                            default:
                                print("boxMovement B3 duckBox switch out of range")
                                break
                            }
                        }
                    }
                }
            }
        }
        
        //B4
        for (var firstCounter = 1, laneIndex = 3; laneIndex <= 15; firstCounter++, laneIndex += 4)
        {
            if(boxes[laneIndex].shape.name?.lowercaseString.rangeOfString("l" + String(firstCounter)) == nil)
            {
                print("boxMovement B4 wrong box updated: laneIndex = " + String(laneIndex))
            }
            
            boxes[laneIndex].shape.position.x -= deltaVel
            if(laneIndex == 15)
            {
                if(boxes[laneIndex].shape.position.x <= 30)
                {
                    // reset set of boxes
                    let rand = myRandom(0, max: 2)
                    let resetDist = CGFloat(boxDist * 4)
                    for (var counter = 0, boxIndex = 3; boxIndex <= 15; counter++, boxIndex += 4)
                    {
                        boxes[boxIndex].shape.position.x += resetDist
                        if(rand == 0)
                        {
                            boxes[boxIndex].shape.position.y = baseY + CGFloat(60 * counter)
                            boxes[boxIndex].shape.fillColor = SKColor.purpleColor()
                            switch(boxes[boxIndex].lane)
                            {
                            case 0:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox1.rawValue
                                break
                            case 1:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox2.rawValue
                                break
                            case 2:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox3.rawValue
                                break
                            case 3:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.jumpbox4.rawValue
                                break
                            default:
                                print("boxMovement B4 jumpBox switch out of range")
                                break
                            }
                        }
                        else
                        {
                            boxes[boxIndex].shape.position.y = baseY + CGFloat(60 * counter) + 80
                            boxes[boxIndex].shape.fillColor = SKColor.brownColor()
                            switch(boxes[boxIndex].lane)
                            {
                            case 0:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox1.rawValue
                                break
                            case 1:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox2.rawValue
                                break
                            case 2:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox3.rawValue
                                break
                            case 3:
                                boxes[boxIndex].shape.physicsBody?.categoryBitMask = BodyType.duckbox4.rawValue
                                break
                            default:
                                print("boxMovement B4 duckBox switch out of range")
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            // get touch location
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if(node.name == nil)
            {
                return
            }
            
            //let midX = CGRectGetMidX(self.frame)
            //let midY = CGRectGetMidY(self.frame)
            
            //var Red = CGFloat(0.0)
            //var Green = CGFloat(0.0)
            //var Blue = CGFloat(0.0)
            //let Alpha = CGFloat(1.0)
            
            let sprite = sprites.first
            
            switch(node.name!)
            {
            case "bar":
                
                break
            case "Left":
                // duck
                if(sprite!.inAir == false)
                {
                    //barra.runAction(duckSequence)
                    sprite!.duckingAnimation()
                    sprite!.inDuck = true
                    
                    print("duck hit")
                }
                break
            case "Right":
                // jump
                if(sprite!.inAir == false)
                {
                    //_sprite.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
                    sprite!.getCollidable().velocity.dy = CGFloat(jumpVel)
                    sprite!.jumpingAnimation()
                    sprite!.inAir = true
                    jumpHeld = true
                    jumpDecay = 1.0
                }
                break
            case "ScreenLineButton":
                self.optionIndex++
                //let check1 = ScreenLineOptions.count
                //let check = self.optionIndex
                if(self.optionIndex >= ScreenLineOptions.count)
                {
                    optionIndex = 0
                    screenLineOption = ScreenLineOptions.None
                }
                else
                {
                    var mask = 0
                    for index in 0...optionIndex-1
                    {
                        mask += (1<<index)
                    }
                    screenLineOption = ScreenLineOptions(rawValue: mask)
                }
                ActivateScreenLines(screenLineOption)
                break
            default:
                break
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        for touch in touches {
            // get touch location
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if(node.name == nil)
            {
                return
            }
            
            let sprite = sprites.first
            
            switch(node.name!)
            {
            case "left":
                // duck
                break
            case "right":
                // jump
                if(sprite!.getCollidable().velocity.dy > 0.0)
                {
                    sprite!.getCollidable().velocity.dy = CGFloat(0)
                }
                jumpHeld = false
                break
            default:
                
                break
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        var deltaTime: CFTimeInterval = currentTime - lastUpdateTimeInterval
        
        lastUpdateTimeInterval = currentTime
        
        if (deltaTime > 1.0)
        {
            deltaTime = 0.0167
        }
        
        if(start == false)
        {
            beginTimer -= deltaTime
            deltaStartTimer += deltaTime
            if(deltaStartTimer >= 1.0)
            {
                deltaStartTimer = 0.0
                startShapes[startShapeIndex].removeFromParent()
                startShapeIndex = Int(beginTimer)
                self.addChild(startShapes[startShapeIndex])
            }
        }
        if(beginTimer <= 0.0)
        {
            startShapes[startShapeIndex].removeFromParent()
            start = true
        }
        
        boxMovement(deltaTime)
        
        let sprite = sprites.first
        
        if(sprite!.inDuck == true)
        {
            sprite!.duckTimer += deltaTime
            
            if(sprite!.duckTimer >= 0.5)
            {
                sprite!.inDuck = false
                sprite!.duckTimer = 0.0
                
                sprite!.runningAnimation()
            }
        }
        if(sprite!.inAir == true && jumpHeld == true)
        {
            sprite!.getCollidable().velocity.dy -= CGFloat((jumpVel*jumpDecay) * deltaTime)
            //jumpDecay -= 0.001 * deltaTime
            if(jumpDecay <= 0.0)
            {
                jumpDecay = 0.0
            }
        }
        if(sprite!.damaged)
        {
            sprite!.damageTimer += deltaTime
            if(sprite!.damageTimer >= 0.3)
            {
                sprite!.endDamage()
            }
        }
        if(sprite!.knockbackPos >= 5)
        {
            if(sprite!.alive == true)
            {
                sprite!.alive = false
                sprite!.getCollidable().collisionBitMask = 0
                sprite!.getCollidable().applyImpulse(CGVector(dx: 0.0, dy: 100))
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        //this gets called automatically when two objects begin contact with each other
        
        var spriteMask = UInt32.max
        if((contact.bodyA.node!.name?.lowercaseString.rangeOfString("sprite")) != nil)
        {
            spriteMask = contact.bodyA.categoryBitMask
        }
        else if((contact.bodyB.node!.name?.lowercaseString.rangeOfString("sprite")) != nil)
        {
            spriteMask = contact.bodyB.categoryBitMask
        }
        
        var boxMask = UInt32.max
        if((contact.bodyA.node!.name?.lowercaseString.rangeOfString("box")) != nil ||
            (contact.bodyA.node!.name?.lowercaseString.rangeOfString("lane")) != nil)
        {
            boxMask = contact.bodyA.categoryBitMask
        }
        else if((contact.bodyB.node!.name?.lowercaseString.rangeOfString("box")) != nil ||
            (contact.bodyB.node!.name?.lowercaseString.rangeOfString("lane")) != nil)
        {
            boxMask = contact.bodyB.categoryBitMask
        }
    
        switch(spriteMask)
        {
        case BodyType.sprite1.rawValue:
            let sprite = sprites[0]
            switch(boxMask)
            {
            case BodyType.lane1.rawValue:
                //either the contactMask was the sprite type or the ground type
                //print("contact made: sprite1 & ground")
                if(sprite.inAir == true)
                {
                    sprite.inAir = false
                    jumpHeld = false
                    jumpDecay = 1.0
                    sprite.runningAnimation()
                }
                break
            case BodyType.duckbox1.rawValue:
                if(start == false)
                {
                    break
                }
                
                if(sprite.damaged == false && sprite.inDuck == false)
                {
                    sprite.damage(CGFloat(-knockbackDist))
                }
                break
            case BodyType.jumpbox1.rawValue:
                if(start == false)
                {
                    break
                }
                
                if(sprite.damaged == false && sprite.inAir == false)
                {
                    sprite.damage(CGFloat(-knockbackDist))
                }
                break
            default:
                print("collision switch index wrong: sprite1")
                return
            }
            break
        case BodyType.sprite2.rawValue:
            let sprite = sprites[1]
            switch(boxMask)
            {
            case BodyType.lane2.rawValue:
                //either the contactMask was the sprite type or the ground type
                //print("contact made: sprite2 & ground")
                if(sprite.inAir == true)
                {
                    sprite.inAir = false
                    jumpHeld = false
                    jumpDecay = 1.0
                    sprite.runningAnimation()
                }
                break
            case BodyType.duckbox2.rawValue:
                if(start == false)
                {
                    break
                }
                
                if(sprite.damaged == false && sprite.inDuck == false)
                {
                    sprite.damage(CGFloat(-knockbackDist))
                }
                break
            case BodyType.jumpbox2.rawValue:
                if(start == false)
                {
                    break
                }
                
                if(sprite.damaged == false && sprite.inAir == false)
                {
                    sprite.damage(CGFloat(-knockbackDist))
                }
                break
            default:
                print("collision switch index wrong: sprite2")
                return
            }
            break
        case BodyType.sprite3.rawValue:
            let sprite = sprites[2]
            switch(boxMask)
            {
            case BodyType.lane3.rawValue:
                //either the contactMask was the sprite type or the ground type
                //print("contact made: sprite3 & ground")
                if(sprite.inAir == true)
                {
                    sprite.inAir = false
                    jumpHeld = false
                    jumpDecay = 1.0
                    sprite.runningAnimation()
                }
                break
            case BodyType.duckbox3.rawValue:
                if(start == false)
                {
                    break
                }
                
                if(sprite.damaged == false && sprite.inDuck == false)
                {
                    sprite.damage(CGFloat(-knockbackDist))
                }
                break
            case BodyType.jumpbox3.rawValue:
                if(start == false)
                {
                    break
                }
                
                if(sprite.damaged == false && sprite.inAir == false)
                {
                    sprite.damage(CGFloat(-knockbackDist))
                }
                break
            default:
                print("collision switch index wrong: sprite3")
                return
            }
        case BodyType.sprite4.rawValue:
            let sprite = sprites[3]
            switch(boxMask)
            {
            case BodyType.lane4.rawValue:
                //either the contactMask was the sprite type or the ground type
                //print("contact made: sprite4 & ground")
                if(sprite.inAir == true)
                {
                    sprite.inAir = false
                    jumpHeld = false
                    jumpDecay = 1.0
                    sprite.runningAnimation()
                }
                break
            case BodyType.duckbox4.rawValue:
                if(start == false)
                {
                    break
                }
                
                if(sprite.damaged == false && sprite.inDuck == false)
                {
                    sprite.damage(CGFloat(-knockbackDist))
                }
                break
            case BodyType.jumpbox4.rawValue:
                if(start == false)
                {
                    break
                }
            
                if(sprite.damaged == false && sprite.inAir == false)
                {
                    sprite.damage(CGFloat(-knockbackDist))
                }
                break
            default:
                print("collision switch index wrong: sprite4")
                return
            }
            break
        default:
            print("collision switch index wrong: initial mask")
            break
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
        //this gets called automatically when two objects end contact with each other
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch(contactMask) {
        case BodyType.sprite1.rawValue | BodyType.lane1.rawValue:
            //either the contactMask was the bro type or the ground type
            print("contact ended: sprite1 & ground")
            
        default:
            return
            
        }
        
    }
}
