this.ap_blueprint <- ::inherit("scripts/crafting/blueprint",
{
	m = {},
	function create()
	{
		this.blueprint.create();
		this.assignGenericProperties();
		this.assignSpecialProperties();
		this.buildPreview();
	}

	function assignGenericProperties()
	{
		return;
	}

	function assignPropertiesByName( _properName )
	{
		this.setIDByName(_properName);
		this.buildIngredients(_properName);
	}

	function assignSpecialProperties()
	{
		this.m.ItemPath <- null;
		this.m.Ingredients <- [];
	}

	function buildIngredients( _properName )
	{
		local key = this.formatName(_properName, "_");
		this.init(::AP.Database.getField("Blueprints", key).Ingredients);
	}

	function buildPreview()
	{
		if (this.m.ItemPath == null)
		{
			return;
		}

		this.m.PreviewCraftable = ::new(this.m.ItemPath);
	}

	function formatName( _properName, _replacementSubstring = "" )
	{
		return ::AP.Standard.replaceSubstring(" ", _replacementSubstring, _properName);
	}

	function onCraft( _stash )
	{
		_stash.add(::new(this.m.ItemPath));
	}

	function setIDByName( _properName )
	{
		local formattedName = this.formatName(_properName, "_");
		this.m.ID = format("blueprint.ap_%s", formattedName.tolower());
	}
});