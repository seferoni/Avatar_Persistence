::AP.Database.Generic.Skills <-
{
	MomentumAttributes =
	[
		"MeleeSkill",
		"RangedSkill",
		"MeleeDefense",
		"RangedDefense",
		"Bravery",
		"Initiative",
		"Stamina"
	],
	MomentumSpecialEffects =
	[
		{
			EnemiesSlain = 35,
			Property = "Hitpoints",
			Offset = 20
		},
		{
			EnemiesSlain = 80,
			Property = "ActionPoints",
			Offset = 1
		},
		{
			EnemiesSlain = 150,
			Property = "FatigueRecoveryRate",
			Offset = 4
		},
		{
			EnemiesSlain = 260,
			Property = "Hitpoints",
			Offset = 20
		},
		{
			EnemiesSlain = 400,
			Property = "ActionPoints",
			Offset = 1
		},
	]
};