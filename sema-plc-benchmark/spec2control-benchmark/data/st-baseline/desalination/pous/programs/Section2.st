PROGRAM Section2
VAR
	FT101_Flow_PV : real;
	FT102_Flow_PV : real;
	AT101_Analyzer_PV : real;
	AT103_Analyzer_PV : real;
	LT104_Level_PV : real;
	LT105_Level_PV : real;
	FC101_MV_Out : real;
	FC102_MV_Out : real;
	FV101_Valve_Position : real;
	FV102_Valve_Position : real;
	SP101_PctCmd : real;
	SP102_PctCmd : real;
	FlowDevAlarm101 : bool;
	FlowDevAlarm102 : bool;
	AT_101 : ANALOG_IN;
	AT_103 : ANALOG_IN;
	FC_101 : PID_BASIC;
	FC_102 : PID_BASIC;
	FT_101 : ANALOG_IN;
	FT_102 : ANALOG_IN;
	FV_101 : VALVE_ELECTRIC;
	FV_102 : VALVE_ELECTRIC;
	LT_104 : ANALOG_IN;
	LT_105 : ANALOG_IN;
	XV_102 : VALVE_ON_OFF;
	SP101_DevDelay_TON : TON;
	SP102_DevDelay_TON : TON;
	XV102NotOpen_NOT : bool;
	Contamination_OR : bool;
	FV101_Inhibit_OR : bool;
	FV102_Inhibit_OR : bool;
	SP101_PctNorm_DIV : real;
	SP101_PctScaled_MULT : real;
	SP101_PctOffset_ADD : real;
	SP101_PctToFrac_DIV : real;
	SP101_SP_EU_MULT : real;
	DL101_MULT : real;
	SP101_1p1_MULT : real;
	SP101_0p9_MULT : real;
	SP101_PV_GT_HighThresh : bool;
	SP101_PV_LT_LowThresh : bool;
	SP101_DevBand_OR : bool;
	SP102_PctNorm_DIV : real;
	SP102_PctScaled_MULT : real;
	SP102_PctOffset_ADD : real;
	SP102_PctToFrac_DIV : real;
	SP102_SP_EU_MULT : real;
	DL102_MULT : real;
	SP102_1p1_MULT : real;
	SP102_0p9_MULT : real;
	SP102_PV_GT_HighThresh : bool;
	SP102_PV_LT_LowThresh : bool;
	SP102_DevBand_OR : bool;
END_VAR

AT_101(
    PV_High := 50.0,
    Alarm_Enable := TRUE);
AT_103(
    PV_High := 35.0,
    Alarm_Enable := TRUE);
SP101_PctNorm_DIV := SP101_PctCmd / 100.0;
SP101_PctScaled_MULT := SP101_PctNorm_DIV * 59.0;
SP101_PctOffset_ADD := SP101_PctScaled_MULT + 16.0;
SP101_PctToFrac_DIV := SP101_PctOffset_ADD / 100.0;
SP101_SP_EU_MULT := SP101_PctToFrac_DIV * 5000.0;
DL101_MULT := SP101_SP_EU_MULT * 0.1;
FT_101(
    PV_High := 5500.0,
    PV_Low := 450.0,
    Scaling_Slope := 312.5,
    Scaling_Offset := -1250.0,
    Alarm_Enable := TRUE);
FC_101(
    AUTO := TRUE,
    PV := FT_101.PV,
    SP := SP101_SP_EU_MULT,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 2.5,
    TR := 0.8,
    TD := 0.2,
    Deviation_Limit := DL101_MULT,
    Inhibit := FT_101.General_Fault);
SP102_PctNorm_DIV := SP102_PctCmd / 100.0;
SP102_PctScaled_MULT := SP102_PctNorm_DIV * 59.0;
SP102_PctOffset_ADD := SP102_PctScaled_MULT + 16.0;
SP102_PctToFrac_DIV := SP102_PctOffset_ADD / 100.0;
SP102_SP_EU_MULT := SP102_PctToFrac_DIV * 3000.0;
DL102_MULT := SP102_SP_EU_MULT * 0.1;
FT_102(
    PV_High := 3300.0,
    PV_Low := 270.0,
    Scaling_Slope := 187.5,
    Scaling_Offset := -750.0,
    Alarm_Enable := TRUE);
FC_102(
    AUTO := TRUE,
    PV := FT_102.PV,
    SP := SP102_SP_EU_MULT,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 2.5,
    TR := 0.8,
    TD := 0.2,
    Deviation_Limit := DL102_MULT,
    Inhibit := FT_102.General_Fault);
Contamination_OR := AT_101.High_Alarm OR AT_103.High_Alarm;
LT_104(
    PV_Low := 2.0,
    Alarm_Enable := TRUE);
LT_105(
    Alarm_Enable := TRUE);
XV_102(
    Inhibit := Contamination_OR);
XV102NotOpen_NOT := NOT XV_102.FB_Opened;
FV101_Inhibit_OR := XV102NotOpen_NOT OR Contamination_OR OR LT_104.Low_Alarm OR LT_105.High_Alarm OR FT_101.General_Fault;
FV_101(
    Control_Signal := FC_101.XOUT,
    Manual_Mode := FALSE,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := FV101_Inhibit_OR);
FV102_Inhibit_OR := XV102NotOpen_NOT OR Contamination_OR OR LT_104.Low_Alarm OR LT_105.High_Alarm OR FT_102.General_Fault;
FV_102(
    Control_Signal := FC_102.XOUT,
    Manual_Mode := FALSE,
    Manual_Position := 0.0,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Inhibit := FV102_Inhibit_OR);
SP101_1p1_MULT := SP101_SP_EU_MULT * 1.1;
SP101_PV_GT_HighThresh := (FT_101.PV > SP101_1p1_MULT);
SP101_0p9_MULT := SP101_SP_EU_MULT * 0.9;
SP101_PV_LT_LowThresh := (FT_101.PV < SP101_0p9_MULT);
SP101_DevBand_OR := SP101_PV_GT_HighThresh OR SP101_PV_LT_LowThresh;
SP101_DevDelay_TON(
    IN := SP101_DevBand_OR,
    PT := T#30s);
SP102_1p1_MULT := SP102_SP_EU_MULT * 1.1;
SP102_PV_GT_HighThresh := (FT_102.PV > SP102_1p1_MULT);
SP102_0p9_MULT := SP102_SP_EU_MULT * 0.9;
SP102_PV_LT_LowThresh := (FT_102.PV < SP102_0p9_MULT);
SP102_DevBand_OR := SP102_PV_GT_HighThresh OR SP102_PV_LT_LowThresh;
SP102_DevDelay_TON(
    IN := SP102_DevBand_OR,
    PT := T#30s);

(* Outputs published to other sections / HMI. *)
FT101_Flow_PV := FT_101.PV;
FT102_Flow_PV := FT_102.PV;
AT101_Analyzer_PV := AT_101.PV;
AT103_Analyzer_PV := AT_103.PV;
LT104_Level_PV := LT_104.PV;
LT105_Level_PV := LT_105.PV;
FC101_MV_Out := FC_101.XOUT;
FC102_MV_Out := FC_102.XOUT;
FV101_Valve_Position := FV_101.Valve_Position;
FV102_Valve_Position := FV_102.Valve_Position;
FlowDevAlarm101 := SP101_DevDelay_TON.Q;
FlowDevAlarm102 := SP102_DevDelay_TON.Q;

END_PROGRAM
