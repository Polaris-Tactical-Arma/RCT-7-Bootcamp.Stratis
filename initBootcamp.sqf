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
	- add teleporter
	- add bounding box for shooting (teleport back if too far)
	- add check for backend connection
	
	FormationGroup call RCT7Bootcamp_fnc_formation
	
*/

_completedSectionName = "CompletedSections";

_sectionList = [
	"Radio",
	"3DReport",
	"Shoothouse",
	"Grenade",
	"Map",
	"Launcher",
	"Formation",
	"Bounding",
	"Medical",
	"MedicalSelf"
];

_isSectionCompleted = {
	private _sectionToCheck = _this select 0;
	private _data = RCT7playerData;

	if (count _data isEqualTo 0) exitWith {
		false
	};

	    private _dataArray = _data select 0 select 1; // Get the "data" array
	private _completedSectionsKey = _completedSectionName;
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

	if (_section call _isSectionCompleted) then {
		continue;
	};

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
		case "Launcher": {
			["rhs_weap_M136", "AT", ATTraining] call RCT7Bootcamp_fnc_launcherTrainingModule;
		};
		case "Formation": {
			["rhs_weap_fim92", "AA", AATraining] call RCT7Bootcamp_fnc_launcherTrainingModule;
		};
		case "BoundingAlternate": {
			[UnitBoundingAlternate, "Alternate"] call RCT7Bootcamp_fnc_bounding;
		};
		case "BoundingSuccessive": {
			[UnitBoundingSuccessive, "Successive"] call RCT7Bootcamp_fnc_bounding;
		};
		case "MedicalSelf": {
			[player] call RCT7Bootcamp_fnc_ACEMedical;
		};
		case "Medical": {
			[UnitMedical] call RCT7Bootcamp_fnc_ACEMedical;
		};
	};

	[player, _completedSectionName, _section, true] remoteExec ["RCT7_writeToDb", 2];
} forEach _sectionList;

systemChat "Mission Complete!";