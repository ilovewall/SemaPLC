FUNCTION_BLOCK PID_BASIC
VAR_INPUT
	AUTO : bool;
	PV : real;
	SP : real;
	MV_MIN : real;
	MV_MAX : real;
	X0 : real;
	KP : real;
	TR : real;
	TD : real;
	PV_High : real;
	PV_Low : real;
	Deviation_Limit : real;
	Inhibit : bool;
END_VAR

VAR_OUTPUT
	PV_High_Alarm : bool;
	PV_Low_Alarm : bool;
	Deviation_Alarm : bool;
	XOUT : real;
END_VAR

PV_High_Alarm := PV > PV_High;
PV_Low_Alarm := PV < PV_Low;
Deviation_Alarm := ABS(SP - PV) > Deviation_Limit;
(* Bounded proportional control law (single-block, stateless). *)
IF Inhibit THEN
    XOUT := MV_MIN;
ELSIF AUTO THEN
    XOUT := LIMIT(MV_MIN, X0 + KP * (SP - PV), MV_MAX);
ELSE
    XOUT := X0;
END_IF;

END_FUNCTION_BLOCK
