this.foul_poultice_blueprint <- ::inherit("scripts/crafting/blueprint",
{
	m = {},
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.foul_poultice";
		this.m.PreviewCraftable = ::new("scripts/items/special/foul_poultice_item");
		this.m.Cost = 500;
		local ingredients = [
			{
				Script = "scripts/items/misc/unhold_heart_item",
				Num = 1
			},
			{
				Script = "scripts/items/misc/ghoul_brain_item",
				Num = 2
			},
            {
				Script = "scripts/items/misc/poison_gland_item",
				Num = 2
			}
		];
		this.init(ingredients);
	}

	function onCraft( _stash )
	{
		_stash.add(::new("scripts/items/special/foul_poultice_item"));
	}
});

