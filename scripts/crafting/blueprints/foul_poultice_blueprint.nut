this.foul_poultice_blueprint <- ::inherit("scripts/crafting/blueprint",
{
	m = {},
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.foul_poultice";
		this.m.PreviewCraftable = ::new("scripts/items/special/foul_poultice_item");
		this.m.Cost = 500;
		local modSettings = ::RPGR_Avatar_Persistence.Mod.ModSettings;
		local ingredients = [
			{
				Script = "scripts/items/misc/unhold_heart_item",
				Num = modSettings.getSetting("PoulticeUnholdHeartCount").getValue()
			}
		];

		if (modSettings.getSetting("PoulticeGhoulBrainCount").getValue() > 0)
		{
			ingredients.push({
				Script = "scripts/items/misc/ghoul_brain_item",
				Num = modSettings.getSetting("PoulticeGhoulBrainCount").getValue()
			});
		}

		if (modSettings.getSetting("PoulticePoisonGlandCount").getValue() > 0)
		{
			ingredients.push({
				Script = "scripts/items/misc/poison_gland_item",
				Num = modSettings.getSetting("PoulticePoisonGlandCount").getValue()
			});
		}

		this.init(ingredients);
	}

	function onCraft( _stash )
	{
		_stash.add(::new("scripts/items/special/foul_poultice_item"));
	}
});

