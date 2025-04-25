::AP.Integrations.MSU <-
{
	function addPage( _pageID, _pageName = null )
	{
		return ::AP.Interfaces.MSU.ModSettings.addPage(_pageID, _pageName);
	}

	function appendElementToPage( _settingElement, _pageID )
	{
		this.getPage(_pageID).addElement(_settingElement);
	}

	function build()
	{
		this.Builders.Implicit.build();
	}

	function buildDescription( _settingElement )
	{
		local description = this.getElementDescription(_settingElement.getID());
		_settingElement.setDescription(description);
	}

	function createDivider( _elementID )
	{
		return ::MSU.Class.SettingsDivider(_elementID);
	}

	function createTables()
	{
		this.Builders <- {};
	}

	function getPage( _pageID )
	{
		return ::AP.Interfaces.MSU.ModSettings.getPage(_pageID);
	}

	function getPages()
	{
		return ::AP.Interfaces.MSU.ModSettings.getPanel().getPages();
	}

	function getElementDescription( _elementKey )
	{
		return this.getSettingString(format("%sDescription", _elementKey));
	}

	function getElementName( _elementKey )
	{
		return this.getSettingString(format("%sName", _elementKey));
	}

	function getSettingString( _fieldName )
	{
		return ::AP.Strings.getField("Settings", "Common")[_fieldName];
	}

	function initialise()
	{
		this.createTables();
		this.loadBuilders();
		this.build();
	}

	function loadBuilders()
	{
		::AP.Manager.includeFiles("mod_rpgr_avatar_persistence/framework/integrations/MSU/builders");
	}
};