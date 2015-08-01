//
//  XXButton.swift
//  Button
//	0.1.1
//
//  Created by Joshua Cox on 7/27/15.
//  Copyright (c) 2015 Joshua Cox. All rights reserved.
//

import SpriteKit

class XXButton: SKNode {
	private var background : SKShapeNode
	private var label : SKLabelNode
	private var callback : (() -> Void)?
	
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
	
	/// Instantiate button node with a texture and callback function.
	convenience init(texture: SKTexture, callback: () -> Void) {
		self.init(size: texture.size(), text: "")
		self.callback = callback
		background.fillTexture = texture
		background.strokeColor = UIColor.clearColor()
		userInteractionEnabled = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
		if userInteractionEnabled {
			callback!()
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
		self.callback = callback
		userInteractionEnabled = true
	}

}




