::AP.Patcher.hook("scripts/entity/world/settlements/buildings/marketplace_building", function( p )
{
	::AP.Patcher.wrap(p, "fillStash", function( _list, _stash, _priceMult, _allowDamagedEquipment = false )
	{
		if (!this.m.Settlement.hasBuilding("building.temple"))
		{
			return;
		}

		if (::Math.rand(1, 100) > ::AP.Standard.getParameter("ElixirMarketplaceChance"))
		{
			return;
		}

		this.m.Stash.add(::new(::AP.Utilities.getField("ItemPaths").Elixir));
		this.m.Stash.sort();
	});
});