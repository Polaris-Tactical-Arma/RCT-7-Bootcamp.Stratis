/*
	ORDER:
	. Radio
	. 3D Report
	. Shoothouse (targets, timer, delay for diagram)
	. Grenade
	. Map Training
	. Launcher
	. formation
	. Bounding
	. Medical
	
	
	TODO:
	- add check for backend connection
	
	
*/
RCT7playerData = nil;

[0, "BLACK", 1, 1] spawn BIS_fnc_fadeEffect;
titleText ["Initializing Bootcamp...", "PLAIN", 10];

[player] remoteExec ["RCT7_getFromDb", 2];

waitUntil {
	sleep 3;
	{
		publicVariable "RCT7playerData"
	} remoteExec ["call", 2];
	!(isNil "RCT7playerData");
};

titleText ["", "PLAIN", 1];

_completedSectionName = "CompletedSections";

_sectionList = [
	"Radio",
	"3DReport",
	// "Shoothouse", 
	"Grenade",
	"Map",
	"LauncherAT",
	"LauncherAA",
	"Formation",
	"BoundingAlternate",
	"BoundingSuccessive",
	"Medical",
	"MedicalSelf"
];

private _lastItem = _sectionList # (count _sectionList - 1);

_isSectionCompleted = {
	private _sectionToCheck = _this # 0;
	private _completedSectionsKey = _this # 1;
	private _data = RCT7playerData;

	if (count _data isEqualTo 0) exitWith {
		false
	};

	    private _dataArray = _data select 0 select 1; // Get the "data" array
	private _completedSections = [];

	{
		private _key = _x select 0;
		if (_key == _completedSectionsKey) then {
			_completedSections = _x select 1;
		};
	} forEach _dataArray;

	private _isCompleted = false;

	{
		private _section = _x select 0;
		private _completed = _x select 1;
		if (_section == _sectionToCheck && _completed) then {
			_isCompleted = true;
		};
	} forEach _completedSections;

	_isCompleted
};

{
	_section = _x;

	if ([_section, _completedSectionName] call _isSectionCompleted) then {
		systemChat (["Section: [", _section, "] is completed"] joinString "");
		continue;
	};

	_section call _teleportPlayer;
	[player, _section] call RCT7Bootcamp_fnc_teleportPlayer;

	switch (_section) do {
		case "Radio": {
			[] call RCT7Bootcamp_fnc_radioModule;
		};
		case "3DReport": {
			Gun3DReport call RCT7Bootcamp_fnc_3DReportTrainingModule;
		};
		case "Shoothouse": {
			[] call RCT7Bootcamp_fnc_shoothouse;
		};
		case "Grenade": {
			["rhs_mag_m67", "Grenade", GrenadeTraining] call RCT7Bootcamp_fnc_grenadeTrainingModule;
		};
		case "Map": {
			GunGridTraining call RCT7Bootcamp_fnc_mapTrainingModule;
		};
		case "LauncherAT": {
			["rhs_weap_M136", "AT", ATTraining] call RCT7Bootcamp_fnc_launcherTrainingModule;
		};
		case "LauncherAA": {
			["rhs_weap_fim92", "AA", AATraining] call RCT7Bootcamp_fnc_launcherTrainingModule;
		};
		case "Formation": {
			private _group = FormationGroup;
			[position ((units _group) # 0)] call RCT7Bootcamp_fnc_playerLookAtPos;

			[_group] call RCT7Bootcamp_fnc_formation;
		};
		case "BoundingAlternate": {
			[UnitBoundingAlternate, "Alternate"] call RCT7Bootcamp_fnc_bounding;
		};
		case "BoundingSuccessive": {
			[UnitBoundingSuccessive, "Successive"] call RCT7Bootcamp_fnc_bounding;
		};
		case "Medical": {
			private _unit = UnitMedical;
			[position _unit] call RCT7Bootcamp_fnc_playerLookAtPos;
			[_unit] call RCT7Bootcamp_fnc_ACEMedical;
		};
		case "MedicalSelf": {
			[player] call RCT7Bootcamp_fnc_ACEMedical;
		};
	};

	systemChat (["Section [", _section, "] complete. Saving process..."] joinString "");
	[[player, _completedSectionName, _section, true]] remoteExec ["RCT7_addToDBQueue", 2];

	if (_lastItem isEqualTo _section) exitWith {};
	titleText ["Training Complete!<br/>Starting next Training", "PLAIN", 0.4, false, true];
} forEach _sectionList;

hint "Bootcamp complete!";
sleep 3;
["Bootcamp finished", true, 3] remoteExec ["BIS_fnc_endMission", 0, true];