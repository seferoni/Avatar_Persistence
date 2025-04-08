::AP.Integrations.MSU.Builders.Implicit <-
{
	function addSettingsImplicitly( _settingTable, _pageID )
	{
		local elements = [];
		local booleanSettings = [];

		foreach( settingID, settingGroup in _settingTable )
		{
			local settingElement = this.buildSettingElement(settingID, settingGroup);

			if (settingElement == null)
			{
				continue;
			}

			if (settingElement instanceof ::MSU.Class.BooleanSetting)
			{
				booleanSettings.push(settingElement);
				continue;
			}

			elements.push(settingElement);
		}

		elements.push(::AP.Integrations.MSU.createDivider(format("%sDivider", _pageID)));
		elements.extend(booleanSettings);

		foreach( element in elements )
		{
			::AP.Integrations.MSU.appendElementToPage(element, _pageID);
		}
	}

	function build()
	{
		this.buildPages();

		foreach( category, settingGroup in ::AP.Database.Settings )
		{
			local pageID = format("Page%s", category);
			this.addSettingsImplicitly(settingGroup, pageID);
		}
	}

	function buildPages()
	{
		local pageCategories = ::AP.Database.getSettingCategories();

		foreach( category in pageCategories )
		{
			local pageID = format("Page%s", category);
			local pageName = ::AP.Strings.Settings.Common[format("%sName", pageID)];
			::AP.Integrations.MSU.addPage(pageID, pageName);
		}
	}

	function buildSettingElement( _settingID, _settingValues )
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
			return null;
		}

		::AP.Integrations.MSU.buildDescription(settingElement);
		return settingElement;
	}

	function createBooleanSetting( _settingID, _settingValues )
	{
		return ::MSU.Class.BooleanSetting
		(
			_settingID,
			_settingValues.Default,
			::AP.Integrations.MSU.getElementName(_settingID)
		);
	}

	function createNumericalSetting( _settingID, _settingValues )
	{
		return ::MSU.Class.RangeSetting
		(
			_settingID,
			_settingValues.Default,
			_settingValues.Range[0],
			_settingValues.Range[1],
			_settingValues.Interval,
			::AP.Integrations.MSU.getElementName(_settingID)
		);
	}
};