FUNCTION_BLOCK VALVE_ELECTRIC
VAR_INPUT
	Control_Signal : real;
	Manual_Mode : bool;
	Manual_Position : real;
	Open_Limit : real;
	Close_Limit : real;
	Timeout : time;
	Inhibit : bool;
END_VAR

VAR_OUTPUT
	Valve_Position : real;
	Feedback_Pos : real;
	Valve_Moving : bool;
	Position_Error : bool;
	Alarm : bool;
END_VAR

IF Inhibit THEN
    Valve_Position := Close_Limit;
ELSIF Manual_Mode THEN
    Valve_Position := LIMIT(Close_Limit, Manual_Position, Open_Limit);
ELSE
    Valve_Position := LIMIT(Close_Limit, Control_Signal, Open_Limit);
END_IF;
Feedback_Pos := Valve_Position;
Valve_Moving := FALSE;
Position_Error := FALSE;
Alarm := Inhibit;

END_FUNCTION_BLOCK
