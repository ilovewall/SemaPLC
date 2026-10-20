PROGRAM Section6
VAR
	CT501_Consistency_PV_Pct : real;
	FC502_MV_to_FV502_Pct : real;
	SELT501_SEL_PV_WsPerMm2 : real;
	SELC501_MV_to_PGA501_Pct : real;
	LT501_Level_PV_Pct : real;
	PT502_Pressure_PV_kPa : real;
	PGT501_PlateGap_PV_mm : real;
	CT_501 : ANALOG_IN;
	FC_502 : PID_BASIC;
	FV_502 : VALVE_ELECTRIC;
	LT_501 : ANALOG_IN;
	M_501 : MOTOR_ON_OFF;
	PT_502 : ANALOG_IN;
	SELC_501 : PID_BASIC;
	PGT_501 : ANALOG_IN;
	PGA_501 : VALVE_ELECTRIC;
	SELT_501 : ANALOG_IN;
	INTLK_M501_RUNNING : BOOL_INPUT;
	INTLK_PLATE_GAP_IN_RANGE : BOOL_INPUT;
	INTLK_LEVEL_ABOVE_20 : BOOL_INPUT;
	PERM_PT502_IN_RANGE : BOOL_INPUT;
	PGT501_OutOfRange_OR : bool;
	PlateGapInRange_NOT : bool;
	SEL_Enable_AND : bool;
	SEL_Inhibit_NOT : bool;
	LT501_LevelNotOK_OR : bool;
	LevelAbove20_NOT : bool;
	PT502_NotInRange_OR : bool;
	PT502_InRange_NOT : bool;
	FC502_Inhibit_OR : bool;
END_VAR

CT_501(
    Scaling_Slope := 0.1875,
    Scaling_Offset := 1.25,
    Alarm_Enable := TRUE);
LT_501(
    Alarm_Enable := TRUE);
LT501_LevelNotOK_OR := LT_501.Low_Alarm OR LT_501.General_Fault;
PT_502(
    Alarm_Enable := TRUE);
PT502_NotInRange_OR := PT_502.High_Alarm OR PT_502.Low_Alarm OR PT_502.General_Fault;
FC502_Inhibit_OR := LT501_LevelNotOK_OR OR PT502_NotInRange_OR OR CT_501.General_Fault;
FC_502(
    AUTO := TRUE,
    PV := CT_501.PV,
    SP := 3.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 2.2,
    TR := 0.7,
    TD := 0.0,
    PV_High := 4.0,
    PV_Low := 2.0,
    Inhibit := FC502_Inhibit_OR);
FV_502(
    Control_Signal := FC_502.XOUT,
    Manual_Mode := FALSE,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := FC502_Inhibit_OR);
PGT_501(
    Alarm_Enable := TRUE);
PGT501_OutOfRange_OR := PGT_501.High_Alarm OR PGT_501.Low_Alarm OR PGT_501.General_Fault;
M_501(
    Inhibit := PGT501_OutOfRange_OR);
SELT_501(
    Scaling_Slope := 0.0625,
    Scaling_Offset := -0.05,
    Alarm_Enable := TRUE);
INTLK_M501_RUNNING(
    Bool_In := M_501.FB_Running);
PlateGapInRange_NOT := NOT PGT501_OutOfRange_OR;
INTLK_PLATE_GAP_IN_RANGE(
    Bool_In := PlateGapInRange_NOT);
SEL_Enable_AND := INTLK_M501_RUNNING.Bool_Out AND INTLK_PLATE_GAP_IN_RANGE.Bool_Out;
SEL_Inhibit_NOT := NOT SEL_Enable_AND;
SELC_501(
    AUTO := TRUE,
    PV := SELT_501.PV,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 1.8,
    TR := 0.5,
    TD := 0.1,
    PV_High := 1.1,
    PV_Low := 0.3,
    Inhibit := SEL_Inhibit_NOT);
PGA_501(
    Control_Signal := SELC_501.XOUT,
    Manual_Mode := FALSE,
    Open_Limit := 100.0,
    Close_Limit := 0.0);
LevelAbove20_NOT := NOT LT501_LevelNotOK_OR;
INTLK_LEVEL_ABOVE_20(
    Bool_In := LevelAbove20_NOT);
PT502_InRange_NOT := NOT PT502_NotInRange_OR;
PERM_PT502_IN_RANGE(
    Bool_In := PT502_InRange_NOT);

(* Outputs published to other sections / HMI. *)
CT501_Consistency_PV_Pct := CT_501.PV;
FC502_MV_to_FV502_Pct := FC_502.XOUT;
SELT501_SEL_PV_WsPerMm2 := SELT_501.PV;
SELC501_MV_to_PGA501_Pct := SELC_501.XOUT;
LT501_Level_PV_Pct := LT_501.PV;
PT502_Pressure_PV_kPa := PT_502.PV;
PGT501_PlateGap_PV_mm := PGT_501.PV;

END_PROGRAM
