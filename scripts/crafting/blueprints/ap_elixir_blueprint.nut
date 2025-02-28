this.ap_elixir_blueprint <- ::inherit("scripts/crafting/blueprint",
{	// TODO: this could do with a refactor
	m = {},
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.ap_elixir";
		this.m.PreviewCraftable = ::new("scripts/items/special/ap_elixir_item");
		this.m.Cost = 500;
		local ingredients =
		[
			{Script = "scripts/items/misc/unhold_heart_item", Num = 1},
			{Script = "scripts/items/misc/ghoul_brain_item", Num = 1},
		];
		this.init(ingredients);
	}

	function onCraft( _stash )
	{
		_stash.add(::new("scripts/items/special/ap_elixir_item"));
	}
});