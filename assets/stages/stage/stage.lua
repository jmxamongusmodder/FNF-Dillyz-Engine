function onCreate()
	funkyLog('Welcome to Stage Lua!','normal')
end

function onBeatHit()
	if curBeat % 8 == 7 and string.lower(songName) == 'bopeebo 'then
		funkyLog('Curbeat is ' .. curBeat .. '! (a multiple of 4!)','normal')
		playAnim('bf','hey',true)
		playAnim('gf','hey',true)
	end
end
