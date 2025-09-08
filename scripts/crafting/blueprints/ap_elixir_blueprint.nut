this.ap_elixir_blueprint <- ::inherit("scripts/crafting/ap_blueprint",
{
	m = {},
	function create()
	{
		this.ap_blueprint.create();
		this.assignPropertiesByName("Elixir");
	}

	function assignGenericProperties()
	{
		this.ap_blueprint.assignGenericProperties();
		this.m.Cost = 250;
	}

	function assignSpecialProperties()
	{
		this.ap_blueprint.assignSpecialProperties();
		this.m.ItemPath = ::AP.Utilities.getCommonField("ItemPaths").Elixir;
	}

	function isCraftable()
	{
		if (!::World.Retinue.hasFollower("follower.alchemist"))
		{
			return false;
		}

		return this.ap_blueprint.isCraftable();
	}

	function isQualified()
	{
		if (!::World.Retinue.hasFollower("follower.alchemist"))
		{
			return false;
		}

		return this.ap_blueprint.isQualified();
	}
});