PROGRAM Section4
VAR
	PIT103_Pressure_kPa : real;
	PT101_UpstreamPressure_kPa : real;
	DT301_PulpDensity_Pct : real;
	PIC104_ControlOutput_to_FV106_Pct : real;
	FV106_ValvePositionFeedback_Pct : real;
	DT_301 : ANALOG_IN;
	PIT_103 : ANALOG_IN;
	PT_101 : ANALOG_IN;
	PIC_104 : PID_BASIC;
	FV_106 : VALVE_ELECTRIC;
	XV_102 : VALVE_ON_OFF;
	XV_107 : VALVE_ON_OFF;
	XV_102_OPEN_FB : DIGITAL_IN;
	XV_107_OPEN_FB : DIGITAL_IN;
	PERM_XV102_OPEN : BOOL_INPUT;
	PERM_XV107_OPEN : BOOL_INPUT;
	PIC104Inhibit_OR : bool;
	FV106Inhibit_OR : bool;
	SystemFault_OR : bool;
	XV102NotOpen_NOT : bool;
	XV107NotOpen_NOT : bool;
	SystemEnable_NOT : bool;
	PIC104Auto_NOT : bool;
END_VAR

DT_301();
PIT_103(
    Scaling_Slope := 31.25,
    Scaling_Offset := -125.0);
PT_101();
PIC104Inhibit_OR := PT_101.Low_Alarm OR PT_101.High_Alarm OR DT_301.High_Alarm OR PIT_103.General_Fault;
PIC104Auto_NOT := NOT PIC104Inhibit_OR;
PIC_104(
    AUTO := PIC104Auto_NOT,
    PV := PIT_103.PV,
    SP := 250.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := -3.0,
    TR := 1.2,
    TD := 0.1,
    PV_High := 275.0,
    PV_Low := 200.0,
    Deviation_Limit := 12.5,
    Inhibit := PIC104Inhibit_OR);
XV_102_OPEN_FB();
PERM_XV102_OPEN(
    Bool_In := XV_102_OPEN_FB.DI_Out);
XV102NotOpen_NOT := NOT PERM_XV102_OPEN.Bool_Out;
XV_107_OPEN_FB();
PERM_XV107_OPEN(
    Bool_In := XV_107_OPEN_FB.DI_Out);
XV107NotOpen_NOT := NOT PERM_XV107_OPEN.Bool_Out;
FV106Inhibit_OR := XV102NotOpen_NOT OR XV107NotOpen_NOT OR PT_101.High_Alarm OR PIT_103.General_Fault;
FV_106(
    Control_Signal := PIC_104.XOUT,
    Manual_Mode := FALSE,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#2S,
    Inhibit := FV106Inhibit_OR);
SystemFault_OR := PT_101.General_Fault OR DT_301.General_Fault;
SystemEnable_NOT := NOT SystemFault_OR;
XV_102(
    Open_Cmd := SystemEnable_NOT,
    Close_Cmd := SystemFault_OR,
    Inhibit := SystemFault_OR);
XV_107(
    Open_Cmd := SystemEnable_NOT,
    Close_Cmd := SystemFault_OR,
    Inhibit := SystemFault_OR);

(* Outputs published to other sections / HMI. *)
PIT103_Pressure_kPa := PIT_103.PV;
PT101_UpstreamPressure_kPa := PT_101.PV;
DT301_PulpDensity_Pct := DT_301.PV;
PIC104_ControlOutput_to_FV106_Pct := PIC_104.XOUT;
FV106_ValvePositionFeedback_Pct := FV_106.Feedback_Pos;

END_PROGRAM
