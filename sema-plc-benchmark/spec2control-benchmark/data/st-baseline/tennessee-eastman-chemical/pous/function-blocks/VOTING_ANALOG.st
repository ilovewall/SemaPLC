FUNCTION_BLOCK VOTING_ANALOG
VAR_INPUT
	Input1 : real;
	Input2 : real;
	Input3 : real;
	Deviation_Limit : real;
	Voting_Scheme : string;
	EnableAlarm : bool;
	Inhibit : bool;
END_VAR

VAR_OUTPUT
	Voted_Output : real;
	Sensor1_Fault : bool;
	Sensor2_Fault : bool;
	Sensor3_Fault : bool;
	Alarm_Voting_Error : bool;
	Healthy_Sensors_Count : int;
END_VAR

Voted_Output := (Input1 + Input2 + Input3) / 3.0;
Sensor1_Fault := FALSE;
Sensor2_Fault := FALSE;
Sensor3_Fault := FALSE;
Alarm_Voting_Error := FALSE;
Healthy_Sensors_Count := 3;

END_FUNCTION_BLOCK
