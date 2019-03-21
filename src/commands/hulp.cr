require "../Commands"

module CommandsHulp
	include Commands
	QUOTE = ->(args : Array(String), ctx : CommandContext) {
		[
			"May your lords be merciful!",
			"Submit to the three, the spirits, and thy lords.",
			"You. I've seen you. Let me see your face. You are the one from my dreams.",
			"What a fool you are. I'm a god! How can you kill a god? What a grand and intoxicating innocence. How could you be so naïve? There is no escape, no recall or intervention will work in this place. Come, lay down your weapons, it is not too late for my mercy.",
			"Intitiating Spin!",
			"Hallowed are the Ori.",
			"If you can hear this, you're alone.
			The only thing left of me is the sound of my voice.
			I don't know if any of us made it. Did we win? Did we lose? I don't know.
			But either way, it's over.
			So let me tell you who we were.
			Let me tell you who you are.
			Someone once asked me if I had learned anything from it all. So let me tell you what I learned. I learned everyone dies alone.
			But if you meant something to someone, if you helped someone, or loved someone… If even a single person remembers you. Then maybe you never really die.
			And maybe? …This isn't the end at all.﻿",
			"Unauthorized off-world activation!",
			"If you feel like you're superior to other people solely because you can code stuff, fuck you.",
			"Do not go gentle into that good night,
			Old age should burn and rave at close of day;
			Rage, rage against the dying of the light.
			Though wise men at their end know dark is right,
			Because their words had forked no lightning they
			Do not go gentle into that good night.
			Good men, the last wave by, crying how bright
			Their frail deeds might have danced in a green bay,
			Rage, rage against the dying of the light.
			Wild men who caught and sang the sun in flight,
			And learn, too late, they grieved it on its way,
			Do not go gentle into that good night.
			Grave men, near death, who see with blinding sight
			Blind eyes could blaze like meteors and be gay,
			Rage, rage against the dying of the light.
			And you, my father, there on the sad height,
			Curse, bless, me now with your fierce tears, I pray.
			Do not go gentle into that good night.
			Rage, rage against the dying of the light."
		].sample
	}
	HULP = ->(args : Array(String), ctx : CommandContext) {
		[
			"Don't do that again <@#{ctx[:issuer].id}>. Look at my flair\nI only need 0.001% of my power to wipe you out",
			"You see here, you rudely throw my words back in my face, among other petty nitpicks and your signature holier-than-thou attitude.",
			"RAILWAY INSPECTION OFFICE VIENNA! EVERYONE FREEZE, DROP YOUR WEAPONS! **I SAID DROP THEM!**",
			#Frens
			"<@344166495317655562> DING!",
			"It's Kat Appreciation Day\n:frog:\nMy frens",
			"Fundamentalism 2: Electric Mirror",
			"𝐁𝐋𝐎𝐁𝐁𝐈𝐄 :heart:",
			"\\*inhales* SYSTEMD",
			"It's called beauty and it's art.",
			#Facts and Logic[tm]
			"**B& FACT**\n[DATA EXPUNGED]",
			"**B& FACT**\nChainsaws are friends, not food.",
			"**B& FACT**\nHeterosexuality is overrated.",
			"**B& FACT**\nYou can reduce your invoices easily using many chemical elements.",
			"**B& FACT**\nHumanity fUCK YEAAAAAAH",
			"**B& FACT**\nBlockchain as a service is the next big thing. Invest now.",
			"**B& FACT**\ndeing is actually an enlightened centrist",
			"**B& FACT**\nPotatoes are the superior provider of starch.",
			"**B& FACT**\nBlobs can form pseudopods to manipulate objects or [REDACTED ON GROUNDS OF YOUTH PROTECTION]",
			"**B& FACT**\nSure, socialism looks nice on paper. But in reality, every attempt at it is foiled by the CIA",
		].sample
	}
end
