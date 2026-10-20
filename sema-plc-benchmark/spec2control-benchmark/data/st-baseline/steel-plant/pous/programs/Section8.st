PROGRAM Section8
VAR
	FT701_FuelFlow_PV : real;
	FT702_AirFlow_PV : real;
	TT701_FurnaceTemp_PV : real;
	FLT701_FuelTankLevel_PV : real;
	FT702_SP_Ratio : real;
	FFIC701_ActiveRatio : real;
	FFIC701_RatioError : real;
	BLS701_BurnerStatus : bool;
	BLS701_BurnerStatus_DI : bool;
	ALM701_RatioAlarm : bool;
	ALM702_FT701Fault : bool;
	ALM703_FT702Fault : bool;
	ALM704_HighTemp : bool;
	FT_701 : ANALOG_IN;
	FT_702 : ANALOG_IN;
	TT_701 : ANALOG_IN;
	FLT_701 : ANALOG_IN;
	FFIC_701 : RATIO_CONTROL;
	FIC_702 : PID_BASIC;
	FV_702 : VALVE_ELECTRIC;
	BLS_701 : BOOL_INPUT;
	FuelGE200_GE : bool;
	BurnerOff_NOT : bool;
	TxFaults_OR : bool;
	FFICInhibit_OR1 : bool;
	FFICInhibit_OR2 : bool;
	FICInhibit_OR1 : bool;
	ValveInhibit_OR1 : bool;
	ValveInhibit_OR2 : bool;
	ValveInhibit_OR3 : bool;
	FFIC_Auto_AND1 : bool;
	FFIC_Auto_AND2 : bool;
	TempHigh_NOT : bool;
	RatioMinCalc_MULT : real;
	RatioMaxCalc_MULT : real;
	Ratio8xFuel_MULT : real;
	RatioLow_GT : bool;
	RatioHigh_GT : bool;
	RatioAlarm_OR : bool;
END_VAR

FT_701(
    Alarm_Enable := TRUE);
FT_702(
    Alarm_Enable := TRUE);
TT_701(
    PV_High := 1200.0,
    Alarm_Enable := TRUE);
FLT_701();
BLS_701(
    Bool_In := BLS701_BurnerStatus_DI,
    Alarm_OnTrue := FALSE,
    Alarm_OnFalse := TRUE,
    Latch_Enable := FALSE);
BurnerOff_NOT := NOT BLS_701.Bool_Out;
FFICInhibit_OR1 := BurnerOff_NOT OR FT_701.Low_Alarm;
TxFaults_OR := FT_701.General_Fault OR FT_702.General_Fault;
FFICInhibit_OR2 := FFICInhibit_OR1 OR TxFaults_OR;
FuelGE200_GE := (FT_701.PV >= 200.0);
FFIC_Auto_AND1 := FuelGE200_GE AND BLS_701.Bool_Out;
TempHigh_NOT := NOT TT_701.High_Alarm;
FFIC_Auto_AND2 := FFIC_Auto_AND1 AND TempHigh_NOT;
Ratio8xFuel_MULT := FT_701.PV * 8.0;
RatioMaxCalc_MULT := FT_701.PV * 12.0;
RatioMinCalc_MULT := FT_701.PV * 8.0;
FFIC_701(
    Auto := FFIC_Auto_AND2,
    PrimaryPV := FT_701.PV,
    SecondaryPV := FT_702.PV,
    RatioSP := 10.0,
    Bias := 0.0,
    MV_MIN := RatioMinCalc_MULT,
    MV_MAX := RatioMaxCalc_MULT,
    ManOut := Ratio8xFuel_MULT,
    Inhibit := FFICInhibit_OR2);
FICInhibit_OR1 := BurnerOff_NOT OR TxFaults_OR;
FIC_702(
    AUTO := TRUE,
    PV := FT_702.PV,
    SP := FFIC_701.SlaveSP,
    MV_MIN := 0.0,
    MV_MAX := 100.0,
    X0 := 0.0,
    KP := 1.5,
    TR := 10.0,
    TD := 0.5,
    Deviation_Limit := 5.0,
    Inhibit := FICInhibit_OR1);
ValveInhibit_OR1 := FT_701.Low_Alarm OR TT_701.Low_Alarm;
ValveInhibit_OR2 := ValveInhibit_OR1 OR TT_701.High_Alarm;
ValveInhibit_OR3 := ValveInhibit_OR2 OR TxFaults_OR;
FV_702(
    Control_Signal := FIC_702.XOUT,
    Manual_Mode := FALSE,
    Open_Limit := 100.0,
    Close_Limit := 0.0,
    Timeout := T#10s,
    Inhibit := ValveInhibit_OR3);
RatioLow_GT := (8.0 > FFIC_701.ActiveRatio);
RatioHigh_GT := (FFIC_701.ActiveRatio > 12.0);
RatioAlarm_OR := RatioLow_GT OR RatioHigh_GT;

(* Outputs published to other sections / HMI. *)
FT701_FuelFlow_PV := FT_701.PV;
FT702_AirFlow_PV := FT_702.PV;
TT701_FurnaceTemp_PV := TT_701.PV;
FLT701_FuelTankLevel_PV := FLT_701.PV;
FT702_SP_Ratio := FFIC_701.SlaveSP;
FFIC701_ActiveRatio := FFIC_701.ActiveRatio;
FFIC701_RatioError := FFIC_701.RatioErr;
BLS701_BurnerStatus := BLS_701.Bool_Out;
ALM702_FT701Fault := FT_701.General_Fault;
ALM703_FT702Fault := FT_702.General_Fault;
ALM704_HighTemp := TT_701.High_Alarm;
ALM701_RatioAlarm := RatioAlarm_OR;

END_PROGRAM
