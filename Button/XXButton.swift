//
//  XXButton.swift
//  Button
//	0.1.3
//
//  Created by Joshua Cox on 7/27/15.
//  Copyright (c) 2015 Joshua Cox. All rights reserved.
//

import SpriteKit

class XXButton: SKNode {
	private var background : SKShapeNode
	private var label : SKLabelNode
	private var pressedAction : SKAction?
	private var callback : (() -> Void)?
	private var argCallback : ((AnyObject) -> Void)?
	private var arg : AnyObject?
	
	///	Instantiate a convienient button styled node. Determine touch events using node name.
	init(size: CGSize, text: String) {
		let rect = CGRectMake(-size.width/2, -size.height/2, size.width, size.height)
		background = SKShapeNode(rect: rect, cornerRadius: 10)
		background.fillColor = UIColor(red: 125/255, green: 130/255, blue: 138/255, alpha: 1.0)
		
		label = SKLabelNode(text: text)
		label.fontSize = 80
		label.verticalAlignmentMode = .Center
		
		super.init()
		addChild(background)
		addChild(label)
	}
	
	/// Instantiate button node with callback.
	convenience init(size: CGSize, text: String, callback: () -> Void) {
		self.init(size: size, text: text)
		self.callback = callback
		userInteractionEnabled = true
	}
	
	/// Instantiate button node with callback with an arguement. If arg is nil, the button object will be passed.
	convenience init(size: CGSize, text: String, callback: (AnyObject) -> Void, _ arg: AnyObject?) {
		self.init(size: size, text: text)
		self.argCallback = callback
		self.arg = arg ?? self
		userInteractionEnabled = true
	}
	
	/// Instantiate button node with a texture and callback function.
	convenience init(texture: SKTexture, callback: () -> Void) {
		self.init(size: texture.size(), text: "")
		self.callback = callback
		background.fillTexture = texture
		background.strokeColor = UIColor.clearColor()
		userInteractionEnabled = true
	}
	
	/// Instantiate button node with a texture and callback function with an arguement. If arg is nil, the button object will be passed.
	convenience init(texture: SKTexture, callback: (AnyObject) -> Void, _ arg: AnyObject?) {
		self.init(size: texture.size(), text: "")
		self.argCallback = callback
		self.arg = arg ?? self
		background.fillTexture = texture
		background.strokeColor = UIColor.clearColor()
		userInteractionEnabled = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
		if pressedAction != nil {
			runAction(pressedAction!)
		}
		
		if userInteractionEnabled {
			if argCallback != nil { argCallback!(arg!) }
			if callback != nil { callback!() }
		}
	}
	
	/// Set all child node names of the Button node.
	func setNameTo(name: String) {
		background.name = name
		label.name = name
	}
	/// Change the button text.
	func setTextTo(text: String) {
		label.text = text
	}
	/// Change the button font style, default is system default.
	func setFontNameTo(fontNamed: String) {
		label.fontName = name
	}
	/// Change the button font size, default is 80.
	func setFontSizeTo(size: CGFloat) {
		label.fontSize = size
	}
	/// Change the button text color, default is UIColor.whiteColor().
	func setFontColorTo(color: UIColor) {
		label.fontColor = color
	}
	/// Change the button's background color, default is grey : rgb(125,130,138).
	func setBackgroundColorTo(color: UIColor) {
		background.fillColor = color
	}
	/// Change the button's border color, default is UIColor.whiteColor().
	func setBorderColorTo(color: UIColor) {
		background.strokeColor = color
	}
	/// Assign a callback to button.
	func setCallbackTo(callback: () -> Void) {
		resetCallbacks()
		self.callback = callback
	}
	/// Assign a callback with an arguement. If arg is nil, self will be passed.
	func setCallbackTo(callback: (AnyObject) -> Void, _ arg: AnyObject?) {
		resetCallbacks()
		self.argCallback = callback
		self.arg = arg ?? self
	}
	/// Action played when the button is pressed.
	func setPressedActionTo(action: SKAction) {
		self.pressedAction = action
	}
	
	private func resetCallbacks() {
		userInteractionEnabled = true
		self.callback = nil
		self.argCallback = nil
	}
}




