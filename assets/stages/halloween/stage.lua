function onCreate() 
	spr_init("bg_static",-200,-100)
	spr_init("bg_overlay",-200,-100)
	
	spr_loadSpriteSheet("bg_static", "Halloween BG", true)
	spr_loadSpriteSheet("bg_overlay", "Halloween BG", true)
	
	spr_addAnimationByPrefix("bg_static", "static", "HBG Static0", 24, true)
	spr_addAnimationByPrefix("bg_overlay", "strike", "HBG Strike Cut0", 24, true)
	
	spr_playAnim("bg_static", "static", true)
	
	spr_add("bg_static")
	spr_add("bg_overlay")
	spr_visible("bg_overlay",false)
end

local strikeBeat = 0
local strikeOffset = 8

function onBeatHit() 
	if random_bool(10) and curBeat > strikeBeat + strikeOffset then 
		sound_play("lightningStrike" .. tostring(random_int(0,1)), 1)
		spr_playAnim("bg_overlay", "strike", true)
		strikeBeat = curBeat
		strikeOffset = random_int(0, 24)
		spr_playAnim("bf", "scared", true)
		spr_playAnim("gf", "scared", true)
		spr_visible("bg_overlay",true)
		camera_flash("camGame",0.5)
	end
end