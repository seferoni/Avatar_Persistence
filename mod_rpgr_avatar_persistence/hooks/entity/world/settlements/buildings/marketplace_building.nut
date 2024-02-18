local AP = ::RPGR_Avatar_Persistence;
::mods_hookExactClass("entity/world/settlements/buildings/marketplace_building", function( _object )
{
	AP.Standard.wrap(_object, "fillStash", function( _list, _stash, _priceMult, _allowDamagedEquipment = false )
	{
		if (!this.m.Settlement.hasBuilding("building.temple"))
		{
			return;
		}

		if (::Math.rand(1, 100) > AP.Standard.getSetting("ElixirMarketplaceChance"))
		{
			return;
		}

		this.m.Stash.add(::new(AP.Persistence.Paths.Elixir));
		this.m.Stash.sort();
	});
});