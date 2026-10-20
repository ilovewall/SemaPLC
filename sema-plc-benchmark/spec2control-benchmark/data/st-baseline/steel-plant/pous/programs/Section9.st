PROGRAM Section9
VAR
	FT801_Flow_PV : real;
	FT802_Flow_PV : real;
	PT801_Pressure_PV : real;
	FFIC801_AirFlow_SP : real;
	FFIC801_ActiveRatio : real;
	RatioHigh_Alarm : bool;
	RatioLow_Alarm : bool;
	AL_801 : ANALOG_IN;
	AL_802 : ANALOG_IN;
	AL_803 : ANALOG_IN;
	AL_804 : ANALOG_IN;
	FT_801 : ANALOG_IN;
	FT_802 : ANALOG_IN;
	PT_801 : ANALOG_IN;
	FFIC_801 : RATIO_CONTROL;
	FIC_802 : PID_BASIC;
	FV_802 : VALVE_ELECTRIC;
	RatioHighDelay_TON : TON;
	LowFlowEnable_GE : bool;
	PressureOutOfRange_OR : bool;
	FFIC801_Inhibits_OR : bool;
	FIC802_Faults_OR : bool;
	FV802_Inhibits_OR : bool;
	RatioHigh_GT : bool;
	RatioLow_LT : bool;
	NotFaults_NOT : bool;
	NotPressureLockout_NOT : bool;
	AutoEnable_AND : bool;
END_VAR

AL_801();
AL_802();
AL_803();
AL_804();
FT_801(
    Scaling_Slope := 312.5,
    Scaling_Offset := -1250.0,
    Alarm_Enable := TRUE);
FT_802(
    Scaling_Slope := 375.0,
    Scaling_Offset := -1500.0,
    Alarm_Enable := TRUE);
PT_801(
    Scaling_Slope := 0.125,
    Scaling_Offset := -0.5,
    Alarm_Enable := TRUE);
PressureOutOfRange_OR := PT_801.High_Alarm OR PT_801.Low_Alarm;
FFIC801_Inhibits_OR := PressureOutOfRange_OR OR FT_801.Low_Alarm OR FT_802.High_Alarm;
LowFlowEnable_GE := (FT_801.PV >= 100.0);
FFIC_801(
    Auto := LowFlowEnable_GE,
    PrimaryPV := FT_801.PV,
    SecondaryPV := FT_802.PV,
    RatioSP := 2.5,
    MV_MIN := 0.0,
    MV_MAX := 6000.0,
    Inhibit := FFIC801_Inhibits_OR);
FIC802_Faults_OR := FT_801.General_Fault OR PT_801.General_Fault;
NotFaults_NOT := NOT FIC802_Faults_OR;
NotPressureLockout_NOT := NOT PressureOutOfRange_OR;
AutoEnable_AND := LowFlowEnable_GE AND NotFaults_NOT AND NotPressureLockout_NOT;
FIC_802(
    AUTO := AutoEnable_AND,
    PV := FT_802.PV,
    SP := FFIC_801.SlaveSP,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 50.0,
    Inhibit := FIC802_Faults_OR);
FV802_Inhibits_OR := PressureOutOfRange_OR OR FIC802_Faults_OR;
FV_802(
    Control_Signal := FIC_802.XOUT,
    Manual_Mode := PressureOutOfRange_OR,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := FV802_Inhibits_OR);
RatioHigh_GT := (FFIC_801.ActiveRatio > 3.0);
RatioHighDelay_TON(
    IN := RatioHigh_GT,
    PT := T#5s);
RatioLow_LT := (FFIC_801.ActiveRatio < 2.0);

(* Outputs published to other sections / HMI. *)
RatioHigh_Alarm := RatioHighDelay_TON.Q;
RatioLow_Alarm := RatioLow_LT;
FT801_Flow_PV := FT_801.PV;
FT802_Flow_PV := FT_802.PV;
PT801_Pressure_PV := PT_801.PV;
FFIC801_AirFlow_SP := FFIC_801.SlaveSP;
FFIC801_ActiveRatio := FFIC_801.ActiveRatio;

END_PROGRAM
