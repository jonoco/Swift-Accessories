//
//  XXButton.swift
//  Button
//	0.1.7
//
//  Created by Joshua Cox on 7/27/15.
//  MIT License
//  Copyright (c) 2015 Joshua Cox. All rights reserved.
//

import SpriteKit

class XXButton: SKNode {
	private let background : SKShapeNode
	private let label : SKLabelNode
	
	private var pressedAction : SKAction?
	private static var defaultAction : SKAction?
	
	private var callback : (() -> Void)?
	private var argCallback : ((AnyObject) -> Void)?
	private var arg : AnyObject?
	
	private var upTexture : SKTexture?
	private var downTexture : SKTexture?
	private static var defaultUpTexture : SKTexture?
	private static var defaultDownTexture : SKTexture?
	private var upColor : UIColor?
	private var downColor : UIColor?
	private static var defaultUpColor : UIColor = UIColor(red: 125/255, green: 130/255, blue: 138/255, alpha: 1.0)
	private static var defaultDownColor : UIColor?
	
	///	Instantiate a convenient button styled node. Determine touch events using node name.
	init(size: CGSize, text: String) {
		background = SKShapeNode(
			rect: CGRectMake(-size.width/2, -size.height/2, size.width, size.height),
			cornerRadius: 10)
		
		if XXButton.defaultUpTexture != nil { background.fillTexture = XXButton.defaultUpTexture }
		else { background.fillColor = XXButton.defaultUpColor }
		
		background.strokeColor = UIColor.clearColor()
		
		label = SKLabelNode(text: text)
		label.fontSize = 80
		label.verticalAlignmentMode = .Center
		
		super.init()
		addChild(background)
		addChild(label)
	}
	
	/// DEPRECATED: use setCallback - Instantiate button node with callback.
	convenience init(size: CGSize, text: String, callback: () -> Void) {
		self.init(size: size, text: text)
		self.callback = callback
		userInteractionEnabled = true
	}
	
	/// DEPRECATED: use setCallback - Instantiate button node with callback with an arguement. If arg is nil, the button object will be passed.
	convenience init(size: CGSize, text: String, callback: (AnyObject) -> Void, _ arg: AnyObject?) {
		self.init(size: size, text: text)
		self.argCallback = callback
		self.arg = arg ?? self
		userInteractionEnabled = true
	}
	
	/// Instantiate button node with a texture.
	convenience init(texture: SKTexture) {
		self.init(size: texture.size(), text: "")
		background.fillTexture = texture
		background.strokeColor = UIColor.clearColor()
	}
	
	/// DEPRECATED: use setCallback - Instantiate button node with a texture and callback function.
	convenience init(texture: SKTexture, callback: () -> Void) {
		self.init(size: texture.size(), text: "")
		self.callback = callback
		background.fillTexture = texture
		background.strokeColor = UIColor.clearColor()
		userInteractionEnabled = true
	}
	
	/// DEPRECATED: use setCallback - Instantiate button node with a texture and callback function with an arguement. If arg is nil, the button object will be passed.
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
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		if downColor != nil { background.fillColor = downColor! }
		else if downTexture != nil { background.fillTexture = downTexture! }
		else if XXButton.defaultDownTexture != nil { background.fillTexture = XXButton.defaultDownTexture!}
		else if XXButton.defaultDownColor != nil {background.fillColor = XXButton.defaultDownColor!}
		
		if pressedAction != nil { runAction(pressedAction!) }
		else if XXButton.defaultAction != nil { runAction(XXButton.defaultAction!)}
	}
	
	override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
		if upColor != nil { background.fillColor = upColor! }
		else if upTexture != nil { background.fillTexture = upTexture! }
		else if XXButton.defaultUpTexture != nil { background.fillTexture = XXButton.defaultUpTexture! }
		else {background.fillColor = XXButton.defaultUpColor}
		
//		if pressedAction != nil { runAction(pressedAction!) }
//		else if XXButton.defaultAction != nil { runAction(XXButton.defaultAction!)}
		
		if userInteractionEnabled {
			if argCallback != nil { argCallback!(arg!) }
			if callback != nil { callback!() }
		}
	}
	
	// MARK: - Properties
	
	/// Set all child node names of the Button node.
	func setNameTo(name: String) -> XXButton {
		background.name = name
		label.name = name
		return self
	}
	/// Change the button text.
	func setTextTo(text: String) -> XXButton {
		label.text = text
		return self
	}
	/// Change the button font style, default is system default.
	func setFontNameTo(fontNamed: String) -> XXButton {
		label.fontName = name
		return self
	}
	/// Change the button font size, default is 80.
	func setFontSizeTo(size: CGFloat) -> XXButton {
		label.fontSize = size
		return self
	}
	/// Change the button text color, default is UIColor.whiteColor().
	func setFontColorTo(color: UIColor) -> XXButton {
		label.fontColor = color
		return self
	}
	/// Change the button's border color, default is UIColor.clearColor.
	func setBorderColorTo(color: UIColor) -> XXButton {
		background.strokeColor = color
		return self
	}
	
	// MARK: - Callbacks
	
	/// Assign a callback to button.
	func setCallbackTo(callback: () -> Void) -> XXButton {
		resetCallbacks()
		self.callback = callback
		return self
	}
	/// Assign a callback with an arguement. If arg is nil, self will be passed.
	func setCallbackTo(callback: (AnyObject) -> Void, _ arg: AnyObject?) -> XXButton {
		resetCallbacks()
		self.argCallback = callback
		self.arg = arg ?? self
		return self
	}
	
	// MARK: - Rest state
	
	/// Set a texture for rest state.
	func setTextureTo(texture: SKTexture) -> XXButton {
		self.upTexture = texture
		background.fillTexture = texture
		return self
	}
	/// Default texture for rest state.
	func setDefaultTextureTo(texture: SKTexture) -> XXButton {
		XXButton.defaultUpTexture = texture
		background.fillTexture = texture
		self.upTexture = texture
		return self
	}
	
	/// Change the button's background color, default is grey : rgb(125,130,138).
	func setBackgroundColorTo(color: UIColor) -> XXButton {
		self.upColor = color
		background.fillColor = color
		return self
	}
	/// Default rest state color.
	func setDefaultColorTo(color: UIColor) -> XXButton {
		XXButton.defaultUpColor = color
		self.upColor = color
		background.fillColor = color
		return self
	}

	// MARK: - Pressed state

	/// Set a texture for pressed state. Requires a callback to be set.
	func setPressedTextureTo(texture: SKTexture) -> XXButton {
		self.downTexture = texture
		return self
	}
	/// Default pressed state texture. Requires a callback to be set.
	func setDefaultPressedTextureTo(texture: SKTexture) -> XXButton {
		XXButton.defaultDownTexture = texture
		self.downTexture = texture
		return self
	}
	
	/// Set a color for pressed state. Not used if a texture is used. Requires a callback to be set.
	func setPressedColorTo(color: UIColor) -> XXButton {
		self.upColor = background.fillColor
		self.downColor = color
		return self
	}
	/// Default pressed color. Not used if a texture is used. Requires a callback to be set.
	func setDefaultPressedColorTo(color: UIColor) -> XXButton {
		XXButton.defaultDownColor = color
		self.downColor = color
		return self
	}
	
	/// Action played when the button is pressed. Requires a callback to be set.
	func setPressedActionTo(action: SKAction) -> XXButton {
		self.pressedAction = action
		return self
	}
	/// Default action shared by all buttons. Will not run on a button if an individual action is set. Requires a callback to be set.
	func setDefaultActionTo(action: SKAction) -> XXButton {
		XXButton.defaultAction = action
		return self
	}
	
	// MARK: - Private functions
	
	private func resetCallbacks() {
		userInteractionEnabled = true
		self.callback = nil
		self.argCallback = nil
	}
	
	struct Color {
		static let Red = UIColor(red: 221/255, green: 113/255, blue: 102/255, alpha: 1)
		static let Cyan = UIColor(red: 80/255, green: 221/255, blue: 231/255, alpha: 1)
		static let Green = UIColor(red: 150/255, green: 221/255, blue: 119/255, alpha: 1)
		static let Purple = UIColor(red: 161/255, green: 182/255, blue: 255/255, alpha: 1)
	}
}




