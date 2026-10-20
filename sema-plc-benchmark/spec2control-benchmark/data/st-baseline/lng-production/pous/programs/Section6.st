PROGRAM Section6
VAR
	FT501_PropaneFlow_PV : real;
	FT502_MRFlow_PV : real;
	PT501_EndFlashDrumPressure_PV : real;
	TIT102_MCHE_OutletTemp_PV : real;
	FIC504_MRFlow_SP_From_FFIC503 : real;
	FFIC503_ActiveRatio : real;
	Operator_RatioBias : real;
	FFIC503_DV_HI : bool;
	FFIC503_DV_LO : bool;
	FFIC_503 : RATIO_CONTROL;
	FIC_504 : PID_BASIC;
	FV_502 : VALVE_ELECTRIC;
	FV_501 : VALVE_ELECTRIC;
	FT_501 : ANALOG_IN;
	FT_502 : ANALOG_IN;
	PT_501 : ANALOG_IN;
	TIT_102 : ANALOG_IN;
	FV501_Open_TON : TON;
	RatioDevHi_TON : TON;
	RatioDevLo_TON : TON;
	TempHigh_GT : bool;
	AutoTrim_SEL : real;
	RatioSum_ADD : real;
	RatioBias_ADD : real;
	RatioClamp_LIMIT : real;
	LowFlowCutoff_LT : bool;
	AutoMode_NOT : bool;
	FV501_FullyOpen_GT : bool;
	AutoDisable1_OR : bool;
	AutoDisable3_OR : bool;
	AnySignalIssue_OR : bool;
	ManualSP_SEL1 : real;
	ManualSP_SEL2 : real;
	FT501_RangeAlarm_OR : bool;
	FT502_RangeAlarm_OR : bool;
	FlowRangeViolation_OR : bool;
	FlowSignalFault_OR : bool;
	SafetyCommon_OR : bool;
	RatioDevHi_GT : bool;
	RatioDevLo_LT : bool;
END_VAR

FV_501(
    Open_Limit := 100.0);
FV501_FullyOpen_GT := (FV_501.Feedback_Pos > 99.0);
FV501_Open_TON(
    IN := FV501_FullyOpen_GT,
    PT := T#5s);
FT_501(
    Scaling_Slope := 312.5,
    Scaling_Offset := -1250.0,
    Alarm_Enable := TRUE);
LowFlowCutoff_LT := (FT_501.PV < 500.0);
AutoDisable1_OR := LowFlowCutoff_LT OR FV501_Open_TON.Q;
FT501_RangeAlarm_OR := FT_501.Low_Alarm OR FT_501.High_Alarm;
FT_502(
    Scaling_Slope := 125.0,
    Scaling_Offset := -500.0,
    Alarm_Enable := TRUE);
FT502_RangeAlarm_OR := FT_502.Low_Alarm OR FT_502.High_Alarm;
FlowRangeViolation_OR := FT501_RangeAlarm_OR OR FT502_RangeAlarm_OR;
FlowSignalFault_OR := FT_501.General_Fault OR FT_502.General_Fault;
AnySignalIssue_OR := FlowRangeViolation_OR OR FlowSignalFault_OR;
PT_501(
    Alarm_Enable := TRUE);
SafetyCommon_OR := PT_501.Low_Alarm OR AnySignalIssue_OR;
AutoDisable3_OR := AutoDisable1_OR OR SafetyCommon_OR;
AutoMode_NOT := NOT AutoDisable3_OR;
ManualSP_SEL1 := SEL(G := FV501_Open_TON.Q, IN0 := 100.0, IN1 := 1000.0);
ManualSP_SEL2 := SEL(G := AnySignalIssue_OR, IN0 := ManualSP_SEL1, IN1 := 500.0);
TIT_102(
    PV_High := -155.0,
    Alarm_Enable := TRUE);
TempHigh_GT := (TIT_102.PV > -155.0);
AutoTrim_SEL := SEL(G := TempHigh_GT, IN0 := 0.0, IN1 := 0.1);
RatioSum_ADD := 2.5 + AutoTrim_SEL;
RatioBias_ADD := RatioSum_ADD + Operator_RatioBias;
RatioClamp_LIMIT := LIMIT(MN := 2.0, IN := RatioBias_ADD, MX := 3.0);
FFIC_503(
    Auto := AutoMode_NOT,
    PrimaryPV := FT_501.PV,
    SecondaryPV := FT_502.PV,
    RatioSP := RatioClamp_LIMIT,
    ManOut := ManualSP_SEL2,
    Inhibit := SafetyCommon_OR);
FIC_504(
    PV := FT_502.PV,
    SP := FFIC_503.SlaveSP,
    Inhibit := FlowSignalFault_OR);
FV_502(
    Control_Signal := FIC_504.XOUT);
RatioDevHi_GT := (FFIC_503.RatioErr > 0.2);
RatioDevHi_TON(
    IN := RatioDevHi_GT,
    PT := T#10s);
RatioDevLo_LT := (FFIC_503.RatioErr < -0.2);
RatioDevLo_TON(
    IN := RatioDevLo_LT,
    PT := T#10s);

(* Outputs published to other sections / HMI. *)
FFIC503_DV_HI := RatioDevHi_TON.Q;
FFIC503_DV_LO := RatioDevLo_TON.Q;
FT501_PropaneFlow_PV := FT_501.PV;
FT502_MRFlow_PV := FT_502.PV;
PT501_EndFlashDrumPressure_PV := PT_501.PV;
TIT102_MCHE_OutletTemp_PV := TIT_102.PV;
FIC504_MRFlow_SP_From_FFIC503 := FFIC_503.SlaveSP;
FFIC503_ActiveRatio := FFIC_503.ActiveRatio;

END_PROGRAM
