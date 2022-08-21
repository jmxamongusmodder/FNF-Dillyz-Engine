--function onCreate()
--	funkyLog('Welcome to Stage Lua!','normal')
--end

function onBeatHit()
	if curBeat % 8 == 7 then-- and string.lower(songName) == 'bopeebo' then
		spr_playAnim('bf','hey',true)
		spr_playAnim('gf','hey',true)
	end
end
