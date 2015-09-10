//
//  XXButton.swift
//  Button
//	0.2.1
//
//  Created by Joshua Cox on 7/27/15.
//  MIT License 2015 Joshua Cox
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
	
	private var toggled : Bool?
	private var checkBox : Bool = false
	private var radio : Bool = false
	private var radioCallsign : Int = 0
	private var radioGroup : String = "radioGroup"
	
	private var upTexture : SKTexture?
	private var downTexture : SKTexture?
	private static var defaultUpTexture : SKTexture?
	private static var defaultDownTexture : SKTexture?
	private var upColor : UIColor?
	private var downColor : UIColor?
	private static var defaultUpColor : UIColor = UIColor(red: 125/255, green: 130/255, blue: 138/255, alpha: 1.0)
	private static var defaultDownColor : UIColor?

	///	Instantiate a convenient button styled node.
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
	
	/// Instantiate button node with a texture.
	convenience init(texture: SKTexture) {
		self.init(size: texture.size(), text: "")
		background.fillTexture = texture
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Touch functions
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		if radio {
			NSNotificationCenter.defaultCenter().postNotificationName(radioGroup, object: radioCallsign)
			return
		}
		pressDown()
	}
	
	override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
		if !radio { pressUp() }
		
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
	/// Enable checkbox behavior; button can be toggled off and on.
	func setCheckboxOn() -> XXButton {
		checkBox = true
		return self
	}
	/** 
			Change toggled state; e.g., checked or unchecked.
			IMPORTANT: If you are instantiating a button to be already toggled on,
			set toggled state property after setting a pressed color or texture.
	*/
	func setToggledStateTo(state: Bool) -> XXButton {
		if state { pressDown() }
		else { toggled = false }
		return self
	}
	/// Enable radio behavior with an optional group identifier.
	func setRadioOn(group: String?) -> XXButton {
		radio = true
		radioGroup = group ?? "radioGroup"
		radioCallsign = random()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "radioAlert:", name: radioGroup, object: nil)

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
	
	// MARK: - Utility functions
	
	/// Simulate a press without running the button's callback.
	func simulatePress() {
		pressDown()
		runAction(SKAction.sequence([
			SKAction.waitForDuration(0.05),
			SKAction.runBlock(pressUp)
		]))
	}
	
	// MARK: - Private functions
	
	private func pressDown() {
	
		if downColor != nil { background.fillColor = downColor! }
		else if downTexture != nil { background.fillTexture = downTexture! }
		else if XXButton.defaultDownTexture != nil { background.fillTexture = XXButton.defaultDownTexture!}
		else if XXButton.defaultDownColor != nil {background.fillColor = XXButton.defaultDownColor!}
		
		if pressedAction != nil { runAction(pressedAction!) }
		else if XXButton.defaultAction != nil { runAction(XXButton.defaultAction!)}
		
		if checkBox { toggled = (toggled == true) ? false : true } // only toggle on touch for a checkbox
	}
	
	private func pressUp() {
		if checkBox { if toggled! {return} }
	
		if upColor != nil { background.fillColor = upColor! }
		else if upTexture != nil { background.fillTexture = upTexture! }
		else if XXButton.defaultUpTexture != nil { background.fillTexture = XXButton.defaultUpTexture! }
		else {background.fillColor = XXButton.defaultUpColor}
	}
	
	private func resetCallbacks() {
		userInteractionEnabled = true
		self.callback = nil
		self.argCallback = nil
	}
	
	/// Invokes alert to radio group.
	func radioAlert(msg: AnyObject) {
		let activeCallsign = msg.object as! Int
		
		if (radioCallsign == activeCallsign) {
			pressDown()
			toggled = true
		} else {
			pressUp()
			toggled = false
		}
	}
	
	// MARK: - Template Options
	
	struct Color {
		static let Red	  = UIColor(red: 221/255, green: 113/255, blue: 102/255, alpha: 1)
		static let Cyan 	= UIColor(red:  80/255, green: 221/255, blue: 231/255, alpha: 1)
		static let Green 	= UIColor(red: 150/255, green: 221/255, blue: 119/255, alpha: 1)
		static let Purple = UIColor(red: 161/255, green: 182/255, blue: 255/255, alpha: 1)
		static let Gray   = UIColor(red: 125/255, green: 130/255, blue: 138/255, alpha: 1)
	}
	
	struct Animations {
		static let Pop : SKAction = {
			var anim = SKAction.group([
				SKAction.sequence([
					SKAction.scaleBy(1.1, duration: 0.05),
					SKAction.scaleTo(1.0, duration: 0.05)]),
				SKAction.sequence([
					SKAction.fadeAlphaTo(0.85, duration: 0.05),
					SKAction.fadeAlphaTo(1.0, duration: 0.05)])
				])
			anim.timingMode = SKActionTimingMode.EaseInEaseOut
			return anim
		}()
		
		static let Flop : SKAction = {
			var anim = SKAction.group([
				SKAction.sequence([
					SKAction.moveByX(0, y: -15, duration: 0.05),
					SKAction.moveByX(0, y: 15, duration: 0.05)]),
				SKAction.sequence([
					SKAction.fadeAlphaTo(0.8, duration: 0.05),
					SKAction.fadeAlphaTo(1.0, duration: 0.05)])
				])
			anim.timingMode = SKActionTimingMode.Linear
			return anim
			}()
	}
}




