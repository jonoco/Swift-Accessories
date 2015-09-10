# Swift-Accessories
Extra Accessories for Swift.  
Drop them into your project or use them as a starting point to create something good, or just slightly better.

### Acessories
- [Button](#button)
- Multiline Label

## Installation
1. Drag the .swift file into your project, make sure to check <b>Copy Items If Needed</b>.
2. Initialize the object.
3. Stop reading here.

## Usage
### Button
```swift

    import SpriteKit
    
    let buttonSize = CGSize(width: 100, height: 50)
    	
    // Use textures or the default color backgrounds to style buttons
    let colorButton   = XXButton(size: buttonSize, text: "a button")
    let textureButton = XXButton(texture: SKTexture)
    
    // Set default behavior on one button to extend them to all other buttons
    let topButton = XXButton(size: buttonSize, text: "top button")
		.setDefaultActionTo(
				SKAction.sequence([
					SKAction.scaleBy(1.1, duration: 0.05),
					SKAction.scaleTo(1.0, duration: 0.05)]))
    
    // Override defaults by setting individual behaviors
    let topButton = XXButton(size: buttonSize, text: "top button")
    	.setActionTo(nil)
    
	// Chain methods to assign multiple properties
	let rightButton = XXButton(size: buttonSize, text: "right button")
		.setBackgroundColorTo(XXButton.Color.Cyan)
		.setPressedColorTo(XXButton.Color.Gray)
		.setCallbackTo(callback, nil)
		.setFontSizeTo(80)
		
	// Set callbacks with or without arguements
	let buttonA = XXButton(size: buttonSize, text: "no argument")
	  .setCallbackTo(callback)
	
	func callback() {
	  println("I've been called")
	}
	
	let buttonB = XXButton(size: buttonSize, text: "has an argument")
	  .setCallbackTo(callbackWithArg, "some argument")
	 
	// Callback needs to accept an AnyObject
	func callbackWithArg(arg: AnyObject) {
	  // Cast argument to expected type to handle (if necessary)
	  let arg = arg as! String
	  println(arg)
	}
	
	// Or just use a closure in place of a callback
	let buttonC = XXButton(size: buttonSize, text: "closure time")
		.setCallbackTo({
			let msg = "this seems reckless"
			println(msg)
		})
	
	// Use the style templates to help prototype or whatever
	let styleButton = XXButton(size: buttonSize, text: "i'm fancy")
		.setBackgroundColorTo(XXButton.Color.Red)
		.setPressedActionTo(XXButton.Animations.Pop)
		
		// Check out XXButton.Color & XXButton.Animations for all options
```

#### Experimental button behavior
```swift
	// Enable button toggling, e.g., a checkbox behavior
	let toggleButton = XXButton(size: CGSize, text: String)
			.setTogglingOn()

	// Enable radio buttons
	let radioButton1 = XXButton(size: CGSize, text: String)
			.setRadioOn(nil)
	let radioButton2 = XXButton(size: CGSize, text: String)
			.setRadioOn(nil)
	
	// Use a radio group to allow sets of radio buttons
	let radioButtonA = XXButton(size: CGSize, text: String)
			.setRadioOn("groupOne")
	let radioButtonB = XXButton(size: CGSize, text: String)
			.setRadioOn("groupOne")

	let radioButtonC = XXButton(size: CGSize, text: String)
			.setRadioOn("groupTwo")
	let radioButtonD = XXButton(size: CGSize, text: String)
			.setRadioOn("groupTwo")

	// Set a toggled state to pre-enable a checkbox or radio
	let activeButton = XXButton(size: CGSize, text: String)
			.setTogglingOn()
			.setActive()

	let radioButtonOn = XXButton(size: CGSize, text: String)
			.setRadioOn(nil)
			.setActive()
	let radioButtonOff = XXButton(size: CGSize, text: String)
			.setRadioOn(nil)
```
