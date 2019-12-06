/*
This file scans a template and returns items of soldiers...
Author: Sparker 30 september 2019
*/

#define pr private

params ["_t", ["_returnString", false]];

pr _catID = T_INF;
pr _catSize = T_INF_SIZE;
pr _classDefault = _t#_catID#0#0;
pr _subCatID = T_INF_DEFAULT + 1; // We don't want to process the default loadout/unit!
pr _group = createGroup WEST;

// Weapons and magazines for corresponding weapons
pr _primaryWeapons = [];
pr _primaryWeaponMagazines = [];

// Weapons and magazines for corresponding weapons
pr _secondaryWeapons = [];
pr _secondaryWeaponMagazines = [];

// Weapons and magazines for corresponding weapons
pr _handgunWeapons = [];
pr _handgunWeaponMagazines = [];

// Items are on their own
pr _primaryWeaponItems = [];
pr _secondaryWeaponItems = [];
pr _handgunWeaponItems = [];

// General items
pr _items = [];

// Vests
pr _vests = [];

// Backpacks
pr _backpacks = [];

// Loadout Weapons
// Each element is an array describing loadout weapons of a specific unit subcategory
pr _loadoutWeapons = [ [[], []] ];

while {_subCatID < _catSize} do {
	pr _classArray = _t#_catID#_subCatID;
	pr _primaryWeaponsThisSubcat = [];		// Primary and secondary weapons of this subcategory
	pr _secondaryWeaponsThisSubcat = [];
	{
		pr _classOrLoadout = _x;
		pr _isLoadout = [_classOrLoadout] call t_fnc_isLoadout;
		
		if (_isLoadout) then {
			//diag_log format ["LOADOUT: %1", _classOrLoadout];
		} else {
			//diag_log format ["CLASS:   %1", _classOrLoadout];
		};

		// Create a unit from which we will read data
		pr _hO = objNull;
		pr _unitClassName = _classDefault;

		if (!_isLoadout) then {
			_unitClassName = _classOrLoadout;
		};

		_hO = _group createUnit [_unitClassName, [0, 0, 0], [], 100, "CAN_COLLIDE"];

		if (_isLoadout) then {
			[_hO, _classOrLoadout] call t_fnc_setUnitLoadout;
		};

		// Process primary weapon
		pr _weap = primaryWeapon _hO;
		if (_weap != "") then {
			_weap = _weap call bis_fnc_baseWeapon;
			if (! (_weap in _primaryWeapons)) then {
				pr _items = primaryWeaponItems _hO;
				pr _mags = getArray (configfile >> "CfgWeapons" >> _weap >> "magazines");
				_primaryWeapons pushBack _weap;
				_primaryWeaponMagazines pushBack _mags;
				{ if (_x != "") then {_primaryWeaponItems pushBackUnique _x} } forEach _items;
			};
			_primaryWeaponsThisSubcat pushBackunique _weap;
		};

		// Process secondary weapon
		pr _weap = secondaryWeapon _hO;
		if (_weap != "") then {
			_weap = _weap call bis_fnc_baseWeapon;
			if (! (_weap in _secondaryWeapons)) then {
				pr _items = secondaryWeaponItems _hO;
				pr _mags = getArray (configfile >> "CfgWeapons" >> _weap >> "magazines");
				_secondaryWeapons pushBack _weap;
				_secondaryWeaponMagazines pushBack _mags;
				{ if (_x != "") then {_secondaryWeaponItems pushBackUnique _x} } forEach _items;
			};
			_secondaryWeaponsThisSubcat pushBackUnique _weap;
		};

		// Process handgun weapon
		pr _weap = handgunWeapon _hO;
		if (_weap != "") then {
			_weap = _weap call bis_fnc_baseWeapon;
			if (! (_weap in _handgunWeapons)) then {
				pr _items = handgunItems _hO;
				pr _mags = getArray (configfile >> "CfgWeapons" >> _weap >> "magazines");
				_handgunWeapons pushBack _weap;
				_handgunWeaponMagazines pushBack _mags;
				{ if (_x != "") then {_handgunWeaponItems pushBackUnique _x} } forEach _items;
			};
		};

		// Process items, except for map, watch, etc
		{
			_items pushBackUnique _x;
		} forEach ((assignedItems _hO) - ["ItemMap", "ItemWatch", "ItemCompass", "ItemRadio"]);

		// Process vest
		pr _vest = vest _hO;
		if (_vest != "") then {
			_vests pushBackUnique _vest;
		};

		// Process backpack
		pr _backpack = backpack _hO;
		if (_backpack != "") then {
			pr _backpackBase = _backpack call bis_fnc_basicbackpack;
			if (_backpackBase != "") then {
				_backpacks pushBackUnique _backpackBase;
			};
		};

		// Delete the unit
		deleteVehicle _hO;
	} forEach _classArray;

	pr _loadoutWeaponsThis = [_primaryWeaponsThisSubcat, _secondaryWeaponsThisSubcat];
	_loadoutWeapons set [_subCatID, _loadoutWeaponsThis];

	_subCatID = _subCatID + 1;
};

diag_log format ["Primary weapons:", _primaryWeapons];
diag_log format ["  %1", _primaryWeapons];
diag_log format ["  %1", _primaryWeaponMagazines];
diag_log format ["  %1", _primaryWeaponItems];

diag_log format ["Secondary weapons:", _secondaryWeapons];
diag_log format ["  %1", _secondaryWeapons];
diag_log format ["  %1", _secondaryWeaponMagazines];
diag_log format ["  %1", _secondaryWeaponItems];

diag_log format ["Handgun weapons:", _handgunWeapons];
diag_log format ["  %1", _handgunWeapons];
diag_log format ["  %1", _handgunWeaponMagazines];
diag_log format ["  %1", _handgunWeaponItems];

diag_log format ["Items:"];
diag_log format ["  %1", _items];

diag_log format ["Vests:"];
diag_log format ["  %1", _vests];

diag_log format ["Backpacks:"];
diag_log format ["  %1", _backpacks];


// Export to string

// Prepare arrays
pr _primary = [];
pr _secondary = [];
pr _handgun = [];

pr _i = 0;
while {_i < count _primaryWeapons} do {
	_primary pushBack [_primaryWeapons#_i, _primaryWeaponMagazines#_i];
	_i = _i + 1;
};

pr _i = 0;
while {_i < count _secondaryWeapons} do {
	_secondary pushBack [_secondaryWeapons#_i, _secondaryWeaponMagazines#_i];
	_i = _i + 1;
};

pr _i = 0;
while {_i < count _handgunWeapons} do {
	_handgun pushBack [_handgunWeapons#_i, _handgunWeaponMagazines#_i];
	_i = _i + 1;
};

pr _arrayExport = [_primary, _primaryWeaponItems, _secondary, _secondaryWeaponItems, _handgun, _handgunWeaponItems, _items, _vests, _backpacks];

// Export a human-readable string if requested
if (_returnString) then {
	pr _tab = toString [9];
	pr _nl = toString [10];

	// Function to convert array to a beautyful string with tabs and stuff
	_fnc_arrayToString = {
		params ["_array", "_str", "_level"];
		
		private _arraySize = count _array;

		for "_i" from 0 to (_level-1) do {_str = _str + _tab;}; // Add tabs
		_str = _str + "[";
		_str = _str + _nl;

		private _index = 0;
		while {_index < (count _array) } do {
			//_str = _str + _nl; // New line
			private _element = _array#_index;

			// Check element, if it's an array or not
			if (_element isEqualType "") then {
				// Add tabs plus one more tab
				for "_i" from 0 to (_level) do {_str = _str + _tab;};
				_str = _str + (format ['"%1"', _element]);
			} else {
				_str = [_element, _str, _level+1] call _fnc_arrayToString;
			};

			if (_index <= (_arraySize - 2)) then {
				_str = _str + ",";
			};
			_str = _str + _nl;

			_index = _index + 1;
		};

		//_str = _str + _nl;
		for "_i" from 0 to (_level-1) do {_str = _str + _tab;}; // Add tabs
		_str = _str + "]";
		
		_str
	};

	pr _strStart = 	(format ["/* Exported with t_fnc_processTemplateItems for template %1", _t select T_NAME]) + _nl + "Primary weapons" + _nl + "Primary weapon items" + _nl + 
					"Secondary weapons" + _nl + "Secondary weapon items" + _nl + "Handguns" + _nl + "Handgun items" + _nl + "General items */" + _nl;

	pr _str = [_arrayExport, _strStart, 0] call _fnc_arrayToString;
	_str
} else {
	// Otherwise we return an array
	[_arrayExport, _loadoutWeapons]
};