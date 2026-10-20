FUNCTION_BLOCK ANALOG_IN
VAR_INPUT
	Raw_Signal : real;
	PV_High : real;
	PV_Low : real;
	Scaling_Slope : real;
	Scaling_Offset : real;
	Alarm_Enable : bool;
END_VAR

VAR_OUTPUT
	PV : real;
	High_Alarm : bool;
	Low_Alarm : bool;
	General_Fault : bool;
END_VAR

(* Linear scaling of the 4-20mA raw signal to engineering units. *)
PV := Raw_Signal * Scaling_Slope + Scaling_Offset;
(* Wire-break style fault: a healthy 4-20mA loop never drops below ~2mA. *)
General_Fault := Alarm_Enable AND (Raw_Signal < 2.0);
High_Alarm := Alarm_Enable AND (PV > PV_High);
Low_Alarm := Alarm_Enable AND (PV < PV_Low);

END_FUNCTION_BLOCK
