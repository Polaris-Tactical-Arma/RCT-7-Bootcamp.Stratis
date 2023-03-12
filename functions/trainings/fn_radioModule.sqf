_micro = "TFAR_microdagr";
_radio = "TFAR_rf7800str_1Q";
_microDisplayname = getText(configfile >> "CfgWeapons" >> _micro >> "displayName");
_radioDisplayname = getText(configfile >> "CfgWeapons" >> _radio >> "displayName");

_radioTaskId = "Radio";
[_radioTaskId, "Finish the radio training", "", "intel", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

_getRadio = "GetRadio";
_getRadioDescription = ["Grab the following out of the box:<br/>", _microDisplayname, _radioDisplayname] joinString "<br/>";
[[_getRadio, _radioTaskId], "Get a radio", _getRadioDescription] call RCT7Bootcamp_fnc_taskCreate;
waitUntil{
	_micro in assignedItems player && _radio in assignedItems player
};
[_getRadio] call RCT7Bootcamp_fnc_taskSetState;

_openRadioKeybind = ["TFAR", "OpenSWRadioMenu"] call RCT7Bootcamp_fnc_getCBAKeybind;

_openRadioTaskId = "OpenRadio";
_openRadioDescription = ["Open your Radio with:<br/>[", _openRadioKeybind, "]"] joinString "";
[[_openRadioTaskId, _radioTaskId], "Open Radio", _openRadioDescription, "radio"] call RCT7Bootcamp_fnc_taskCreate;
waitUntil{
	!isNull(findDisplay 4425)
};
[_openRadioTaskId] call RCT7Bootcamp_fnc_taskSetState;

_freq1 = "31";
_frequency1TaskId = ["Frequency", _freq1] joinString "";

_setFrequencyDescription = ["Set your first Channel to:<br/>", _freq1] joinString "";
[[_frequency1TaskId, _radioTaskId], ["Set to", _freq1] joinString " ", _setFrequencyDescription, "radio"] call RCT7Bootcamp_fnc_taskCreate;
waitUntil{
	([(call TFAR_fnc_activeSwRadio), 1] call TFAR_fnc_getChannelFrequency) isEqualTo _freq1
};
[_frequency1TaskId] call RCT7Bootcamp_fnc_taskSetState;

_freq2 = "31.1";
_setFrequencyDescription = ["Set your first Channel to:<br/>", _freq2] joinString "";
_frequency2TaskId = ["Frequency", _freq2] joinString "";
[[_frequency2TaskId, _radioTaskId], ["Set to", _freq2] joinString " ", _setFrequencyDescription, "radio"] call RCT7Bootcamp_fnc_taskCreate;

waitUntil{
	[(call TFAR_fnc_activeSwRadio), 2] call TFAR_fnc_getChannelFrequency isEqualTo _freq2
};
[_frequency2TaskId] call RCT7Bootcamp_fnc_taskSetState;

_transmitKeybind = ["TFAR", "SWTransmit"] call RCT7Bootcamp_fnc_getCBAKeybind;

_transmitTaskId = "transmit";
_transmitDesciption = ["You can now transmit with [", _transmitKeybind, "]<br/> You can switch Channels with your Numpad"] joinString "";
[[_transmitTaskId, _radioTaskId], ["Set to", _freq2] joinString " ", _transmitDesciption, "radio"] call RCT7Bootcamp_fnc_taskCreate;

waitUntil{
	[call TFAR_fnc_activeSWRadio, true] call TFAR_fnc_radioOn;
};
[_transmitTaskId, "SUCCEEDED", false] call RCT7Bootcamp_fnc_taskSetState;

[_radioTaskId] call RCT7Bootcamp_fnc_taskSetState;