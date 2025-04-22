::AP.Utilities <-
{	// TODO: copied verbatim from wfr. needs closer inspection
	function getAttributeString( _fieldName )
	{
		return this.getStringField("Attributes")[_fieldName];
	}

	function getString( _fieldName )
	{
		return this.getStringField("Common")[_fieldName];
	}

	function getSkillString( _fieldName )
	{
		return this.getSkillStringField("Common")[_fieldName];
	}

	function getStringField( _fieldName )
	{
		return ::AP.Strings.getField("Generic", _fieldName);
	}

	function getSkillStringField( _fieldName )
	{
		return ::AP.Strings.getField("Skills", _fieldName);
	}
};