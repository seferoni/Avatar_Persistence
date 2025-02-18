::AP.Integrations.MSU.Builders.Implicit <-
{
	function addSettingImplicitly( _settingID, _settingValues, _pageID )
	{
		local settingElement = null;

		switch (typeof _settingValues.Default)
		{
			case ("bool"): settingElement = this.createBooleanSetting(_settingID, _settingValues); break;
			case ("float"):
			case ("integer"): settingElement = this.createNumericalSetting(_settingID, _settingValues); break;
		}

		if (settingElement == null)
		{
			::AP.Standard.log(format("Passed element with ID %s had an unexpected default value type, skipping for implicit construction.", _settingID), true);
			return;
		}

		::AP.Integrations.MSU.buildDescription(settingElement);
		::AP.Integrations.MSU.appendElementToPage(settingElement, _pageID);
	}

	function build()
	{
		this.buildPages();

		foreach( category, settingGroup in ::AP.Database.Settings )
		{
			local pageID = format("Page%s", category);
			this.buildImplicitly(pageID, settingGroup);
		}
	}

	function buildPages()
	{
		local pageCategories = ::AP.Database.getSettingCategories();

		foreach( category in pageCategories )
		{
			local pageID = format("Page%s", category);
			local pageName = ::AP.Strings.Settings[format("%sName", pageID)];
			::AP.Integrations.MSU.addPage(pageID, pageName);
		}
	}

	function buildImplicitly( _pageID, _settingGroup )
	{
		foreach( settingID, settingValues in _settingGroup )
		{
			this.addSettingImplicitly(settingID, settingValues, _pageID);
		}
	}

	function createBooleanSetting( _settingID, _settingValues )
	{
		return ::MSU.Class.BooleanSetting(_settingID, _settingValues.Default, ::AP.Integrations.MSU.getElementName(_settingID));
	}

	function createNumericalSetting( _settingID, _settingValues )
	{
		return ::MSU.Class.RangeSetting(_settingID, _settingValues.Default, _settingValues.Range[0], _settingValues.Range[1], _settingValues.Interval, ::AP.Integrations.MSU.getElementName(_settingID));
	}
};