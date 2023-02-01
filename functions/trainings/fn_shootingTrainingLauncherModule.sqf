
_args = _this # 3;
_module = _args # 0;
_launcher = _args # 1;
_sectionName = _args # 2;

firedCount = 0;

_firedIndex = player addEventHandler ["Fired", {
	firedCount = firedCount + 1;
}];

_synchedObjects = synchronizedObjects _module;

private _triggerObj = nil;
private _targetList = [];


{
	if (_x isKindOf "LandVehicle") then {
		// It is a Target Cluster
		_targetList pushBack _x;
		continue;
	};
	
	if (_x isKindOf "Thing") then {
		_triggerObj = _x;
	};
	
} forEach _synchedObjects;


_checkDamage = {

	_unit = _this;
	_damageList = _unit getVariable ["ace_medical_bodypartdamage", [0,0,0,0,0,0]];
	{
		if (_x > 0) exitWith {
			[player, dbSectionName, "backblast_cleared", false ] remoteExec ["RCT7_writeToDb", 2];
			false;
		};
		 
		[player, dbSectionName, "backblast_cleared", true ] remoteExec ["RCT7_writeToDb", 2];


		
	} forEach _damageList;
	 
	true;
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
		Make backblast clear a required step - add an AI
		Get distance to target on hit
		Change Section to actual classname
		Time to finish the section
		Explain Ranging


*/
player call RCT7Bootcamp_fnc_sectionStart;

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
	if ((player ammo secondaryWeapon player) isEqualTo 0) then {
		_firesteps = [
			"Steps to fire: \n",
			"1. Equip your launcher",
			"2. Prepare your launcher with: ", call compile (actionKeysNames "ReloadMagazine"),
			"3. Be sure to check your backblast before firing!",
			"4. Call out 'Rocket, Rocket, Rocket!' and Fire",
			"\n\n-------\n\n"
		] joinString "\n";

		hint _firesteps;

		waitUntil {player ammo secondaryWeapon player isEqualTo 1};
	};

	_name = gettext (configfile >> "CfgVehicles" >> typeOf _target >> "displayName");
	_dist = player distance (_target);
	_distance = round(_dist * 0.1) * 10;
	_dir = round(([player, (_target)] call BIS_fnc_dirTo));

	hint ([_firesteps, "Shoot at the ", _name, "\n\n", "direction: ", _dir, "\n",  _distance, " meters"] joinString "");

	dbSectionName = [_sectionName,_name] joinString "-";

	{
		_x addMPEventHandler ["MPHit", {
				params ["_unit", "_source", "_damage", "_instigator"];
					player call RCT7Bootcamp_fnc_targetHitValid;
					shotsValid = shotsValid + 1;
					_name =  gettext (configfile >> "CfgVehicles" >> typeOf _unit >> "displayName");
					[player, dbSectionName, "success", true] remoteExec ["RCT7_writeToDb", 2];
					[player, dbSectionName, "vehicle", _name] remoteExec ["RCT7_writeToDb", 2];
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
	
	_damageCheck = player call _checkDamage;
	if (_damageCheck) then {
		player call RCT7Bootcamp_fnc_targetHitInvalid;
		hint "Step away from the wall stupid!";
	};
	sleep 2;

	(synchronizedObjects _module) apply { _x removeAllMPEventHandlers "MPHit"; };

	if (getNumber(configfile >> "CfgWeapons" >> _launcher >> "rhs_disposable") isEqualTo 1) then { 
		hint "This Launcher is disposabel, drop it.";

		waitUntil {secondaryWeapon player isEqualTo ""};
	};
	
	if ( _count > _index ) then {
		["Next in", 3] call RCT7Bootcamp_fnc_cooldownHint;
	};
};

player removeEventHandler ["Fired", _firedIndex];

player call RCT7Bootcamp_fnc_sectionFinished;
hint "Traning completed!";