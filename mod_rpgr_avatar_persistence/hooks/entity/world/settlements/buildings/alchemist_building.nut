::AP.Patcher.hook("scripts/entity/world/settlements/buildings/alchemist_building", function( p )
{
	::AP.Patcher.wrap(p, "fillStash", function( _list, _stash, _priceMult, _allowDamagedEquipment = false )
	{
		if (::Math.rand(1, 100) > ::AP.Standard.getParameter("ElixirAlchemistChance"))
		{
			return;
		}

		this.m.Stash.add(::new(::AP.Utilities.getCommonField("ItemPaths").Elixir));
		this.m.Stash.sort();
	});
});