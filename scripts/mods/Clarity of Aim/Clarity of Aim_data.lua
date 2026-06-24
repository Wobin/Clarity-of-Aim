local mod = get_mod("Clarity of Aim")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "coa_enabled",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "coa_colour",
				type = "group",
				sub_widgets = {
					{ setting_id = "coa_colour_R", type = "numeric", default_value = 255, range = {0, 255} },
					{ setting_id = "coa_colour_G", type = "numeric", default_value = 0,   range = {0, 255} },
					{ setting_id = "coa_colour_B", type = "numeric", default_value = 0,   range = {0, 255} },
				},
			},
		},
	},
}
