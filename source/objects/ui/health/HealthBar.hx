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

	var iconLeft:HealthIcon;
	var iconRight:HealthIcon;

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

		iconLeft = new HealthIcon(0, 0, 'default', false);
		iconRight = new HealthIcon(0, 0, 'default', false);
		iconRight.flipX = true;

		add(iconLeft);
		add(iconRight);

		updateHealth(1);
	}

	public function updateHealthIconsAndColors(charLeft:Character, charRight:Character)
	{
		remove(healthBar);
		remove(healthBarOverlay);
		remove(iconLeft);
		remove(iconRight);

		healthBar.createFilledBar(FlxColor.fromRGB(charLeft.healthIconColors[0], charLeft.healthIconColors[1], charLeft.healthIconColors[2]),
			FlxColor.fromRGB(charRight.healthIconColors[0], charRight.healthIconColors[1], charRight.healthIconColors[2]));

		healthBar.scale.x = 1.125;
		healthBarOverlay.scale.x = 1.125;

		iconLeft.reloadHealthIconByIcon(charLeft.healthIcon);
		iconRight.reloadHealthIconByIcon(charRight.healthIcon);

		add(healthBar);
		add(healthBarOverlay);
		add(iconLeft);
		add(iconRight);

		iconLeft.y = (healthBarOverlay.y + healthBarOverlay.height / 2) - iconLeft.height / 2;
		iconRight.y = (healthBarOverlay.y + healthBarOverlay.height / 2) - iconRight.height / 2;
		iconRight.flipX = true;
	}

	public function updateHealth(realHealth:Float)
	{
		// this.playerHealth = realHealth;
		// healthBar.parent = realHealth * 50;
		this.intendedHealth = realHealth * 5000;

		var isLeft:String = 'Neutral';
		var isRight:String = 'Neutral';

		if (this.intendedHealth / 100 <= 20)
		{
			isRight = 'Losing';
			isLeft = 'Winning';
		}
		else if (this.intendedHealth / 100 >= 80)
		{
			isRight = 'Winning';
			isLeft = 'Losing';
		}

		iconLeft.updateState(isLeft);
		iconRight.updateState(isRight);
	}

	override public function update(e:Float)
	{
		super.update(e);
		playerHealth = FlxMath.lerp(intendedHealth, playerHealth, e * 114);

		var iconLerp:Float = e * 114;
		iconLeft.setGraphicSize(Std.int(FlxMath.lerp(150, iconLeft.width, iconLerp)));
		iconRight.setGraphicSize(Std.int(FlxMath.lerp(150, iconLeft.width, iconLerp)));
		iconLeft.updateHitbox();
		iconRight.updateHitbox();

		iconLeft.y = (healthBarOverlay.y + healthBarOverlay.height / 2) - iconLeft.height / 2;
		iconRight.y = (healthBarOverlay.y + healthBarOverlay.height / 2) - iconRight.height / 2;

		var barMid:Float = healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01);
		iconLeft.x = healthBar.x + barMid - iconLeft.width;
		iconRight.x = healthBar.x + barMid;
	}

	public function iconBop()
	{
		iconLeft.setGraphicSize(180);
		iconRight.setGraphicSize(180);
		iconLeft.updateHitbox();
		iconRight.updateHitbox();
	}
}
