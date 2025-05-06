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
		this.assignBlueprintKey(_properName);
		this.setIDByName(_properName);
		this.assignItemPath();
		this.buildIngredients(_properName);
	}

	function assignSpecialProperties()
	{
		this.m.BlueprintKey <- "";
		this.m.ItemPath <- null;
		this.m.Ingredients <- [];
	}

	function assignBlueprintKey( _properName )
	{
		this.m.BlueprintKey <- this.formatName(_properName, "_");
	}

	function assignItemPath()
	{
		this.m.ItemPath = ::AP.Utilities.getCommonField("ItemPaths")[this.m.BlueprintKey];
	}

	function buildIngredients( _properName )
	{	// TODO: don't typically like naively accessing the database handler's getField
		this.init(::AP.Database.getField("Blueprints", this.m.BlueprintKey).Ingredients);
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