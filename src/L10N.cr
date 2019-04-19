require "ini"

module L10N
  extend self
  @@translations : Hash(String, Hash(String, String)) = INI.parse(File.read("l10n.ini")).transform_values do |val|
    val.transform_values do |string|
      string.gsub("\\n", "\n")
    end
  end
  Log.info("Loaded #{@@translations.size} languages: #{@@translations.keys}")

  def translate(lang, key)
    @@translations[lang][key]
  end

  def lang?(lang)
    @@translations.has_key? lang
  end

  macro do(key, *substs)
		%lang = if ctx.guild_id.nil?
			"en"
		else
			State.get(ctx.guild_id)[:language]
		end
		string = L10N.translate(%lang, {{key}})
		{% for subst in substs %}
		string = string.sub "%%", {{subst}}
		{% end %}
	end
end
