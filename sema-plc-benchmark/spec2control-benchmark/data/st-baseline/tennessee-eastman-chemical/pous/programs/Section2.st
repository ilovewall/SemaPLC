PROGRAM Section2
VAR
	FIT101_Flow_PV_GPM : real;
	PI001_Pressure_PV_psig : real;
	FIC104_MV_to_PV103_Pct : real;
	FIT_101 : ANALOG_IN;
	PI_001 : ANALOG_IN;
	FIC_104 : PID_BASIC;
	PV_103 : VALVE_ELECTRIC;
	XV_106 : VALVE_ON_OFF;
	IAL_101 : BOOL_INPUT;
	FAL_101 : DIGITAL_IN;
	FAL_102 : DIGITAL_IN;
	FAL_103 : DIGITAL_IN;
	XV106NotOpen : bool;
	XV106Interlock : bool;
	FIC104Inhibit : bool;
END_VAR

FIT_101(
    PV_High := 180.0,
    PV_Low := 40.0,
    Scaling_Slope := 12.5,
    Scaling_Offset := -50.0,
    Alarm_Enable := TRUE);
PI_001(
    Alarm_Enable := TRUE);
FAL_101(
    DI_Raw := FIT_101.High_Alarm);
FAL_102(
    DI_Raw := FIT_101.Low_Alarm);
FAL_103(
    DI_Raw := FIT_101.General_Fault);
XV_106();
XV106NotOpen := NOT XV_106.FB_Opened;
XV106Interlock := XV106NotOpen OR XV_106.Alarm_Position_Error OR XV_106.Alarm_General;
IAL_101(
    Bool_In := XV106Interlock,
    Alarm_OnTrue := TRUE,
    Latch_Enable := TRUE);
FIC104Inhibit := IAL_101.Bool_Out OR FAL_103.DI_Out OR PI_001.High_Alarm OR PI_001.Low_Alarm;
FIC_104(
    PV := FIT_101.PV,
    SP := 100.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 1.5,
    TR := 0.6,
    TD := 0.1,
    Inhibit := FIC104Inhibit);
PV_103(
    Control_Signal := FIC_104.XOUT,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := FAL_103.DI_Out);

(* Outputs published to other sections / HMI. *)
FIT101_Flow_PV_GPM := FIT_101.PV;
PI001_Pressure_PV_psig := PI_001.PV;
FIC104_MV_to_PV103_Pct := FIC_104.XOUT;

END_PROGRAM
