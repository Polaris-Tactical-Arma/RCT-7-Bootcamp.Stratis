_unitList = param[0, [], [[]], [4]];
_formation = param[1, "LINE", [""]];
_distance = param[2, 5, [1]];

_formation = toUpper(_formation);

private _unit1 = _unitList # 0;
private _unit2 = _unitList # 1;
private _unit3 = _unitList # 2;
private _unit4 = _unitList # 3;

_d = _distance * -1;

switch (_formation) do {
	case "COLUMN": {
		_unit2 setPos (_unit1 modelToWorld [0, _d, 0]);
		_unit3 setPos (_unit1 modelToWorld [0, (_d * 2), 0]);
		_unit4 setPos (_unit1 modelToWorld [0, (_d * 3), 0]);
	};
	case "STAG COLUMN": {
		_unit2 setPos (_unit1 modelToWorld [_d, _d, 0]);
		_unit3 setPos (_unit1 modelToWorld [0, (_d * 2), 0]);
		_unit4 setPos (_unit1 modelToWorld [_d, (_d * 3), 0]);
	};
	case "WEDGE": {
		_unit2 setPos (_unit1 modelToWorld [0, _d * 2, 0]);
		_unit3 setPos (_unit1 modelToWorld [_d, _d, 0]);
		_unit4 setPos (_unit1 modelToWorld [_distance, _d, 0]);
	};
	case "ECH LEFT": {
		_unit2 setPos (_unit1 modelToWorld [_d, _d, 0]);
		_unit3 setPos (_unit1 modelToWorld [_d * 2, _d * 2, 0]);
		_unit4 setPos (_unit1 modelToWorld [_d * 3, _d*3, 0]);
	};
	case "ECH RIGHT": {
		_unit2 setPos (_unit1 modelToWorld [_distance, _d, 0]);
		_unit3 setPos (_unit1 modelToWorld [_distance * 2, _d * 2, 0]);
		_unit4 setPos (_unit1 modelToWorld [_distance * 3, _d*3, 0]);
	};
	case "LINE": {
		_unit2 setPos (_unit1 modelToWorld [_d, 0, 0]);
		_unit3 setPos (_unit1 modelToWorld [(_d * 2), 0, 0]);
		_unit4 setPos (_unit1 modelToWorld [(_d * 3), 0, 0]);
	};
};

true;