FUNCTION_BLOCK BOOL_INPUT
VAR_INPUT
	Bool_In : bool;
	Alarm_OnTrue : bool;
	Alarm_OnFalse : bool;
	Latch_Enable : bool;
	Reset_Latch : bool;
END_VAR

VAR_OUTPUT
	Bool_Out : bool;
	Alarm_Active : bool;
	Latched_Status : bool;
END_VAR

Bool_Out := Bool_In;
Alarm_Active := (Alarm_OnTrue AND Bool_In) OR (Alarm_OnFalse AND NOT Bool_In);
IF Reset_Latch THEN
    Latched_Status := FALSE;
ELSIF Latch_Enable AND Alarm_Active THEN
    Latched_Status := TRUE;
END_IF;

END_FUNCTION_BLOCK