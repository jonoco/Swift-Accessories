//
//  XXTileMap.swift
//	v0.1.0	
//
//  Created by Joshua Cox on 9/5/15.
//  Copyright (c) 2015 Joshua Cox. All rights reserved.
//

import SpriteKit

/// Tilemap for parsing JSON tile maps and producing tilelayers and objects
class XXTileMap {
	
	/// Tilemap file
	var fileName: NSURL
	
	/// Number of tiles in width and height
	var mapSize: CGSize = CGSizeZero
	
	/// Size of individual tiles
	var tileSize: CGSize = CGSizeZero
	
	/// Map orientation style
	var orientation: Orientation?
	
	/// Layers may be of type tilelayer or objectlayer. Order of tilelayers represents z-positioning
	private var tileLayers: [String:TileLayer] = [String:TileLayer]()
	private var objectLayers: [String:ObjectLayer] = [String:ObjectLayer]()
	private var tilesets: [Tileset] = []
	
	/// Tilemap properties
	var properties: [String : AnyObject] = [String : AnyObject]()
	
	/// Stores cached tiles
	var tilesetTextureCache: [Int : SKTexture] = [Int:SKTexture]()
	
	/// Change tile's filtering mode. Use Linear if tiles are pixelated.
	var tileFilteringMode : SKTextureFilteringMode = .Nearest
	
	/// Initialize tilemap with a tilemap .json file
	init(fileName: String) {
		self.fileName = NSURL(string: fileName)!
		readFile()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func readFile() {
		let file = self.fileName.URLByDeletingPathExtension
		let ext = self.fileName.pathExtension
		
		if (ext!.lowercaseString != "json") {
			fatalError("Tilemap error: tilemap is invalid data type: \(ext)")
		}
		
		let path = NSBundle.mainBundle().pathForResource(String(file!), ofType: ext!)
		let data = NSData(contentsOfFile: path!)
		let json = JSON(data: data!)

		beginParse(json)
		
	}
	
	private func beginParse(json: JSON) {
		
		// Parse tilemap properties
		self.mapSize = CGSize(width: json["width"].int!, height: json["height"].int!)
		self.tileSize = CGSize(width: json["tileheight"].int!, height: json["tilewidth"].int!)
		
		let orientation: String = json["orientation"].string!
		switch orientation {
		case "orthogonal":
			self.orientation = .Orthogonal
		case "isometric":
			self.orientation = .Isometric
		default:
			fatalError("Tilemap error: invalid tilemap orientation: \(orientation)")
		}
		
		// Parse layers
		let layers = json["layers"].array!
		for layer in layers as [JSON] {
			
			let type = layer["type"]
			switch type {
			case "objectgroup":
				let mapLayer = ObjectLayer()
				mapLayer.name = layer["name"].string!.lowercaseString
				mapLayer.opacity = layer["opacity"].double!
				mapLayer.visible = layer["visible"].bool!
				mapLayer.size = CGSize(width: layer["width"].double!, height: layer["height"].double!)
				mapLayer.position = CGPoint(x: layer["x"].double!, y: layer["y"].double!)
				
				// Parse through objects array
				let objects = layer["objects"].array!
				for object in objects {
					let size = CGSize(width: object["width"].double!, height: object["height"].double!)
					let position = CGPoint(x: object["x"].double!, y: object["y"].double!)
					let name = object["name"].string!
					let visible = object["visible"].bool!
					let mapObject = MapObject(size: size, name: name, visible: visible, position: position)
					mapLayer.objects.append(mapObject)
				}
				
				// add layer to tilemap layers
				self.objectLayers.updateValue(mapLayer, forKey: mapLayer.name)
			case "tilelayer":
				let mapLayer = TileLayer()
				mapLayer.name = layer["name"].string!.lowercaseString
				mapLayer.opacity = layer["opacity"].double!
				mapLayer.visible = layer["visible"].bool!
				mapLayer.size = CGSize(width: layer["width"].double!, height: layer["height"].double!)
				mapLayer.position = CGPoint(x: layer["x"].double!, y: layer["y"].double!)
				
				// need to convert JSON array to Int array
				// possible source of drag
				let data = layer["data"].array!
				for tile in data {
					mapLayer.tiles.append(tile.int!)
				}
				
				// add layer to tilemap layers
				self.tileLayers.updateValue(mapLayer, forKey: mapLayer.name)
			default:
				break
			}// switch type
		}// layers
		
		// Parse tilesets
		let tilesets = json["tilesets"].array!
		for tileset in tilesets {
			
			let newTileset = Tileset(
				firstGID: tileset["firstgid"].int!,
				imageName: tileset["image"].string!,
				imageSize: CGSize(width: tileset["imagewidth"].int!, height: tileset["imageheight"].int!),
				imageMargin: tileset["margin"].int!,
				imageSpacing: tileset["spacing"].int!,
				tileSize: CGSize(width: tileset["tilewidth"].int!, height: tileset["tileheight"].int!),
				name: tileset["name"].string!)
			
			// parse tileset properties
			for (gid, property):(String, JSON) in tileset["tileproperties"] {
				
				// tileproperties is [String:Anyobject]
				let tileProperties = property.dictionaryObject!
				let tile = Int(gid)!
				newTileset.tileProperties.updateValue(tileProperties, forKey: tile)
			}
			
			self.tilesets.append(newTileset)
		}
		
	}// beginParse(json:)
	
	/// Returns layer of tiles for tile layer name
	func getTileLayer(named: String) -> SKNode {
		let layerMeta = self.tileLayers[named.lowercaseString]
		if !(layerMeta != nil) {
			fatalError("Tilemap Error: no tilelayer with name \(named)")
		}
		
		let tileLayer = SKNode()
		tileLayer.name = layerMeta!.name
		tileLayer.hidden = !layerMeta!.visible
		tileLayer.alpha = CGFloat(layerMeta!.opacity)
		
		let width = Int(layerMeta!.size.width)
		let height = Int(layerMeta!.size.height)
		
		for row in 0..<height {
			for column in 0..<width {
				let index = column + row * width
				let gid = layerMeta!.tiles[index]
				if gid < 1 { continue }
				let tile = tileForGID(gid)
				
				tile.position = CGPoint(
					x: (CGFloat(column) * tileSize.width) - tile.size.width/2,
					y: (tileSize.height * mapSize.height) - CGFloat(row) * tileSize.height - tile.size.height/2)
				tileLayer.addChild(tile)
			}
		}
		
		return tileLayer
	}
	
	/// Returns array of objects for object layer name
	func getObjectLayer(named: String) -> [MapObject]? {
		
		if let objects = self.objectLayers[named.lowercaseString]?.objects {
			return objects
		}
		
		return [MapObject]?()
	}
	
	/// Returns tile for GID value
	func tileForGID(GID: Int) -> Tile {
		let texture = tilesetTextureForGID(GID)
		let tile = Tile(texture: texture)
		
		// check for properties
		let tileset = tilesetForGID(GID)
		if let properties : [String:AnyObject] = tileset.tileProperties[GID] as? [String:AnyObject] {
			tile.properties = properties
		}
		
		return tile
	}
	
	/// Returns the tileset for a given GID
	func tilesetForGID(GID: Int) -> Tileset {
		var tileset : Tileset = self.tilesets.first!
		let highestFirstGID = 0
		for i in 0..<self.tilesets.count {
			if self.tilesets[i].firstGID > highestFirstGID && self.tilesets[i].firstGID <= GID {
				tileset = self.tilesets[i]
			}
		}
		return tileset
	}
	
	/// Returns image from tileset matching the GID
	func tilesetTextureForGID(GID: Int) -> SKTexture {
		
		// check the cache
		if let texture = tilesetTextureCache[GID] {
			return texture
		}
		
		let tileset = tilesetForGID(GID)
		
		let index = GID - tileset.firstGID
		
		var rowOffset = (((CGFloat(tileset.imageSpacing) + tileset.tileSize.height) * CGFloat(tileset.rowForIndex(index))) + CGFloat(tileset.imageMargin)) / tileset.imageSize.height
		let colOffset = (((CGFloat(tileset.imageSpacing) + tileset.tileSize.width) * CGFloat(tileset.colForIndex(index))) + CGFloat(tileset.imageMargin)) / tileset.imageSize.width
		
		// reverse row offset
		rowOffset = 1.0 - rowOffset - (tileset.tileSize.height/tileset.imageSize.height)
		
		let rect = CGRectMake(
			colOffset,
			rowOffset,
			tileset.tileSize.width/tileset.imageSize.width,
			tileset.tileSize.height/tileset.imageSize.height)
		let texture = SKTexture(rect: rect, inTexture: tileset.atlas)
				texture.filteringMode = tileFilteringMode

		// add new texture to cache
		self.tilesetTextureCache.updateValue(texture, forKey: GID)
		
		return texture
	}
	
	/// Returns tile at location in tile units
	func tileAtPosition(inTiles tiles:CGPoint) -> Tile {
		//
		return Tile()
	}
	
	/// Returns tile at location in pixel units
	func tileAtPosition(inPixels pixels: CGPoint) -> Tile {
		//
		return Tile()
	}
	
	/// Returns tile layer names, ordered by their z-position within the tilemap
	func tileLayersNames() -> [String] {
		return Array(tileLayers.keys)
	}
	
	/// Returns object layer names
	func objectLayersNames() -> [String] {
		return Array(objectLayers.keys)
	}
	
	/// Returns a tileset by the name designated in tilemap editor
	func getTileset(named: String) -> Tileset? {
		var namedTileset : Tileset?
		
		for tileset in tilesets {
			if tileset.name == named.lowercaseString {
				namedTileset = tileset
			}
		}
		return namedTileset
	}
}

/// Describes a single tile
class Tile: SKSpriteNode {
	lazy var properties : [String:AnyObject] = [String:AnyObject]()
}

/// Descripes a single object of an objectlayer. Useful for describing collision or event areas on tiles
class MapObject {
	/// Size of object. Size of (0,0) indicates a reference marker.
	var size : CGSize
	var name : String
	var visible : Bool
	var position : CGPoint
	var properties : [String : AnyObject] = [String : AnyObject]()
	
	init(size: CGSize, name: String, visible: Bool, position: CGPoint) {
		self.size = size
		self.name = name
		self.visible = visible
		self.position = position
	}
}

/// Superclass for tilemap layers
class Layer {
	/// Size of layer in tile units
	var size: CGSize = CGSizeZero
	/// Offset position of tile layer. Default (0,0)
	var position: CGPoint = CGPointZero
	var name: String = ""
	var opacity: Double = 1.0
	var visible: Bool = true
	
}

/// Describes a single tile layer
class TileLayer : Layer {
	/// Array of tile GIDs
	var tiles : [Int] = []
	
}

/// Describes a single layer of objects
class ObjectLayer : Layer {
	/// Array of layer objects
	var objects : [MapObject] = []
}

/// Describes a single tileset's properties
class Tileset {
	
	/// First non-void tile GID in set
	var firstGID : Int
	
	/// Tileset image name
	var imageName : String
	
	/// Total image size including margin and spacing
	var imageSize : CGSize
	
	/// Margin around tileset image
	var imageMargin : Int
	
	/// Spacing between tileset tile images
	var imageSpacing : Int
	
	/// Size of individual tiles in tilset
	var tileSize : CGSize
	
	/// Extra tile properties. [Int : [String:AnyObject] ]
	var tileProperties : [Int : AnyObject] = [Int : AnyObject]()
	
	/// Texture for tileset
	var atlas : SKTexture
	
	/// Name of tileset designated in tilemap editor
	var name : String
	
	var atlasTilesPerRow : Int {
		return (Int(imageSize.width) - imageMargin * 2 + imageSpacing) / (Int(tileSize.width) + imageSpacing)
	}
	
	var atlasTilesPerCol : Int {
		return (Int(imageSize.height) - imageMargin * 2 + imageSpacing) / (Int(tileSize.height) + imageSpacing)
	}
	
	init(firstGID: Int, imageName: String, imageSize: CGSize, imageMargin: Int, imageSpacing: Int, tileSize: CGSize, name: String ) {
		
		self.firstGID = firstGID
		self.imageName = imageName
		self.imageSize = imageSize
		self.imageMargin = imageMargin
		self.imageSpacing = imageSpacing
		self.tileSize = tileSize
		self.name = name.lowercaseString
		
		self.atlas = SKTexture(imageNamed: self.imageName)
	}
	
	/// Returns row in tile units for index
	func rowForIndex(index: Int) -> Int {
		return index / atlasTilesPerRow
	}
	
	/// Returns column in tile units for index
	func colForIndex(index: Int ) -> Int {
		return index % atlasTilesPerRow
	}
	
	/// Override the tileset image path from the tilemap file
	func setImagePath(path: String) {
		self.imageName = path
	}
}

/// Tilemap tile orientation
enum Orientation {
	case Isometric
	case Orthogonal
}




