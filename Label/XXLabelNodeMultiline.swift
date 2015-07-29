//
//  XXLabelNodeMultiline.swift
//  Multiline Label Node
//
//  Created by Joshua Cox on 6/26/15.
//  Copyright (c) 2015 Joshua Cox. All rights reserved.
//

import SpriteKit

/**
		Generates multiple SKLabelNodes to create a convenient multiline label node
*/
class XXLabelNodeMultiline: SKNode {
	
	var fontSize: CGFloat = 52.0 {didSet {update()}}
	var fontColor: SKColor = UIColor.grayColor() {didSet {update()}}
	var fontName = "AvenirNext-Regular" {didSet {update()}}
	var verticalAlignmentMode = SKLabelVerticalAlignmentMode.Bottom {didSet {update()}}
	var horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center {didSet {update()}}
	var text: String {didSet {update()}}
	var predicate: String {didSet {update()}}
	/**
			Space between lines of text in pixels. Default 0.0.
	*/
	var verticalLineSpacing: CGFloat = 0.0 {didSet {update()}}
	
	/**
			Divides lines of text with \n.
	*/
	convenience init(text: String) {
		self.init(text: text, predicate: "\n")
	}
	
	/**
			Choose a predicate for line breaks e.g., "/n"
	*/
	init(text: String, predicate: String) {
		self.text = text
		self.predicate = predicate
		super.init()
		
		createLines()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func createLines() {
		removeAllChildren()
		
		let lines = text.componentsSeparatedByString(predicate)
		
		for var i = 0 ; i < lines.count ; i++ {
			let label = SKLabelNode(fontNamed: fontName)
			label.fontSize = fontSize
			label.fontColor = fontColor
			label.text = lines[i]
			label.position = CGPoint(x: 0, y: (CGFloat(i) * -label.fontSize))
			addChild(label)
		}
	}
	
	func update() {
		createLines()
		
		for var i = 0 ; i < children.count ; i++ {
			let label = children[i] as! SKLabelNode
			label.fontName = fontName
			label.fontSize = fontSize
			label.fontColor = fontColor
			label.verticalAlignmentMode = verticalAlignmentMode
			label.horizontalAlignmentMode = horizontalAlignmentMode
			label.position = CGPoint(x: 0, y: (CGFloat(i) * -fontSize))
			label.position.y -= CGFloat(i) * verticalLineSpacing
			
		}
	}
}
