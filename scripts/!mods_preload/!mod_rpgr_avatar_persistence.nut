::RPGR_Avatar_Persistence <-
{
	ID = "mod_rpgr_avatar_persistence",
	Name = "RPG Rebalance - Avatar Persistence",
	Version = "2.0.0",
	Internal =
	{
		TERMINATE = "__end"
	},
	Defaults =
	{
		AmmoLossPercentage = 40,
		ArmorPartsLossPercentage = 50,
		ElixirMarketplaceChance = 30,
		ElixirConfersAvatarStatus = true,
		PermanentInjuryChance = 66,
		PermanentInjuryThreshold = 0,
		ItemRemovalChance = 33,
		ItemRemovalCeiling = 6,
		LoseItemsUponDefeat = true,
		MedicineLossPercentage = 50,
		ModifyTooltip = true,
		MoneyLossPercentage = 85
	}
}

local AP = ::RPGR_Avatar_Persistence;
AP.Internal.MSUFound <- "MSU" in ::getroottable();
::include("mod_rpgr_avatar_persistence/libraries/standard_library.nut");

if (!AP.Internal.MSUFound)
{
	AP.Version = AP.Standard.parseSemVer(AP.Version);
}

::mods_registerMod(AP.ID, AP.Version, AP.Name);
::mods_queue(AP.ID, ">mod_msu", function()
{
	if (!AP.Internal.MSUFound)
	{
		return;
	}

	AP.Mod <- ::MSU.Class.Mod(AP.ID, AP.Version, AP.Name);
	local Defaults = AP.Defaults;

	local pageGeneral = AP.Mod.ModSettings.addPage("General"),
	pageItemLoss = AP.Mod.ModSettings.addPage("Item Loss"),
	pageElixir = AP.Mod.ModSettings.addPage("Elixir");

	local ammoLossPercentage = pageItemLoss.addRangeSetting("AmmoLossPercentage", Defaults.AmmoLossPercentage, 0, 100, 1, "Ammo Loss Percentage");
	ammoLossPercentage.setDescription("Determines the percentage of ammo lost upon defeat. Does nothing if Lose Items Upon Defeat is disabled.");

	local permanentInjuryChance = pageGeneral.addRangeSetting("PermanentInjuryChance", Defaults.PermanentInjuryChance, 0, 100, 1, "Permanent Injury Chance");
	permanentInjuryChance.setDescription("Determines the percentage chance for the player character to suffer permanent injuries upon defeat.");

	local permanentInjuryThreshold = pageGeneral.addRangeSetting("PermanentInjuryThreshold", Defaults.PermanentInjuryThreshold, 0, 8, 1, "Permanent Injury Threshold");
	permanentInjuryThreshold.setDescription("Determines the threshold value of the number of permanent injuries the player character can have before persistence is lost.");

	local itemRemovalCeiling = pageItemLoss.addRangeSetting("ItemRemovalCeiling", Defaults.ItemRemovalCeiling, 1, 10, 1, "Item Removal Ceiling");
	itemRemovalCeiling.setDescription("Determines the maximum number of items that may be removed per instance of player defeat. Does nothing if Lose Items Upon Defeat is disabled.");

	local elixirMarketplaceChance = pageElixir.addRangeSetting("ElixirMarketplaceChance", Defaults.ElixirMarketplaceChance, 0, 100, 1, "Elixir Marketplace Chance");
	elixirMarketplaceChance.setDescription("Determines the percentage chance for elixirs to be found in marketplaces.");

	local elixirConfersAvatarStatus = pageElixir.addBooleanSetting("ElixirConfersAvatarStatus", Defaults.ElixirConfersAvatarStatus, "Elixir Confers Avatar Status");
	elixirConfersAvatarStatus.setDescription("Determines whether or not the elixir has the ability to confer player character status to selected non-player characters on consumption.");

	local loseItemsUponDefeat = pageGeneral.addBooleanSetting("LoseItemsUponDefeat", Defaults.LoseItemsUponDefeat, "Lose Items Upon Defeat");
	loseItemsUponDefeat.setDescription("Determines whether items kept in the player's stash are removed at random upon defeat, in the case of persistence.");

	local modifyTooltip = pageGeneral.addBooleanSetting("ModifyTooltip", Defaults.ModifyTooltip, "Modify Tooltip");
	modifyTooltip.setDescription("Determines whether the player character trait tooltip reflects changes brought about by this mod.");

	local moneyLossPercentage = pageItemLoss.addRangeSetting("MoneyLossPercentage", Defaults.MoneyLossPercentage, 0, 100, 1, "Money Loss Percentage");
	moneyLossPercentage.setDescription("Determines the percentage of money lost upon defeat. Does nothing if Lose Items Upon Defeat is disabled.");

	local medicineLossPercentage = pageItemLoss.addRangeSetting("MedicineLossPercentage", Defaults.MedicineLossPercentage, 0, 100, 1, "Medicine Loss Percentage");
	medicineLossPercentage.setDescription("Determines the percentage of medicine lost upon defeat. Does nothing if Lose Items Upon Defeat is disabled.");

	local toolsLossPercentage = pageItemLoss.addRangeSetting("ArmorPartsLossPercentage", Defaults.ArmorPartsLossPercentage, 0, 100, 1, "Tools Loss Percentage");
	toolsLossPercentage.setDescription("Determines the percentage of tools lost upon defeat. Does nothing if Lose Items Upon Defeat is disabled.");
});

