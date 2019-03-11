require "../Commands"

module CommandsHulp
	include Commands
	HULP = ->(args : Array(String), ctx : CommandContext) {
		[
			#Tildes
			"Don't do that again <@#{ctx[:issuer].id}>. Look at my flair\nI only need 0.001% of my power to wipe you out",
			"You see here, you rudely throw my words back in my face, among other petty nitpicks and your signature holier-than-thou attitude.",

			#Frens
			"<@344166495317655562> DING!",
			"It's Kat Appreciation Day\n:frog:\nMy frens",

			#Facts and Logic[tm]
			"**b& fact**\n[DATA EXPUNGED]",
			"**b& fact**\nChainsaws are friends, not food.",
			"**b& fact**\nHeterosexuality is overrated.",
			"**b& fact**\nBlockchain as a service is the next big thing. Invest now.",

			#School
			"RAILWAY INSPECTION OFFICE MONACO! EVERYONE FREEZE, DROP YOUR WEAPONS! **I SAID DROP THEM!**",
			"The metaphysical Sabeth represented as classical Erinys is a clear reference to Faber's slowly fading composure. Death is inevitable.",

			#Errors
			":x: `Ontological failure. Contact your network administrator.`",
			":x: `Have you tried turning it on and off again?`",
			":x: `Cowode cowwuption detected, performing emewgency shuwutdown.`",

			#Misc Memery
			"https://i.imgur.com/GMwAhNR.png", #dosebot --discord
			"Has anyone really been far even as decided to use even go want to do look more like?",
			"https://i.imgur.com/pk2xS9m.jpg", #bonzenkartoffel!
			"FREUDE SCHÖNER GÖTTERFUNKEN, TOCHTER AUS ELYSIUM\nWIR BETRETEN FEUERTRUNKEN, HIMMLISCHE, DEIN HEILIGTUM",

			#vidya
			"May your lords be merciful!",
			"Submit to the three, the spirits, and thy lords.",
			"SPAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACE!",
			"Wow! You're the Grand Champion! I saw your fight against the Gray Prince! You're the best! Can I... Can I follow you around? I won't get in the way!",

			#The television[tm]
			"Intitiating Spin!",
			"If you can hear this, you're alone.\nThe only thing left of me is the sound of my voice.\nI don't know if any of us made it. Did we win? Did we lose? I don't know.\nBut either way, it's over.\nSo let me tell you who we were.\nLet me tell you who you are.\nSomeone once asked me if I had learned anything from it all. So let me tell you what I learned.\nI learned everyone dies alone.\nBut if you meant something to someone, if you helped someone, or loved someone… If even a single person remembers you. Then maybe you never really die.\nAnd maybe…\nThis isn't the end at all.﻿"
		].sample
	}
end
