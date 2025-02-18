::AP.Database.Generic.Common <-
{
	ExcludedInjuries =
	[
		"injury.missing_nose",
		"injury.missing_eye",
		"injury.missing_ear",
		"injury.missing_finger"
	],
	ExcludedItems =
	[
		"weapon.player_banner"
	],
	ItemPaths =
	{
		Elixir = "scripts/items/special/ap_elixir_item"
	},
	MoodChanges =
	{
		PermanentInjury = 1.35,
		StruckDown = 0.5
	},
	SkillPaths =
	{
		Avatar = "scripts/skills/traits/player_character_trait",
		Sickness = "scripts/skills/injury/sickness_injury"
	},
	ResourceStrings =
	[
		"Ammo",
		"ArmorParts",
		"Medicine",
		"Money"
	]
};