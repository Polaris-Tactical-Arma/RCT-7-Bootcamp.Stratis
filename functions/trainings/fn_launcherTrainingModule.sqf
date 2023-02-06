
_args = _this # 3;
_launcher = _args # 0;

firedCount = 0;

_firedIndex = player addEventHandler ["Fired", {
	firedCount = firedCount + 1;
}];

_syncedObjects = synchronizedObjects _module;

private _triggerObj = nil;
private _targetController = nil;
private _targetClusterList = [];


{
	private _syncedObj = _x;

	if (_syncedObj isKindOf "Logic" && ["TargetCluster", str _syncedObj] call BIS_fnc_inString) then {
		// It is a Target Cluster
		_targetClusterList pushBack _syncedObj;
		continue;
	};
	
	if (_syncedObj isKindOf "Logic" && ["TargetController", str _syncedObj] call BIS_fnc_inString) then {
		_targetController = _syncedObj;
		continue;
	};

	if (_syncedObj isKindOf "Thing") then {
		_triggerObj = _syncedObj;
	};
	

} forEach _syncedObjects;

_checkDamage = {

	_unit = _this;
	private _hasDamage = false;
	_damageList = _unit getVariable ["ace_medical_bodypartdamage", [0,0,0,0,0,0]];
	{
		
		if (_x > 0) exitWith {
			[player, dbSectionName, "backblast_cleared", false ] remoteExec ["RCT7_writeToDb", 2];
			_hasDamage = true;
		};
		 
		[player, dbSectionName, "backblast_cleared", true ] remoteExec ["RCT7_writeToDb", 2];
		
	} forEach _damageList;
	 
	_hasDamage;
};

_getLauncherName = {
	gettext (configfile >> "CfgWeapons" >> secondaryWeapon player >> "displayName");
};

_index = 0;
_count = count(_targetList);

if (!(player getVariable ["ACE_hasEarPlugsIn", false])) then {
	_keybind = ["ACE3 Common", "ACE_Interact_Menu_SelfInteractKey"] call RCT7Bootcamp_fnc_getCBAKeybind;
	_earplugs = ["Open ACE Self-Interaction with\n[", _keybind, "]\nand under Equipment, put your earplugs in"] joinString "";
	hint _earplugs;
};

waitUntil { player getVariable ["ACE_hasEarPlugsIn", false]; };


/*
	TODO:
		Time to finish the section

*/
player call RCT7Bootcamp_fnc_sectionStart;

_firedCheck = { 
	if (firedCount > 0) then {
		_actionId = _this # 0;
		player removeAction _actionId;
		["Follow the instructions on your screen!\n\n Try again in:", 5] call RCT7Bootcamp_fnc_cooldownHint;
		continue; 
	};
	
};

_magSize = getNumber (configfile >> "CfgMagazines" >> (getArray (configFile >> "CfgWeapons" >> _launcher >> "magazines") # 0) >> "count");

while {  _count isNotEqualTo _index  } do {
	
	[_launcher] call RCT7Bootcamp_fnc_handleLauncher;
	_target = _targetList select _index;

	[ player ] call ACE_medical_treatment_fnc_fullHealLocal;
	player setDamage 0;



	_invalidTargetList=  + _targetList; // copy array
	_invalidTargetList deleteAt _index;
	

	shotsValid = 0;
	shotsInvalid = 0;
	_shotsMissed = 0;
	firedCount = 0;

	_firesteps = "";

	if ( currentWeapon player isNotEqualTo secondaryWeapon player ) then {

		hint (["A",call _getLauncherName,"was added to your inventory!\nEquip it!"] joinString " ");
		waitUntil { currentWeapon player isEqualTo secondaryWeapon player; };
		player call RCT7Bootcamp_fnc_targetHitValid;
	};


	if ((player ammo secondaryWeapon player) isEqualTo 0 ) then {

		hint (["Prepare your launcher with:\n", call compile (actionKeysNames "ReloadMagazine")] joinString "");
		waitUntil { (player ammo secondaryWeapon player) isEqualTo 1; };
		player call RCT7Bootcamp_fnc_targetHitValid;
	};

	_dist = player distance (_target);
	_distance = round(_dist / 50) * 50;
	
	if (currentZeroing player isNotEqualTo _distance) then {
		hint ([
			"Zero your gun on:\n",
			_distance,
			"\n\n",
			"Zeroing Up:\n", ((actionKeysNames "zeroingUp") splitString """" joinString ""), "\n\n",
			"Zeroing Down:\n", ((actionKeysNames "zeroingDown") splitString """" joinString "")
			] joinString "");
		waitUntil { currentZeroing player isEqualTo _distance || firedCount > 0; };
		player call RCT7Bootcamp_fnc_targetHitValid;
	};
	call _firedCheck;


	hint "Check your backblast!";

	_actionId = player addAction ["<t color='#ffe0b5'>Backblast clear!</t>", {
		params ["_target", "_caller", "_actionId", "_arguments"];
		player removeAction _actionId;
		player call RCT7Bootcamp_fnc_targetHitValid;
	}];

	waitUntil { !(_actionId in (actionIDs player)) || firedCount > 0; };
	[_actionId] call _firedCheck;
	

	_typeOfTarget = typeOf _target;
	_name = gettext (configfile >> "CfgVehicles" >> _typeOfTarget >> "displayName");
	_dir = round(([player, (_target)] call BIS_fnc_dirTo));

	hint (["Shoot at the ", _name, "\n\n", "direction: ", _dir, "\n",  _distance, " meters"] joinString "");

	dbSectionName = [_sectionName,_typeOfTarget] joinString "-";

	{
		_x addMPEventHandler ["MPHit", {
				params ["_unit", "_source", "_damage", "_instigator"];
					player call RCT7Bootcamp_fnc_targetHitValid;
					shotsValid = shotsValid + 1;
					_name =  gettext (configfile >> "CfgVehicles" >> typeOf _unit >> "displayName");
					[player, dbSectionName, "success", true] remoteExec ["RCT7_writeToDb", 2];
					[player, dbSectionName, "vehicle", _name] remoteExec ["RCT7_writeToDb", 2];
					[player, dbSectionName, "distance", _unit distance _instigator] remoteExec ["RCT7_writeToDb", 2];
					_unit removeAllMPEventHandlers "MPHit";
			}];
		
	} forEach _targetList;


	{
			_invalidTarget = _x;
			_invalidTarget addMPEventHandler ["MPHit", {
				params ["_unit", "_source", "_damage", "_instigator"];
				// invalid
				if (_unit animationPhase "terc" isEqualTo 0) then {
					player call RCT7Bootcamp_fnc_targetHitInvalid;
					shotsInvalid = shotsInvalid + 1;
					_name =  gettext (configfile >> "CfgVehicles" >> typeOf _unit >> "displayName");
					[player, dbSectionName, "success", false] remoteExec ["RCT7_writeToDb", 2];
					[player, dbSectionName, "vehicle", _name] remoteExec ["RCT7_writeToDb", 2];
					[player, dbSectionName, "distance", _unit distance _instigator] remoteExec ["RCT7_writeToDb", 2];
					_unit removeAllMPEventHandlers "MPHit";
				};

			}];
		
	} forEach _invalidTargetList;

	waitUntil { _count isEqualTo shotsValid || _magSize isEqualTo firedCount };


	_index = _index + 1;
	[] spawn {
		sleep 2;
		_shotsMissed = firedCount - (shotsInvalid + shotsValid);
		[player, dbSectionName, "shotsMissed", _shotsMissed] remoteExec ["RCT7_writeToDb", 2];
	};
	
	if (player call _checkDamage) then {
		hint "You were to close to a structure, make sure to have at least 20 meters safe distance!";
		sleep 5;
	};

	(synchronizedObjects _module) apply { _x removeAllMPEventHandlers "MPHit"; };

	if (getNumber(configfile >> "CfgWeapons" >> _launcher >> "rhs_disposable") isEqualTo 1) then { 
		hint "This Launcher is disposabel. Equip your primary Weapon to drop it.";

		waitUntil {secondaryWeapon player isEqualTo ""};
	};
	
	if ( _count > _index ) then {
		["Next in", 3] call RCT7Bootcamp_fnc_cooldownHint;
	};
};

player removeEventHandler ["Fired", _firedIndex];

player call RCT7Bootcamp_fnc_sectionFinished;
hint "Traning completed!";