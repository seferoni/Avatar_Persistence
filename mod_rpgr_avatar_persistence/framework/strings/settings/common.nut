::AP.Strings.Settings.Common <-
{
	PageCommonName = "Common",

	AddElixirOnStartName = "Add Elixir On Start",
	AddElixirOnStartDescription = "Adds a special variant of the Elixir, called the Dilute Elixir, to the player stash on campaign start. Dilute Elixirs, besides having little monetary value, function only to confer avatar status to the character that consumes them. Applicable only for origins without a player character already present.",

	AmmoLossPercentageName = "Ammo Loss Percentage",
	AmmoLossPercentageDescription = "Determines the percentage of ammo lost upon defeat.",

	ArmorPartsLossPercentageName = "Tools Loss Percentage",
	ArmorPartsLossPercentageDescription = "Determines the percentage of tools lost upon defeat.",

	ElixirAlchemistChanceName = "Elixir Alchemist Chance",
	ElixirAlchemistChanceDescription = "Determines the percentage chance for Elixirs to be sold at alchemists per inventory refresh.",

	ElixirConfersAvatarStatusName = "Elixir Confers Avatar Status",
	ElixirConfersAvatarStatusDescription = "Determines whether or not Elixirs have the ability to confer player character status to selected non-player characters on consumption. Does not affect Dilute Elixirs.",

	EnableDefeatEventName = "Enable Defeat Event",
	EnableDefeatEventDescription = "Determines whether an event is fired upon defeat. This event serves as a diegetic log of item and resource losses.",

	EnableMomentumName = "Enable Momentum",
	EnableMomentumDescription = "Determines whether the Momentum effect is added to player characters. Momentum is a powerful effect exclusive to player characters, meant primarily to cater to campaigns with smaller roster sizes. Does nothing once the effect has been added for a given playthrough.",

	ItemRemovalCeilingName = "Item Removal Ceiling",
	ItemRemovalCeilingDescription = "Determines the maximum number of items that may be removed per instance of player defeat.",

	MedicineLossPercentageName = "Medicine Loss Percentage",
	MedicineLossPercentageDescription = "Determines the percentage of medicine lost upon defeat.",

	ModifyTooltipName = "Modify Trait Tooltip",
	ModifyTooltipDescription = "Determines whether the player character trait tooltip reflects changes brought about by Avatar Persistence.",

	MoneyLossPercentageName = "Money Loss Percentage",
	MoneyLossPercentageDescription = "Determines the percentage of money lost upon defeat.",

	MomentumRosterThresholdName = "Momentum Roster Threshold",
	MomentumRosterThresholdDescription = "Determines the roster size at and below which Momentum is Fortified. In this state, Momentum's attribute bonuses are doubled, with each sustained permanent injury further raising this bonus multiplier.",

	MomentumActiveScalingChanceName = "Momentum Active Scaling Chance",
	MomentumActiveScalingChanceDescription = "Determines the percentage chance for Momentum to scale an attribute upon killing an enemy with a higher-valued attribute than the player character.",

	MomentumPassiveScalingChanceName = "Momentum Passive Scaling Chance",
	MomentumPassiveScalingChanceDescription = "Determines the percentage chance for Momentum to scale defensive attributes (Melee Defense & Ranged Defense) at the start of each day. This parameter is also governed by the Passive Scaling Threshold.",

	MomentumPassiveScalingThresholdName = "Momentum Passive Scaling Threshold",
	MomentumPassiveScalingThresholdDescription = "Determines the threshold value of the base bonus a defensive attribute can have via Momentum above which further passive scaling is disabled. Has no effect on active scaling.",

	PermanentInjuryChanceName = "Permanent Injury Chance",
	PermanentInjuryChanceDescription = "Determines the percentage chance for the player character to suffer permanent injuries upon defeat.",

	PermanentInjuryThresholdName = "Permanent Injury Threshold",
	PermanentInjuryThresholdDescription = "Determines the threshold value of the number of permanent injuries the player character can have before persistence is lost.",

	RandomiseResourceLossName = "Randomise Resource Loss",
	RandomiseResourceLossDescription = "If this setting is enabled, the resource loss settings denote a ceiling rather than a fixed percentage value of resources removed upon defeat. Has no effect on item removal."
};