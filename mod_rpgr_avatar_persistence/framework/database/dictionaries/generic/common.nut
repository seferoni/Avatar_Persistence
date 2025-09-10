::AP.Database.Generic.Common <-
{
	ExcludedInjuries =
	[
		"injury.missing_nose",
		"injury.missing_eye",
		"injury.missing_ear",
		"injury.missing_finger"
	],
	ItemPaths =
	{
		DiluteElixir = "scripts/items/special/ap_dilute_elixir_item",
		Elixir = "scripts/items/special/ap_elixir_item"
	},
	MoodChanges =
	{
		PermanentInjury = 1.35,
		StruckDown = 0.5
	},
	PermanentInjurySprites =
	[
		"permanent_injury_1",
		"permanent_injury_2",
		"permanent_injury_3",
		"permanent_injury_4"
	],
	ResourceKeys =
	[
		"Ammo",
		"ArmorParts",
		"Medicine",
		"Money"
	],
	SkillPaths =
	{
		Avatar = "scripts/skills/traits/player_character_trait",
		Sickness = "scripts/skills/injury/sickness_injury"
	}
};