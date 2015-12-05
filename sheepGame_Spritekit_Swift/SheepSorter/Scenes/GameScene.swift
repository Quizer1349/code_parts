//
//  GameScene.swift
//  SheepSorter
//
//  Created by Alex Sklyarenko on 19.11.15.
//  Copyright (c) 2015 Alex Sklyarenko. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Nodes
    let background = BackgroundNode(imageNamed: TextureFileName.Background)

    let leftGate = LeftGatesNode(position: CGPointMake(124, 100))
    let rightGate = RightGatesNode(position:  CGPointMake(196, 100))
    
    let fence = FenceNode()
    
    let scoreLabel = ScoreLabelNode()
    
    // MARK: - Data
    let gameSettings = GameSettings.sharedInstance
    
    // MARK: - Scene vars
    var leftTouch:UITouch?;
    var rightTouch:UITouch?;

    private var touchPosition: CGFloat = 0
    private var targetZRotation: CGFloat = 0
    
    var scoreValue:Int = 0;

    private lazy var popSoundAction = SKAction.playSoundFileNamed(SoundFileName.Pop, waitForCompletion: false)
    private lazy var failSoundAction = SKAction.playSoundFileNamed(SoundFileName.Explosion, waitForCompletion: false)
    
    
    // MARK: - Init
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

        
    override func didMoveToView(view: SKView) {

        self.setupScene()
        
        // Background
        addChild(background)

        //Fence
        addChild(fence)
        
        //Finishes
        addChild(LeftFinishLineNode())
        addChild(CenterFinishLineNode())
        addChild(RightFinishLineNode())
        
        //Gates
        addGatesToFence()
        
        //HUD
        addChild(scoreLabel)
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(createSheep),
                SKAction.waitForDuration(3.0)])))
    }
    
    
    func addGatesToFence(){
        
        addChild(leftGate)
        
        addChild(rightGate)
    }
    
    
    func setupScene(){
        
        backgroundColor = UIColor(hexString: ColorHex.BackgroundColor)
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
    }

    
    func createSheep(){
    
        let startPoint = CGPointMake(160, 588)
        let sheep = SheepNode(sheepType: SheepType.randomSheepType(), position: startPoint)

        self.addChild(sheep)
    }
    
    
    func destroySheep(sheep : SKNode){
        
        print("Sheep destroyed")
        let destroyAction = SKAction.removeFromParentAfterDelay(1)
        sheep.runAction(destroyAction)
        
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
       
        if(self.leftTouch != nil && touches.contains(self.leftTouch!)){
        
            let leftGateVector = CGVectorMake((self.leftTouch!.locationInNode(self).x - self.leftTouch!.previousLocationInNode(self).x) * 20, (self.leftTouch!.locationInNode(self).y - self.leftTouch!.previousLocationInNode(self).y) * CGFloat(gameSettings.getControlSensitivity()))
            
            leftGate.physicsBody!.velocity = leftGateVector
        }
        
        if(self.rightTouch != nil && touches.contains(self.rightTouch!)){
            
            let rightGateVector = CGVectorMake((self.rightTouch!.locationInNode(self).x - self.rightTouch!.previousLocationInNode(self).x) * 20, (self.rightTouch!.locationInNode(self).y - self.rightTouch!.previousLocationInNode(self).y) * CGFloat(gameSettings.getControlSensitivity()))
            
            rightGate.physicsBody!.velocity = rightGateVector
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       
        if(self.leftTouch != nil && self.rightTouch != nil){
        
            return;
        }
        
        for obj in touches {
            
            let touch = obj as UITouch
            let location = touch.locationInNode(self.background)
            let screenMedian = UIScreen.mainScreen().bounds.width / 2
            
            switch location.x{
            
            case 0...screenMedian:
                self.leftTouch = touch
                
            default:
                self.rightTouch = touch
            }
        }
        
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if(self.leftTouch != nil && touches.contains(self.leftTouch!)){
            
            self.leftTouch = nil
        }
        
        if(self.rightTouch != nil && touches.contains(self.rightTouch!)){
            
            self.rightTouch = nil
        }
    }
   
    
    func sheepGotFinishWithContact(contact: SKPhysicsContact, finish:SheepType){
    
        if let sheep = nodeInContact(contact, withCategoryBitMask: PhysicsCategory.Sheep) as? SheepNode {
            
            if(sheep.sheepType == finish){
            
                self.scoreValue++
                scoreLabel.text = "\(self.scoreValue)"
                runAction(popSoundAction, when: isSoundEnabled())
            }else{
                
                runAction(failSoundAction, when: isSoundEnabled())
            }
            
            self.destroySheep(sheep);
        }
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch collision {
        case PhysicsCategory.Sheep | PhysicsCategory.LeftFinish:

            sheepGotFinishWithContact(contact, finish:.Left)
            print("Left Finish")
            
        case PhysicsCategory.Sheep | PhysicsCategory.CenterFinish:
            
            sheepGotFinishWithContact(contact, finish:.Center)
            print("Center Finish")
            
        case PhysicsCategory.Sheep | PhysicsCategory.RightFinish:
            
            sheepGotFinishWithContact(contact, finish:.Right)
            print("Right Finish")
            
        case PhysicsCategory.Sheep | PhysicsCategory.RightGate:
            
            print("Sheep to Right Gate")
            
            if let sheep = nodeInContact(contact, withCategoryBitMask: PhysicsCategory.Sheep) as? SKSpriteNode {
                
                //print(contact.collisionImpulse)
                /*...*/
            }
            
        case PhysicsCategory.Sheep | PhysicsCategory.LeftGate:
            
            print("Sheep to Left Gate")

            if let sheep = nodeInContact(contact, withCategoryBitMask: PhysicsCategory.Sheep) as? SKSpriteNode {

                /*...*/

            }
            
        case PhysicsCategory.Sheep | PhysicsCategory.Fence:
            
            print("Sheep to Fence")
            
        case PhysicsCategory.LeftGate | PhysicsCategory.Fence:
            
            //print("Left to Fence")
            let currentVector = leftGate.physicsBody!.velocity
            leftGate.physicsBody!.velocity = CGVectorMake(-currentVector.dx / 10, -currentVector.dy / 10)
            
        case PhysicsCategory.RightGate | PhysicsCategory.Fence:
            
            //print("Right to Fence")
            let currentVector = leftGate.physicsBody!.velocity
            rightGate.physicsBody!.velocity = CGVectorMake(-currentVector.dx / 10, -currentVector.dy / 10)
            
        case PhysicsCategory.LeftGate | PhysicsCategory.RightGate:
           
            //print("Left to Right")
            leftGate.physicsBody!.velocity = leftGate.physicsBody!.velocity.normalized()
            rightGate.physicsBody!.velocity = rightGate.physicsBody!.velocity.normalized()
           
        default:
            break
        }
    }

    
    func didEndContact(contact: SKPhysicsContact) {
       
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch collision {
        
        case PhysicsCategory.Sheep | PhysicsCategory.LeftGate:
            if let sheep = nodeInContact(contact, withCategoryBitMask: PhysicsCategory.Sheep) as? SKSpriteNode {
                /*...*/

            }
            
        default:
            break
        }
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        
        if(leftTouch == nil){
            leftGate.physicsBody!.velocity = leftGate.physicsBody!.velocity.normalized()
        }
        
        if(rightTouch == nil){
            rightGate.physicsBody!.velocity = rightGate.physicsBody!.velocity.normalized()
        }
        
        
        self.enumerateChildNodesWithName("Sheep") {(sheep, stop) in
            
            var velocity = sheep.physicsBody!.velocity
            
            if (sheep.zRotation.radiansToDegrees() > 50 || sheep.zRotation.radiansToDegrees() < -50){
                let defAngle:CGFloat = 0
                
                let rotateToGoAction = SKAction.rotateToAngle(defAngle.degreesToRadians(), duration: 0.5, shortestUnitArc: true)

                sheep.runAction(rotateToGoAction)
                
            }
            
            if sheep.physicsBody!.velocity.length() > 0 {
                sheep.rotateToVelocity(CGVectorMake(-sheep.physicsBody!.velocity.dx, -sheep.physicsBody!.velocity.dy), rate:0.2)
            }
            
            let wiatAction = SKAction.waitForDuration(0.3)
            let runAgainAction = SKAction.applyImpulse(CGVector(dx:0, dy:-0.1), duration: 5)
            let commonAction = SKAction.sequence([wiatAction, runAgainAction])
            sheep.runAction(commonAction)
            
        }
    }
    
    
    override func didSimulatePhysics() {
        
    }
}
