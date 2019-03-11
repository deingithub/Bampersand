require "../Commands"

module CommandsHulp
	include Commands
	HULP = ->(args : Array(String), ctx : CommandContext) {
		[
			#~s
			"Don't do that again <@#{ctx[:issuer].id}>. Look at my flair\nI only need 0.001% of my power to wipe you out",
			"You see here, you rudely throw my words back in my face, among other petty nitpicks and your signature holier-than-thou attitude.",

			#Frens
			"<@344166495317655562> DING!",
			"It's Kat Appreciation Day\n:frog:\nMy frens",
			"Fundamentalism 2: Electric Mirror",
			"𝐁𝐋𝐎𝐁𝐁𝐈𝐄 :heart:",
			"\*inhales* SYSTEMD",
			"It's called beauty and it's art.",

			#Facts and Logic[tm]
			"**b& fact**\n[DATA EXPUNGED]",
			"**b& fact**\nChainsaws are friends, not food.",
			"**b& fact**\nHeterosexuality is overrated.",
			"**b& fact**\nIf you feel like you're superior to other people because you can code stuff, fuck you.",
			"**b& fact**\nHumanity fUCK YEAAAAAAH",
			"**b& fact**\nBlockchain as a service is the next big thing. Invest now.",

			#School
			"RAILWAY INSPECTION OFFICE MONACO! EVERYONE FREEZE, DROP YOUR WEAPONS! **I SAID DROP THEM!**",
			"The metaphysical Sabeth represented as one of the classical Furies is a clear reference to Faber's slowly fading composure. His death is inevitable.",
			"ａｓｂｅｓｔｏｓ",

			#Errors
			":x: `Ontological failure. Contact your network administrator.`",
			":x: `Have you tried turning it on and off again?`",
			":x: `404 witty reply not found.`",
			":x: `Cowode cowwuption detected, performing emewgency shuwutdown.`",

			#Misc Memery
			"https://i.imgur.com/GMwAhNR.png", #dosebot --discord
			"Has anyone really been far even as decided to use even go want to do look more like?",
			"https://i.imgur.com/pk2xS9m.jpg", #bonzenkartoffel!
			"https://cdn.discordapp.com/emojis/451143444367409193.gif?v=1", #party cat blob
			"https://cdn.discordapp.com/emojis/554436789612576769.png?v=1", #blob peek
			"https://i.imgur.com/qXL6XIr.png", #dab eu
			"FREUDE SCHÖNER GÖTTERFUNKEN, TOCHTER AUS ELYSIUM\nWIR BETRETEN FEUERTRUNKEN, HIMMLISCHE, DEIN HEILIGTUM",
			":musical_note: Sweet dreams are made-up things—",
			"Cease and desist.",
			"All systems nominal, thrust vectoring active. Prepare for take-off.",
			"You can't bweak a man the way you bweak a dog, ow a howse. The hawdew you beat a man, the tawwew he stands. To bweak owo a man's wiww, to bweak his spiwit, you have to bweak his mind. Men have this idea that we can fight with dignyity, that thewe's a pwopew owo way to kiww someonye. It's absuwd, its anyesthetic, we nyeed it to enduwe the bwoody howwow of muwdew. You must destwoy that idea. Show them what a messy, tewwibwe, thing it is to kiww a man, and then show them that you wewish in it. Shoot to wound, and then execute the wounded, buwn them, take them in cwose combat. Destwoy theiw pweconceptions of what a man is and you become theiw pewsonyaw monstew. When they feaw you, you become stwongew, you become bettew. But wet's nyevew fowget, it's a dispway, it's a postuwe, wike a wions woaw, ow a gowiwwa thumping at his chest. If you wose youwsewf uwu in the dispway, if you succumb to the howwow, then you become the monstew. You become weduced, nyot mowe than a man, but wess. And it couwd be fataw.",

			#vidya
			"May your lords be merciful!",
			"Submit to the three, the spirits, and thy lords.",
			"SPAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACE!",
			"Wow! You're the Grand Champion! I saw your fight against the Gray Prince! You're the best! Can I... Can I follow you around? I won't get in the way!",
			"You. I've seen you. Let me see your face. You are the one from my dreams.",
			"What a fool you are. I'm a god! How can you kill a god? What a grand and intoxicating innocence. How could you be so naïve? There is no escape, no recall or intervention will work in this place. Come, lay down your weapons, it is not too late for my mercy.",

			#The television[tm]
			"Intitiating Spin!",
			"If you can hear this, you're alone.\nThe only thing left of me is the sound of my voice.\nI don't know if any of us made it. Did we win? Did we lose? I don't know.\nBut either way, it's over.\nSo let me tell you who we were.\nLet me tell you who you are.\nSomeone once asked me if I had learned anything from it all. So let me tell you what I learned.\nI learned everyone dies alone.\nBut if you meant something to someone, if you helped someone, or loved someone… If even a single person remembers you. Then maybe you never really die.\nAnd maybe…\nThis isn't the end at all.﻿",
			"Unauthorized off-world activation.",
			"[ear-splitting klaxon]"
		].sample
	}
end
