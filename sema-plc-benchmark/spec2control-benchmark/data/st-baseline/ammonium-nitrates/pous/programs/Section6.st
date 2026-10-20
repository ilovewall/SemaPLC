PROGRAM Section6
VAR
	LT501_Level_Pct : real;
	WB505_Flow_Pct : real;
	RIC506_SC504_FlowSP : real;
	Ratio_Bias_Manual : real;
	LT_501 : ANALOG_IN;
	WB_505 : ANALOG_IN;
	AP_503 : VALVE_ON_OFF;
	PRV_502 : VALVE_ON_OFF;
	RIC_506 : RATIO_CONTROL;
	FIC_507 : PID_BASIC;
	SC_504 : MOTOR_VSD;
	AP503_NotActive_NOT : bool;
	PRV502_NotClosed_NOT : bool;
	SC504_Shutdown_OR : bool;
	RIC506_Inhibit_OR : bool;
	LT501_Above80_GT : bool;
	LT501_Below20_LT : bool;
	Level_OutOfRange_OR : bool;
	LevelInNominal_NOT : bool;
	RatioSP_NominalBias_ADD : real;
	RatioSP_HighTerm_MULT : real;
	RatioSP_LowTerm_MULT : real;
	RatioSP_NominalTerm_MULT : real;
	RatioSP_HL_ADD : real;
	RatioSP_Final_ADD : real;
END_VAR

LT_501(
    PV_High := 90.0,
    PV_Low := 10.0,
    Alarm_Enable := TRUE);
WB_505(
    PV_Low := 100.0,
    Scaling_Slope := 6.25,
    Scaling_Offset := -25.0,
    Alarm_Enable := TRUE);
AP_503();
PRV_502();
AP503_NotActive_NOT := NOT AP_503.FB_Opened;
PRV502_NotClosed_NOT := NOT PRV_502.FB_Closed;
RIC506_Inhibit_OR := AP503_NotActive_NOT OR PRV502_NotClosed_NOT OR WB_505.Low_Alarm;
LT501_Above80_GT := (LT_501.PV > 80.0);
RatioSP_HighTerm_MULT := BOOL_TO_REAL(LT501_Above80_GT) * 1.0;
LT501_Below20_LT := (LT_501.PV < 20.0);
RatioSP_LowTerm_MULT := BOOL_TO_REAL(LT501_Below20_LT) * 2.0;
RatioSP_HL_ADD := RatioSP_HighTerm_MULT + RatioSP_LowTerm_MULT;
Level_OutOfRange_OR := LT501_Above80_GT OR LT501_Below20_LT;
LevelInNominal_NOT := NOT Level_OutOfRange_OR;
RatioSP_NominalBias_ADD := 1.5 + Ratio_Bias_Manual;
RatioSP_NominalTerm_MULT := BOOL_TO_REAL(LevelInNominal_NOT) * RatioSP_NominalBias_ADD;
RatioSP_Final_ADD := RatioSP_HL_ADD + RatioSP_NominalTerm_MULT;
FIC_507(
    AUTO := TRUE,
    PV := SC_504.FB_ActualSpeed,
    SP := RIC_506.SlaveSP,
    MV_MIN := 0.0,
    MV_MAX := 100.0);
SC504_Shutdown_OR := RIC506_Inhibit_OR OR LT_501.Low_Alarm;
SC_504(
    Speed_SP := FIC_507.XOUT,
    Accel_Ramp := T#2s,
    Decel_Ramp := T#2s,
    Inhibit := SC504_Shutdown_OR);
RIC_506(
    Auto := TRUE,
    PrimaryPV := WB_505.PV,
    SecondaryPV := SC_504.FB_ActualSpeed,
    RatioSP := RatioSP_Final_ADD,
    Bias := 0.0,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    Inhibit := RIC506_Inhibit_OR);

(* Outputs published to other sections / HMI. *)
LT501_Level_Pct := LT_501.PV;
WB505_Flow_Pct := WB_505.PV;
RIC506_SC504_FlowSP := RIC_506.SlaveSP;

END_PROGRAM
