
_args = _this # 3;
_launcher = _args # 0;
_sectionName = _args # 1;
_module = _args # 2;

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

_targetClusterLogic = _targetClusterList # 0;
myTargetCluster = _targetClusterLogic;


_getTargetList = {

	_targetList = [];

	{
		private _syncedObj = _x;

		if (_syncedObj isKindOf "Logic") then {
			continue;
		};
		
		_targetList pushBack _x;

	} forEach (synchronizedObjects _targetClusterLogic);

	_targetList;

};

_targetList = call _getTargetList;

_index = 0;
_count = count(_targetList);

if (!(player getVariable ["ACE_hasEarPlugsIn", false])) then {
	_keybind = ["ACE3 Common", "ACE_Interact_Menu_SelfInteractKey"] call RCT7Bootcamp_fnc_getCBAKeybind;
	_earplugs = [call RCT7Bootcamp_fnc_getACESelfInfo, "and under Equipment, put your earplugs in"] joinString "";
	hint _earplugs;
};

	// TASK Icon: listen
waitUntil { player getVariable ["ACE_hasEarPlugsIn", false]; };

player call RCT7Bootcamp_fnc_sectionStart;

_firedCheck = { 
	if (firedCount > 0) then {
		_actionId = _this # 0;
		player removeAction _actionId;
		["Follow the instructions on your screen!\n\n Try again in:", 5] call RCT7Bootcamp_fnc_cooldownHint;
		continue; 
	};
	
};

_handleVehicleRespawn = {
	private ["_veh"];
	_unit = _this;

	_pos = getPosATL _unit;
	_dir = direction _unit;
	_type = typeOf _unit;

	sleep 3;
	_unit synchronizeObjectsRemove _targetList;
	deleteVehicleCrew _unit;
	deleteVehicle _unit;

	_veh = createVehicle [_type, _pos, [], 0, "FLY" ];
	_targetClusterLogic synchronizeObjectsAdd [_veh];

	if (_veh isKindOf "Air") then {
		_crew = createVehicleCrew _veh;
		_crew setBehaviour "CARELESS";
		_veh flyInHeight (_pos # 2);
	};

	_veh setPosATL _pos;
	_veh setDir _dir;
	_veh setVectorUp surfaceNormal position _veh;

	_veh call RCT7Bootcamp_fnc_unlimited;

	true;
	
};

_mag = (getArray (configFile >> "CfgWeapons" >> _launcher >> "magazines") # 0);
_magSize = getNumber (configfile >> "CfgMagazines" >> _mag >> "count");
_launcherAmmo = getText(configfile >> "CfgMagazines" >> _mag >> "ammo");

while {  _count isNotEqualTo _index  } do {
	
	_targetList = call _getTargetList;
	_target = _targetList select _index;

	[_launcher] call RCT7Bootcamp_fnc_handleLauncher;
	[ player ] call ACE_medical_treatment_fnc_fullHealLocal;
	player setDamage 0;




	_invalidTargetList=  + _targetList; // copy array
	_invalidTargetList deleteAt _index;
	

	shotsValid = 0;
	shotsInvalid = 0;
	_shotsMissed = 0;
	firedCount = 0;

	_time = time;

	if ( currentWeapon player isNotEqualTo secondaryWeapon player ) then {

		// TASK Icon: use
		hint (["A",call _getLauncherName,"was added to your inventory!\nEquip it!"] joinString " ");
		waitUntil { currentWeapon player isEqualTo secondaryWeapon player; };
		player call RCT7Bootcamp_fnc_targetHitValid;
	};


	if ((player ammo secondaryWeapon player) isEqualTo 0 ) then {

		// TASK Icon: interact
		hint (["Prepare your launcher with:\n", call compile (actionKeysNames "ReloadMagazine")] joinString "");
		waitUntil { (player ammo secondaryWeapon player) isEqualTo 1; };
		player call RCT7Bootcamp_fnc_targetHitValid;
	};

	_dist = player distance (_target);
	_distance = round(_dist / 50) * 50;

	_zeroingList = getArray(configfile >> "CfgWeapons" >> secondaryWeapon player >> "OpticsModes" >> "ironsight" >> "discreteDistance");

	if (count(_zeroingList) > 0 ) then {
		_minZeroing = _zeroingList # 0;
		_maxZeroing = _zeroingList # (count(_zeroingList) - 1);

		if (_distance < _minZeroing) then { _distance = _minZeroing; };
		if (_distance > _maxZeroing) then { _distance = _maxZeroing; };

		
		if (currentZeroing player isNotEqualTo _distance) then {
			// TASK Icon: target
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
	};

	// TASK Icon: danger
	hint "Check your backblast!";

	_actionId = player addAction ["<t color='#ffe0b5'>Backblast clear!</t>", {
		params ["_target", "_caller", "_actionId", "_arguments"];
		player removeAction _actionId;
		player call RCT7Bootcamp_fnc_targetHitValid;
	}];

	waitUntil { !(_actionId in (actionIDs player)) || firedCount > 0; };
	[_actionId] call _firedCheck;
	
	_target removemagazine "168Rnd_CMFlare_Chaff_Magazine";


	_descShort = getText(configfile >> "CfgWeapons" >> "rhs_weap_fim92" >> "descriptionShort");

	if (toLower "Surface-to-air" in toLower _descShort) then {
		// TASK Icon: destroy
		_minDistance = getNumber(configfile >> "CfgAmmo" >> _launcherAmmo >> "missileLockMinDistance");
  		hint (["Shoulder the launcher and aim it at the helicopter. When the beeping intensifies click to fire.\n\n
				Helicopters need to be at least", _minDistance, "away for a successful lock."] joinString " ");
		sleep 7;
	};



	_typeOfTarget = typeOf _target;
	_name = gettext (configfile >> "CfgVehicles" >> _typeOfTarget >> "displayName");

	_dir = round(([player, (_target)] call BIS_fnc_dirTo));

	// TASK Icon: destroy
	hint (["Shoot at the ", _name, "\n\n", "direction: ", _dir, "\n",  _distance, " meters"] joinString "");

	dbSectionName = [_sectionName,_typeOfTarget] joinString "-";


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

	
	_target addMPEventHandler ["MPHit", {
		params ["_unit", "_source", "_damage", "_instigator"];
			player call RCT7Bootcamp_fnc_targetHitValid;
			shotsValid = shotsValid + 1;
			_name =  gettext (configfile >> "CfgVehicles" >> typeOf _unit >> "displayName");
			[player, dbSectionName, "success", true] remoteExec ["RCT7_writeToDb", 2];
			[player, dbSectionName, "vehicle", _name] remoteExec ["RCT7_writeToDb", 2];
			[player, dbSectionName, "distance", _unit distance _instigator] remoteExec ["RCT7_writeToDb", 2];
			_unit removeAllMPEventHandlers "MPHit";
	}];
		
		
	waitUntil { _count isEqualTo shotsValid || _magSize isEqualTo firedCount };
	[player, dbSectionName, "time", time - _time - 2] remoteExec ["RCT7_writeToDb", 2];


	_index = _index + 1;


	if (player call _checkDamage) then {
		// TASK Icon: danger
		hint "You were to close to a structure, make sure to have at least 20 meters safe distance!";
		sleep 5;
	};

	if (getNumber(configfile >> "CfgWeapons" >> _launcher >> "rhs_disposable") isEqualTo 1) then { 
		// TASK Icon: rifle
		hint "This Launcher is disposabel. Equip your primary Weapon to drop it.";

		waitUntil {secondaryWeapon player isEqualTo ""};
	};


	_j = 0;
	waitUntil {
		sleep 1;
		_j = _j + 1;
		(damage _target) > 0 || _j > 2;
	};
	
	_shotsMissed = firedCount - (shotsInvalid + shotsValid);
	[player, dbSectionName, "shotsMissed", _shotsMissed] remoteExec ["RCT7_writeToDb", 2];

	{
		_x removeAllMPEventHandlers "MPHit";
		_x call _handleVehicleRespawn; 
	} forEach _targetList;
	
	
	if ( _count > _index ) then {
		["Next in", 3] call RCT7Bootcamp_fnc_cooldownHint;
	};
};

[ player ] call ACE_medical_treatment_fnc_fullHealLocal;
player setDamage 0;
player removeEventHandler ["Fired", _firedIndex];
player removeWeapon (secondaryWeapon player);

player call RCT7Bootcamp_fnc_sectionFinished;
hint "Traning completed!";