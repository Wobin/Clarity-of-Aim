return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Clarity of Aim` encountered an error loading the Darktide Mod Framework.")

		new_mod("Clarity of Aim", {
			mod_script       = "Clarity of Aim/scripts/mods/Clarity of Aim/Clarity of Aim",
			mod_data         = "Clarity of Aim/scripts/mods/Clarity of Aim/Clarity of Aim_data",
			mod_localization = "Clarity of Aim/scripts/mods/Clarity of Aim/Clarity of Aim_localization",
		})
	end,
	packages = {},
}
