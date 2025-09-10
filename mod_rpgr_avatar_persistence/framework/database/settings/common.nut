::AP.Database.Settings.Common <-
{
	AddElixirOnStart =
	{
		Default = false,
	},
	AmmoLossPercentage =
	{
		Default = 40,
		Range = [0, 100],
		Interval = 1
	},
	ArmorPartsLossPercentage =
	{
		Default = 100,
		Range = [1, 100],
		Interval = 1
	},
	ElixirConfersAvatarStatus =
	{
		Default = true,
	},
	ElixirAlchemistChance =
	{
		Default = 66,
		Range = [0, 100],
		Interval = 1
	},
	EnableDefeatEvent =
	{
		Default = true
	},
	ItemRemovalCeiling =
	{
		Default = 6,
		Range = [1, 10],
		Interval = 1,
	},
	LoseItemsUponDefeat =
	{
		Default = true,
	},
	ModifyTooltip =
	{
		Default = true,
	},
	MoneyLossPercentage =
	{
		Default = 100,
		Range = [1, 100],
		Interval = 1
	},
	MedicineLossPercentage =
	{
		Default = 100,
		Range = [1, 100],
		Interval = 1
	},
	PermanentInjuryChance =
	{
		Default = 20,
		Range = [0, 100],
		Interval = 1
	},
	PermanentInjuryThreshold =
	{
		Default = 2,
		Range = [0, 7],
		Interval = 1
	},
	RandomiseResourceLoss =
	{
		Default = true
	}
};