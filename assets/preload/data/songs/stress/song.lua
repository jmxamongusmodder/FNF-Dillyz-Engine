function onCreate()
	funkyLog('SONG LUAAAAA','normal') 
end

function onBeatHit()
	if curBeat == 184 then 
		funkyLog('beat time','normal') 
		funkyLog(tostring(stat_accuracy) .. ' accuracy','normal') 
		if stat_accuracy >= 75 then 
			spr_playAnim('dad','dialoguePrettyGood',true)
			sound_play('tankman_stress_good',1.15)
		else 
			spr_playAnim('dad','dialogueYoureUgly',true)
			sound_play('tankman_stress_bad',1.15)
		end
	end
end