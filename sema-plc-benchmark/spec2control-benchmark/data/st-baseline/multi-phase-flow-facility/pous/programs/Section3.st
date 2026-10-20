PROGRAM Section3
VAR
	PT501_Pressure_PV : real;
	LI502_Level_PV : real;
	PIC501_Output_To_FV102 : real;
	PT_501 : ANALOG_IN;
	LI_502 : ANALOG_IN;
	PIC_501 : PID_BASIC;
	FV_102 : VALVE_ELECTRIC;
	SeparatorShutdown_OR : bool;
	PIC501_Inhibit_OR : bool;
END_VAR

PT_501(
    PV_High := 85.0,
    PV_Low := 65.0,
    Scaling_Slope := 9.375,
    Scaling_Offset := -37.5);
LI_502(
    PV_High := 90.0,
    PV_Low := 5.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0);
SeparatorShutdown_OR := PT_501.General_Fault OR PIC_501.PV_High_Alarm;
FV_102(
    Control_Signal := PIC_501.XOUT,
    Manual_Mode := FALSE,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := SeparatorShutdown_OR);
PIC501_Inhibit_OR := SeparatorShutdown_OR OR PT_501.High_Alarm OR PT_501.Low_Alarm OR LI_502.Low_Alarm OR LI_502.High_Alarm OR FV_102.Alarm;
PIC_501(
    AUTO := TRUE,
    PV := PT_501.PV,
    SP := 75.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := FV_102.Feedback_Pos,
    KP := 2.0,
    TR := 0.5,
    TD := 0.1,
    Inhibit := PIC501_Inhibit_OR);

(* Outputs published to other sections / HMI. *)
PT501_Pressure_PV := PT_501.PV;
LI502_Level_PV := LI_502.PV;
PIC501_Output_To_FV102 := PIC_501.XOUT;

END_PROGRAM
