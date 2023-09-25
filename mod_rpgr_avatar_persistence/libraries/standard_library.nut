local AP = ::RPGR_Avatar_Persistence;
AP.Standard <-
{
    function cacheHookedMethod( _object, _functionName )
    {
        local naiveMethod = null,
        parentName = _object.SuperName;

        if (_functionName in _object)
        {
            naiveMethod = _object[_functionName];
        }

        return naiveMethod;
    }

    function concatenateArrays( ... )
    {
        local concatenatedArray = [];

        foreach( array in vargv )
        {
            concatenatedArray.extend(array);
        }

        return concatenatedArray;
    }

    function executeHookProcedure( _object, _function, _originalMethod, _argumentsArray, _procedures, _returnOverride = null )
    {
        local arguments = this.concatenateArrays([_object], _argumentsArray);

        switch(_procedures.HookProcedure)
        {
            case "wrapMethod": // Calls both methods in order, returns the original value. Generic wrapper.
                local orderedArray = this.generateOrderedArray(_function, originalMethod, _procedures.Order);
                return this.orderedCall(orderedArray, arguments, _procedures.ReturnSequence, _returnOverride);

            case "overrideMethod": // Calls and returns new method; if return value is null, calls and returns original method. Should only be used for boolean functions.
                local returnValue = _function.acall(arguments);
                return returnValue == null ? _originalMethod(arguments) : returnValue;

            case "overrideReturn": // Calls original method and passes result onto new method, returns new result. Ideal for tooltips.
                local newArguments = this.concatenateArrays([_object], _originalMethod.acall(arguments));
                return _function.acall(newArguments);

            case "overrideArguments": // Calls new method and passes result onto original method; if null, calls original with original arguments. Somewhat niche.
                local newArguments = this.concatenateArrays([_object], _function.acall(arguments));
                return newArguments == null ? (_returnOverride == null ? _originalMethod.acall(arguments) : _returnOverride) : _originalMethod.acall(newArguments);
        }
    }

    function generateTooltipTableEntry( _id, _type, _icon, _text )
    {
        local tableEntry =
        {
            id = _id,
            type = _type,
            icon = "ui/icons/" + _icon,
            text = _text
        }

        return tableEntry;
    }

    function generateOrderedArray( _firstEntry, _secondEntry, _procedure )
    {
        local orderedArray = [_firstEntry, _secondEntry];

        if (_procedure == "reverse")
        {
            orderedArray.reverse();
        }

        return orderedArray;
    }

    function getSetting( _settingID )
    {
        if (AP.MSUFound)
        {
            return AP.Mod.ModSettings.getSetting(_settingID).getValue();
        }

        if (!(_settingID in AP.Defaults))
        {
            this.logWrapper(format("Invalid settingID %s passed to getSetting, returning null.", _settingID), true);
            return null;
        }

        return AP.Defaults[_settingID];
    }

    function includeFiles( _path )
    {
        foreach( file in ::IO.enumerateFiles(_path) )
        {
            ::include(file);
        }
    }

    function logWrapper( _string, _isError = false )
    {
        if (_isError)
        {
            ::logError(format("[Avatar Persistence] %s", _string));
        }

        if (!this.getSetting("VerboseLogging"))
        {
            return;
        }

        ::logInfo(format("[Avatar Persistence] %s", _string));
    }

    function orderedCall( _functions, _argumentsArray, _procedure, _returnOverride = null )
    {
        local returnValues = [];

        foreach( functionDef in _functions )
        {
            returnValues.push(functionDef.acall(_argumentsArray)); // TODO: see what context object we need to be in
        }

        switch(_procedure)
        {
            case "returnFirst": return returnValues[0];
            case "returnSecond": return returnValues[1];
            default: return _returnOverride;
        }
    }

    function wrap( _object, _functionName, _function, _procedures = {Order = null, ReturnSequence = "returnFirst", HookProcedure = "wrap"}, _returnOverride = null )
    {
        local cachedMethod = this.cacheHookedMethod(_object, _functionName),
        parentName = _object.SuperName;

        _object[_functionName] = function( ... )
        {
            local originalMethod = cachedMethod == null ? this[parentName][_functionName] : cachedMethod;
            return ::RPGR_Avatar_Persistence.Standard.executeHookProcedure(_object, _function, originalMethod, vargv, _procedures, _returnOverride);
        }
    }
};

