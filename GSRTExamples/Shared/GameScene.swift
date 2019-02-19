//
//  GameScene.swift
//  GameSparksSample
//
//  Created by Benjamin Schulz on 19/01/17.
//  Copyright © 2017 GameSparks. All rights reserved.
//

import SpriteKit

#if os(watchOS)
    import WatchKit
    // <rdar://problem/26756207> SKColor typealias does not seem to be exposed on watchOS SpriteKit
    typealias SKColor = UIColor
#endif

class GameScene: SKScene, IRTSessionListener {
    func onPlayerConnect(_ peerId: NSNumber) {
        NSLog("onPlayerConnect: " + String(peerId as Int));
    }

    func onPlayerDisconnect(_ peerId: NSNumber) {
        NSLog("onPlayerDisconnect: " + String(peerId as Int));
    }

    func onReady(_ ready: Bool) {
        NSLog("onReady: " + String(ready));
    }

    func onPacket(_ packet: RTPacket) {
        NSLog("onPacket: " + String(describing:packet) + ", payload = " + String(data:packet.getPayload()!, encoding: .utf8)!)

        if(packet.getOpCode() == 42)
        {
            if let spinny = self.spinnyNode?.copy() as! SKShapeNode? {
                if let data = packet.getData()
                {
                    spinny.position.x = data.getFloat(1)! as CGFloat
                    spinny.position.y = data.getFloat(2)! as CGFloat

                    spinny.strokeColor = SKColor(
                            red:data.getFloat(3)! as CGFloat,
                            green:data.getFloat(4)! as CGFloat,
                            blue:data.getFloat(5)! as CGFloat,
                            alpha: 1.0
                    )
                    self.addChild(spinny)
                }
            }
        }
    }


    fileprivate var label : SKLabelNode?
    fileprivate var spinnyNode : SKShapeNode?

    var session1 : IRTSession?;
    var session2 : IRTSession?;

    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }

    var TOKEN_1 = "tl/qb9Oe6ePbGcLolHD7y/uIer/ilctWhpf3beM8sh4zRaX9+XBAYQC/uo6R2ULn/yByGTF3egBmkKKtp7VSH15Ml1t0UcUoO69qih6Hu2O7d7rEtDW8fybuaq07zhFA/+v0cxIJp6uso5txDA+CN87soJ0TscyIYPmIc6mLFIISjjoCVQe4QbmybU0fBz44vgKBlc5X4hlbnD5HJECEO+ucKR33XcF0cbKqlJWHy8oMApOzL7D3zhrm3ShyZnM/Z2PK/9gkc7iw5TusO14vY24nGdtsfwCNa9DLFCW+qqBDZ5qI+nbWByIaz2sj4G2ilb8NCW2t0uTAZZDnYdl3CA=="
    var TOKEN_2 = "DfBwpk+Kguq/U74Ib7GuQfuIer/ilctWhpf3beM8sh4zRaX9+XBAYQC/uo6R2ULn/yByGTF3egBmkKKtp7VSH15Ml1t0UcUoO69qih6Hu2O7d7rEtDW8fybuaq07zhFAAgHDnQ2S6repGK/TKy1t5c7soJ0TscyIYPmIc6mLFIISjjoCVQe4QbmybU0fBz44vgKBlc5X4hlbnD5HJECEO+ucKR33XcF0cbKqlJWHy8oMApOzL7D3zhrm3ShyZnM/Z2PK/9gkc7iw5TusO14vY24nGdtsfwCNa9DLFCW+qqBDZ5qI+nbWByIaz2sj4G2ifqpsE6raa9yBq2fOiwk52w=="
    var HOST = "gst-men-rt02.gamesparks.net"
    var PORT = 5050

    func setUpScene() {

        GameSparksRT.setLogger({(message:String) -> Void in
            NSLog("GSRT: %@", message)
        })

        // create two sessions and start them
        self.session1 = GameSparksRTSessionBuilder()
            .setConnectToken(self.TOKEN_1)
            .setHost(self.HOST)
            .setPort(NSNumber(integerLiteral: self.PORT))
            .setListener(self)
            .build()

        if let session = self.session1{
            session.start();
        }

        self.session2 = GameSparksRTSessionBuilder()
            .setConnectToken(self.TOKEN_2)
            .setHost(self.HOST)
            .setPort(NSNumber(integerLiteral: self.PORT))
            .setListener(self)
            .build()

        if let session = self.session2{
            session.start();
        }

        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
            label.text = "GameSparks RT";
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 4.0
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
            
            #if os(watchOS)
                // For watch we just periodically create one of these and let it spin
                // For other platforms we let user touch/mouse events create these
                spinnyNode.position = CGPoint(x: 0.0, y: 0.0)
                spinnyNode.strokeColor = SKColor.red
                self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 2.0),
                                                                   SKAction.run({
                                                                       let n = spinnyNode.copy() as! SKShapeNode
                                                                       self.addChild(n)
                                                                   })])))
            #endif
        }
    }
    
    #if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    #endif

    func makeSpinny(at pos: CGPoint, color: SKColor) {

        // the creation of the spinny will be done on the remote end.
        if let session = self.session1{
            if(session.getReady())
            {
                let data = RTData()
                data.setFloat(1, value: NSNumber(value: Float(pos.x)));
                data.setFloat(2, value: NSNumber(value: Float(pos.y)));

                data.setFloat(3, value: NSNumber(value: Float(color.cgColor.components![0])))
                data.setFloat(4, value: NSNumber(value: Float(color.cgColor.components![1])))
                data.setFloat(5, value: NSNumber(value: Float(color.cgColor.components![2])))

                let bytes = "Hello binary world".data(using: .utf8);

                session.send(data, withOpcode: 42, andBytes: bytes!, andDeliveryIntent: RTDeliveryIntent.RTDI_RELIABLE);
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // the RT sessions need to be updated regularly
        if let session = self.session1{
            session.update()
        }

        if let session = self.session2{
            session.update()
        }
    }

    deinit {
        // when a session listener gets destroyed, it needs to be cleard. Only do this once per session listener!
        session1?.clearListenerAdapter()
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.green)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.blue)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        self.makeSpinny(at: event.location(in: self), color: SKColor.green)
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.blue)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.red)
    }

}
#endif

