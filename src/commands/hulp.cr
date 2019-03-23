require "../Commands"

module CommandsHulp
	include Commands
	QUOTE = ->(args : Array(String), ctx : CommandContext) {
		[
			"May your lords be merciful!",
			"Submit to the three, the spirits, and thy lords.",
			"You. I've seen you. Let me see your face. You are the one from my dreams.",
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
		return "Ffs\nDon't do that again <@#{ctx[:issuer].id}>. Look at my flair\nI only need 0.001% of my power to wipe you out" unless ctx[:issuer].id == Config.f[:admin]
		"`\#TODO`"
	}
end
