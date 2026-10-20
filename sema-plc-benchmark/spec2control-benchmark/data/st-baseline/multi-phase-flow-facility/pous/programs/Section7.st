PROGRAM Section7
VAR
	PIT106_Raw_mA : real;
	CompressorRunPermissive : bool;
	PIT106_PressureBar : real;
	PIC105_MV_Percent : real;
	PIT_106 : ANALOG_IN;
	COMP_RUN_PERM : BOOL_INPUT;
	PIC_105 : PID_BASIC;
	V_010 : VALVE_ELECTRIC;
	CompStartupDelay : TON;
	CompNotRunning : bool;
	AirCompInhibit : bool;
	StartupNotElapsed : bool;
END_VAR

PIT_106(
    Raw_Signal := PIT106_Raw_mA,
    PV_High := 9.5,
    PV_Low := 0.5,
    Scaling_Slope := 0.625,
    Scaling_Offset := -2.5);
COMP_RUN_PERM(
    Bool_In := CompressorRunPermissive);
CompNotRunning := NOT COMP_RUN_PERM.Bool_Out;
CompStartupDelay(
    IN := COMP_RUN_PERM.Bool_Out,
    PT := T#7s);
StartupNotElapsed := NOT CompStartupDelay.Q;
AirCompInhibit := CompNotRunning OR PIT_106.High_Alarm OR PIT_106.Low_Alarm OR PIT_106.General_Fault OR StartupNotElapsed;
PIC_105(
    AUTO := TRUE,
    PV := PIT_106.PV,
    SP := 8.5,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    KP := 3.0,
    TR := 1.2,
    TD := 0.3,
    Inhibit := AirCompInhibit);
V_010(
    Control_Signal := PIC_105.XOUT,
    Manual_Mode := FALSE,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := AirCompInhibit);

(* Outputs published to other sections / HMI. *)
PIT106_PressureBar := PIT_106.PV;
PIC105_MV_Percent := PIC_105.XOUT;

END_PROGRAM
