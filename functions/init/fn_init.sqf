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

[player] remoteExec ["RCT7_getFromDb", 2];

waitUntil {
	!(isNil "RCT7playerData");
};

_completedSectionName = "CompletedSections";

_sectionList = [
	"Radio",
	"3DReport",
	"Shoothouse",
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

_teleportPlayer = {
	_name = param[0, "", [""]];
	_objName = ["StartPosition", _name] joinString "_";

	if (_name isEqualTo "" || isNil _objName) exitWith {};

	_obj = call compile (_objName);

	_pos = getPosATL _obj;
	player setPosATL _pos;
};

{
	_section = _x;

	if ([_section, _completedSectionName] call _isSectionCompleted) then {
		systemChat (["Section: [", _section, "] is completed"] joinString "");
		continue;
	};

	_section call _teleportPlayer;
	sleep 2;

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
			[FormationGroup] call RCT7Bootcamp_fnc_formation;
		};
		case "BoundingAlternate": {
			[UnitBoundingAlternate, "Alternate"] call RCT7Bootcamp_fnc_bounding;
		};
		case "BoundingSuccessive": {
			[UnitBoundingSuccessive, "Successive"] call RCT7Bootcamp_fnc_bounding;
		};
		case "Medical": {
			[UnitMedical] call RCT7Bootcamp_fnc_ACEMedical;
		};
		case "MedicalSelf": {
			[player] call RCT7Bootcamp_fnc_ACEMedical;
		};
	};

	systemChat (["Section [", _section, "] complete. Saving process..."] joinString "");
	[player, _completedSectionName, _section, true] remoteExec ["RCT7_writeToDb", 2];
	["Training Complete!\nNext Training in", 3] call RCT7Bootcamp_fnc_cooldownHint;
} forEach _sectionList;

["Bootcamp finished", true, 3] remoteExec ["BIS_fnc_endMission", 0, true];