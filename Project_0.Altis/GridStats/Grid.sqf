/*
Class: Grid
2D array of numbers (like a black and white image).
Each grid occupies whole map and starts at [0, 0].

Authors: Sparker(initial author), Sen(code porting)
*/

#include "common.hpp"

#define pr private

CLASS("Grid", "");
	
	// EH ID of mission event handler
	STATIC_VARIABLE("mapSingleClickEH");
	// Grid object which we are currently editing with mouse
	STATIC_VARIABLE("currentGrid");
	STATIC_VARIABLE("currentValue");
	STATIC_VARIABLE("currentScale");
	
	VARIABLE("cellSize");
	VARIABLE("gridArray");

	/*
	Method: new
	Constructor
	
	Parameters: _cellSize
	
	_cellSize - cell size in meters. Each cell is square. And flat.
	*/

	METHOD("new") {
		params ["_thisObject", ["_cellSize", 500]];

		private _nCellsX = ceil(worldSize / _cellSize); //Size of the grid measured in squares
		private _nCellsY = ceil(worldSize / _cellSize);
		
		T_SETV("cellSize", _cellSize);
		
		private _gridArray = [];
		_gridArray resize _nCellsX;
		{
			pr _a = [];
			_a resize _nCellsY;
			_gridArray set [_forEachIndex, _a apply {0}];
		} forEach _gridArray;

		T_SETV("gridArray", _gridArray);
	} ENDMETHOD;

	/*
	Method: getGridArray
	Returns the underlying 2D array.
	
	Returns: Array
	*/
	METHOD("getGridArray") {
		params ["_thisObject"];
		T_GETV("gridArray")
	} ENDMETHOD;
	
	/*
	Method: getCellSize
	Returns cell size of this grid.
	
	Returns: Number
	*/
	METHOD("getCellSize") {
		params ["_thisObject"];
		T_GETV("cellSize")
	} ENDMETHOD;





	// - - - - Setting values - - - -

	/*
	Method: setValueAll
	Sets all elements to constant value
	
	Parameters: _value
	
	_value - Number
	
	Returns: nil
	*/
	METHOD("setValueAll") {
		params ["_thisObject", ["_value", 0, [0]]];
		
		pr _gridArray = T_GETV("gridArray");
		pr _n = count _gridArray;
		{
			pr _a = [];
			_a resize _n;
			_gridArray set [_forEachIndex, _a apply {_value}];
		} forEach _gridArray;
	} ENDMETHOD;
	
	/*
	Method: setValue
	Sets value of element specified by world coordinates
	
	Parameters: _pos, _value
	
	_pos - array, position: [x, y] or [x, y, z], but only x and y matter.
	_value - Number
	
	Returns: nil
	*/
	
	METHOD("setValue") {
		params ["_thisObject", ["_pos", [], [[]]], ["_value", 0, [0]]];
	
		_pos params ["_x", "_y"];
		
		pr _array = T_GETV("gridArray");
		pr _cellSize = T_GETV("cellSize");
	
		pr _xID = floor(_x / _cellSize);
		pr _yID = floor(_y / _cellSize);
		
		(_array select _xID) set [_yID, _value];
	
	} ENDMETHOD;
	
	
	
	// - - - - - Plotting grids - - - - -
	/*
	Method: plot
	Plots the grid on the map.
	
	Parameters: _scale
	
	_scale - value which will result to alpha 1.0.
	_plotZero - bool, optional, default false. If true, zero values will be plotted as green squares.
	
	Returns: nil
	*/
	METHOD("plot") {
		params ["_thisObject", ["_scale", 1, [1]], ["_plotZero", false]];
		
		CALLM0(_thisObject, "unplot");
		
		pr _array = T_GETV("gridArray");
		pr _cellSize = T_GETV("cellSize");
		pr _halfSize = _cellSize * 0.5;
		pr _n = count _array;
		
		for "_x" from 0 to _n do {
			pr _col = _array select _x;
			for "_y" from 0 to _n do {
				pr _val = _col select _y;
				
				// Create marker
				pr _mrkName = format ["%1x%2y%3", _thisObject, _x, _y];
				pr _mrk = createMarkerLocal [_mrkName, [_cellSize*_x + _halfSize, _cellSize*_y + _halfSize, 0]];
				_mrk setMarkerShapeLocal "RECTANGLE";
				_mrk setMarkerBrushLocal "SolidFull";
				_mrk setMarkerSizeLocal [_halfSize, _halfSize];
				
				// Set marker color and alpha
				if (_val == 0 && _plotZero) then {
					// Zero
					_mrk setMarkerColorLocal "ColorGreen";
					_mrk setMarkerAlphaLocal 0.1;
				} else {
					if (_val > 0) then {
						// Positive
						pr _alpha = ((_val/_scale) max 0.1) min 1.0;
						_mrk setMarkerColorLocal "ColorRed";
						_mrk setMarkerAlphaLocal _alpha;
					} else {
						// Negative
						pr _alpha = ((-_val/_scale) max 0.1) min 1.0;
						_mrk setMarkerColorLocal "ColorBlue";
						_mrk setMarkerAlphaLocal _alpha;
					};
				};
			};
		};
		
	} ENDMETHOD;
	
	/*
	Method: unplot
	Removes markers of a previously plotted grid
	
	Returns: nil
	*/
	
	METHOD("unplot") {
		params ["_thisObject"];
		
		pr _array = T_GETV("gridArray");
		pr _n = count _array;
		
		for "_x" from 0 to _n do {
			pr _col = _array select _x;
			for "_y" from 0 to _n do {
				pr _mrkName = format ["%1x%2y%3", _thisObject, _x, _y];
				deleteMarkerLocal _mrkName;
			};
		};
	} ENDMETHOD;
	
	/*
	Method: plotCell
	Plots a single cell of a grid
	
	Parameters: _pos
	
	_pos - [x, y] position, in meters
	
	Returns: nil
	*/
	
	METHOD("plotCell") {
		params ["_thisObject", ["_pos", [], [[]]], ["_scale", 1, [1]], ["_plotZero", false]];
		
		_pos params ["_x", "_y"];
		
		// Convert coordinates to cell IDs
		pr _cellSize = T_GETV("cellSize");
		pr _x = floor(_x / _cellSize);
		pr _y = floor(_y / _cellSize);
		
		pr _mrkName = format ["%1x%2y%3", _thisObject, _x, _y];
		
		// Delete old marker
		deleteMarkerLocal _mrkName;
		
		// Plot the marker again
		pr _array = T_GETV("gridArray");
		pr _halfSize = _cellSize * 0.5;
		
		pr _val = (_array select _x) select _y;
		
		// Create marker
		pr _mrk = createMarkerLocal [_mrkName, [_cellSize*_x + _halfSize, _cellSize*_y + _halfSize, 0]];
		_mrk setMarkerShapeLocal "RECTANGLE";
		_mrk setMarkerBrushLocal "SolidFull";
		_mrk setMarkerSizeLocal [_halfSize, _halfSize];
		
		// Set marker color and alpha
		if (_val == 0 && _plotZero) then {
			// Zero
			_mrk setMarkerColorLocal "ColorGreen";
			_mrk setMarkerAlphaLocal 0.1;
		} else {
			if (_val > 0) then {
				// Positive
				pr _alpha = ((_val/_scale) max 0.1) min 1.0;
				_mrk setMarkerColorLocal "ColorRed";
				_mrk setMarkerAlphaLocal _alpha;
			} else {
				// Negative
				pr _alpha = ((-_val/_scale) max 0.1) min 1.0;
				_mrk setMarkerColorLocal "ColorBlue";
				_mrk setMarkerAlphaLocal _alpha;
			};
		};
		
	} ENDMETHOD;
	
	// - - - - - Manipulating values - - - - - -
	
	METHOD("edit") {
	
		params ["_thisObject", ["_value", 1.0], ["_scale", 1.0]];
		
		// Unplot previous grid
		pr _grid = GETSV("Grid", "currentGrid");
		if (!isNil "_grid") then {
			if (_grid != "") then {
				CALLM0(_grid, "unplot");
			};
		};
		
		SETSV("Grid", "currentGrid", _thisObject);
		SETSV("Grid", "currentValue", _value);
		SETSV("Grid", "currentScale", _scale);
		
		// Plot the grid
		CALLM2(_thisObject, "plot", _scale, true);
		
		// Remove previous EH if it exists
		pr _eh = GETSV("Grid", "mapSingleClickEH");
		if (!isNil "_eh") then {
			removeMissionEventHandler ["MapSingleClick", _eh];
		};
		
		// Hint instructions
		hint "Click: set value\nShift+click: set to 0\nClick outside of map: finish editing";
		
		// Add new EH
		_eh = addMissionEventHandler ["MapSingleClick", {
			params ["_units", "_pos", "_alt", "_shift"];
			
			_pos params ["_x", "_y"];
			
			pr _grid = GETSV("grid", "currentGrid");
			
			if (_x < 0 || _y < 0 || _x > worldSize || _y > worldSize) exitWith {
				pr _eh = GETSV("Grid", "mapSingleClickEH");
				removeMissionEventHandler ["MapSingleClick", _eh];
				systemChat format ["Finished editing %1", _grid];
				SETSV("Grid", "currentGrid", nil);
			};
			
			pr _value = GETSV("grid", "currentValue");
			pr _scale = GETSV("grid", "currentScale");
			
			if (_shift) then { _value = 0 };
			
			CALLM2(_grid, "setValue", _pos, _value);
			CALLM3(_grid, "plotCell", _pos, _scale, true);
			//CALLM2(_grid, "plot", _scale, true);
		}];
		
		SETSV("Grid", "mapSingleClickEH", _eh);
	
	} ENDMETHOD;
	
	
	
	
ENDCLASS;
