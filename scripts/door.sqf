_this addAction ["Open Door",  
    {  
        params ["_target"];  
  
        private _isOpen = _target getVariable ["RCT_isOpen", false];  
  
        private _i = 0;   
        private _p = getPosATL _target; 

        while {90 > _i} do {   
            _dir = (getDir _target) - 1; 
            _target setDir _dir;   
            _pos = _target modelToWorld [0,0.01,0];   
            _target setPosATL [_pos # 0, _pos # 1, _p # 2];   
            _i = _i + 1;  
            sleep 0.001;  
        };  
  
        _target setVariable ["RCT_isOpen", !_isOpen, true];  
  
    },
    nil,
	1.5,
	true,
	true,
	"",
	"_target getVariable [""RCT_isOpen"", false] isEqualTo false"
]; 
 
_this addAction ["Close Door",  
    {  
        params ["_target"];  
  
        private _isOpen = _target getVariable ["RCT_isOpen", false];  
  
        private _i = 0;   
        private _p = getPosATL _target; 

        while {90 > _i} do {   
            _dir = (getDir _target) + 1; 
            _target setDir _dir;   
            _pos = _target modelToWorld [0,-0.01,0];   
            _target setPosATL [_pos # 0, _pos # 1, _p # 2];   
            _i = _i + 1;  
            sleep 0.001;  
        };  
  
        _target setVariable ["RCT_isOpen", !_isOpen, true];  
  
    },
    nil,
	1.5,
	true,
	true,
	"",
	"_target getVariable [""RCT_isOpen"", false] isEqualTo true"
]; 
