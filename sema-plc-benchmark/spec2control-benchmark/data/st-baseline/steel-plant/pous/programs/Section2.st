PROGRAM Section2
VAR
	FT101_WildFlow_PV : real;
	FT102_FluxFlow_PV : real;
	TIT101_Temperature_PV : real;
	FFIC103_FluxFlow_SP : real;
	FT_101 : ANALOG_IN;
	FT_102 : ANALOG_IN;
	TIT_101 : ANALOG_IN;
	FFIC_103 : RATIO_CONTROL;
	FIC_102 : PID_BASIC;
	FV_102 : VALVE_ELECTRIC;
	LowFlow_OK_GT : bool;
	FFIC103_LowTempOrLowFlow_OR : bool;
	FFIC103_SensorFaults_OR : bool;
	FFIC103_RangeOrLowTempLowFlow_OR : bool;
	FFIC103_Inhibit_OR : bool;
END_VAR

FT_101(
    PV_Low := 50.0,
    Scaling_Slope := 62.5,
    Scaling_Offset := -250.0,
    Alarm_Enable := TRUE);
FT_102(
    Alarm_Enable := TRUE);
TIT_101(
    PV_Low := 800.0,
    Alarm_Enable := TRUE);
FFIC103_LowTempOrLowFlow_OR := FT_101.Low_Alarm OR TIT_101.Low_Alarm;
FFIC103_RangeOrLowTempLowFlow_OR := FT_101.High_Alarm OR FFIC103_LowTempOrLowFlow_OR;
FFIC103_SensorFaults_OR := FT_101.General_Fault OR FT_102.General_Fault;
FFIC103_Inhibit_OR := FFIC103_SensorFaults_OR OR FFIC103_RangeOrLowTempLowFlow_OR;
LowFlow_OK_GT := (FT_101.PV > 50.0);
FFIC_103(
    Auto := LowFlow_OK_GT,
    PrimaryPV := FT_101.PV,
    SecondaryPV := FT_102.PV,
    RatioSP := 0.4,
    MV_MIN := 200.0,
    MV_MAX := 300.0,
    Inhibit := FFIC103_Inhibit_OR);
FIC_102(
    AUTO := LowFlow_OK_GT,
    PV := FT_102.PV,
    SP := FFIC_103.SlaveSP);
FV_102(
    Control_Signal := FIC_102.XOUT,
    Inhibit := FFIC103_LowTempOrLowFlow_OR);

(* Outputs published to other sections / HMI. *)
FT101_WildFlow_PV := FT_101.PV;
FT102_FluxFlow_PV := FT_102.PV;
TIT101_Temperature_PV := TIT_101.PV;
FFIC103_FluxFlow_SP := FFIC_103.SlaveSP;

END_PROGRAM
