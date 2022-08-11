package objects;

import DillyzLogger.LogType;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;
import haxe.Exception;

using DillyzUtil;

typedef StageAssetData =
{
	var name:String;
	var path:String;
	var x:Int;
	var y:Int;
	var active:Bool;
	var scrollFactor:Array<Float>;
	var scale:Array<Float>;
}

typedef StageData =
{
	// stage positions
	var position_dad:Array<Int>;
	var position_girlfriend:Array<Int>;
	var position_boyfriend:Array<Int>;
	// camera offsets
	var camera_offset_dad:Array<Int>;
	var camera_offset_girlfriend:Array<Int>;
	var camera_offset_boyfriend:Array<Int>;
	// zooms
	var defaultZoom:Float;
	var zoom_multi_dad:Float;
	var zoom_multi_girlfriend:Float;
	var zoom_multi_boyfriend:Float;
	// i hate week 6
	var pixel_stage:Bool;
	// bg elements NOT added by lua
	var bgPieces:Array<StageAssetData>;
}

class FunkyStage extends FlxTypedSpriteGroup<FunkySprite>
{
	public var bgAssets:Map<String, FunkySprite>;
	public var stageName:String;

	public var posDad:FlxPoint;
	public var posGF:FlxPoint;
	public var posBF:FlxPoint;

	public var camOffDad:FlxPoint;
	public var camOffGF:FlxPoint;
	public var camOffBF:FlxPoint;

	public var camZoom:Float;

	public var zoomMultiDad:Float;
	public var zoomMultiGF:Float;
	public var zoomMultiBF:Float;

	public var pixelStage:Bool;

	public static var defaultData:StageData = {
		// stage positions
		position_dad: [100, 100],
		position_girlfriend: [420, 100],
		position_boyfriend: [770, 100],
		// camera offset
		camera_offset_dad: [0, 0],
		camera_offset_girlfriend: [0, 0],
		camera_offset_boyfriend: [0, 0],
		// zooms
		defaultZoom: 0.9,
		zoom_multi_dad: 0.95,
		zoom_multi_girlfriend: 1,
		zoom_multi_boyfriend: 1.05,
		// i hate week 6
		pixel_stage: false,
		// bg elements not added by lua
		bgPieces: [
			{
				name: "BG",
				path: "stages/stage/BG",
				x: -600,
				y: -200,
				active: false,
				scrollFactor: [0.9, 0.9],
				scale: [1, 1]
			},
			{
				name: "Front",
				path: "stages/stage/Front",
				x: -650,
				y: -600,
				active: false,
				scrollFactor: [0.9, 0.9],
				scale: [1.1, 1.1]
			},
			{
				name: "Curtains",
				path: "stages/stage/Curtains",
				x: -500,
				y: -300,
				active: false,
				scrollFactor: [1.3, 1.3],
				scale: [0.9, 0.9]
			}
		]
	};

	public var curData:StageData;

	public function new(?stageName:String = 'stage')
	{
		super();
		this.bgAssets = new Map<String, FunkySprite>();
		this.stageName = stageName;

		this.curData = Paths.stageSettingsJson(this.stageName);

		// first do char positions
		this.posDad = new FlxPoint(curData.position_dad[0], curData.position_dad[1]);
		this.posGF = new FlxPoint(curData.position_girlfriend[0], curData.position_girlfriend[1]);
		this.posBF = new FlxPoint(curData.position_boyfriend[0], curData.position_boyfriend[1]);
		// now do camera positions
		this.camOffDad = new FlxPoint(curData.camera_offset_dad[0], curData.camera_offset_dad[1]);
		this.camOffGF = new FlxPoint(curData.camera_offset_girlfriend[0], curData.camera_offset_girlfriend[1]);
		this.camOffBF = new FlxPoint(curData.camera_offset_boyfriend[0], curData.camera_offset_boyfriend[1]);
		// now zooms
		this.camZoom = curData.defaultZoom;
		this.zoomMultiDad = curData.zoom_multi_dad;
		this.zoomMultiGF = curData.zoom_multi_girlfriend;
		this.zoomMultiBF = curData.zoom_multi_boyfriend;
		// week 6 can kill itself
		this.pixelStage = curData.pixel_stage;
		// bg elements loading
		for (i in curData.bgPieces)
		{
			var newStaticAsset:FunkySprite = new FunkySprite(i.x, i.y).loadGraphic(Paths.stageSprite(i.path));
			newStaticAsset.active = i.active;
			newStaticAsset.scrollFactor.set(i.scrollFactor[0], i.scrollFactor[1]);
			newStaticAsset.scale.set(i.scale[0], i.scale[1]);
			bgAssets.set(i.name, newStaticAsset);
			add(newStaticAsset);
		}
	}

	override public function destroy()
	{
		var keys:Array<String> = cast(bgAssets.keys().toArray());
		for (i in 0...keys.length)
		{
			try
			{
				var graphic:FunkySprite = bgAssets.get(keys[i]);
				remove(graphic);
				bgAssets.remove(keys[i]);
				graphic.destroy();
			}
			catch (e:Exception)
			{
				DillyzLogger.log('Could not clear graphic asset \'${keys[i]}\'; ${e.toString()}\n${e.message}', LogType.Error);
			}
		}
		super.destroy();
	}
}
