FUNCTION_BLOCK VALVE_ON_OFF
VAR_INPUT
	Open_Cmd : bool;
	Close_Cmd : bool;
	Timeout : time;
	Inhibit : bool;
END_VAR

VAR_OUTPUT
	FB_Opened : bool;
	FB_Closed : bool;
	Valve_Open_Out : bool;
	Valve_Close_Out : bool;
	Alarm_Position_Error : bool;
	Alarm_General : bool;
END_VAR

IF Inhibit THEN
    Valve_Open_Out := FALSE;
    Valve_Close_Out := TRUE;
ELSE
    Valve_Open_Out := Open_Cmd AND NOT Close_Cmd;
    Valve_Close_Out := Close_Cmd OR NOT Open_Cmd;
END_IF;
FB_Opened := Valve_Open_Out;
FB_Closed := NOT Valve_Open_Out;
Alarm_Position_Error := FALSE;
Alarm_General := Inhibit;

END_FUNCTION_BLOCK
