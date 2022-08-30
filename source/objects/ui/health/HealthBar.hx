package objects.ui.health;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import objects.characters.Character;

class HealthBar extends FlxTypedSpriteGroup<FlxSprite>
{
	var intendedHealth:Float = 5000;
	var playerHealth:Float = 0;
	var healthBar:FlxBar;
	var healthBarOverlay:FlxSprite;

	public function new(?x:Float = 0, ?y:Float = 0)
	{
		super(x, y);

		healthBarOverlay = new FlxSprite(0, 0).loadGraphic(Paths.png('ui/Health Bar Overlay', 'shared'));

		healthBar = new FlxBar(2, 2, FlxBarFillDirection.RIGHT_TO_LEFT, Std.int(healthBarOverlay.width - 2), Std.int(healthBarOverlay.height - 2), this,
			"playerHealth", 0, 10000, false);

		healthBar.createFilledBar(FlxColor.fromRGB(161, 161, 161), FlxColor.fromRGB(161, 161, 161));

		healthBar.scale.x = 1.125;
		healthBarOverlay.scale.x = 1.125;

		add(healthBar);
		add(healthBarOverlay);

		updateHealth(1);
	}

	public function updateHealthIconsAndColors(charLeft:Character, charRight:Character)
	{
		remove(healthBar);
		remove(healthBarOverlay);

		healthBar.createFilledBar(FlxColor.fromRGB(charLeft.healthIconColors[0], charLeft.healthIconColors[1], charLeft.healthIconColors[2]),
			FlxColor.fromRGB(charRight.healthIconColors[0], charRight.healthIconColors[1], charRight.healthIconColors[2]));

		healthBar.scale.x = 1.125;
		healthBarOverlay.scale.x = 1.125;

		add(healthBar);
		add(healthBarOverlay);
	}

	public function updateHealth(realHealth:Float)
	{
		// this.playerHealth = realHealth;
		// healthBar.parent = realHealth * 50;
		this.intendedHealth = realHealth * 5000;
	}

	override public function update(e:Float)
	{
		super.update(e);
		playerHealth = FlxMath.lerp(intendedHealth, playerHealth, e * 114);
	}
}
