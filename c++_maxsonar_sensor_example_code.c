//The following is made for the T7/T7-Pro and is most effective when no condensation is expected on the sensor.
//The sensor has a range of 300mm to 5000mm
//Expected connections: Sensor - FIO0, AIN3, OBA(DAC0), GND

#include <stdio.h>
#include <LabJackM.h> 
#include "LJM_Utilities.h" 
#include <thread>
#include <chrono>
#include <vector>
#include <cmath>
#include <string>

int main() { 
	//The following value can be set to a range of 2.7 V to 5.0 V.
	double vsupply = 3.3;


	int err, handle; 
	double value = 0; 
	const char * NAME = {"SERIAL_NUMBER"}; 

	//Find LabJack device
	err = LJM_Open(LJM_dtANY, LJM_ctANY, "LJM_idANY", &handle);
	ErrorCheck(err, "LJM_Open");

	//Initialize variables
	double pwm = 0;
	double ain = 0;

	//Initialize variables
	std::vector<std::string> names = {"DIO_EF_CLOCK0_ENABLE", "DIO_EF_CLOCK1_ENABLE", "DIO_EF_CLOCK2_ENABLE", "DIO_EF_CLOCK0_DIVISOR", "DIO_EF_CLOCK0_OPTIONS", "DIO_EF_CLOCK0_ROLL_VALUE", "DIO0_EF_ENABLE", "DAC0"};
	std::vector<double> nums = {0, 0, 0, 1, 0, 0, 0, vsupply};
	int numFrames = names.size();

	// Convert names to char* array for LJM_eWriteNames
	std::vector<const char*> namePtrs;
	for (const auto& name : names) {
		namePtrs.push_back(name.c_str());
    	}

	//Powers sensor and makes sure all settings are default.
	err = LJM_eWriteNames(handle, numFrames, name, num);
	ErrorCheck(err, "LJM_eWriteNames");
	printf("Measuring...");

	//The following sets up the DIO_EF to measure PWM output
	std::vector<std::string> clockNames = {"DIO0_EF_INDEX", "DIO_EF_CLOCK0_ENABLE", "DIO0_EF_ENABLE"};
	std::vector<double> clockNums = {5, 1, 1};
	numFrames = clockNames.size();

	// Convert clockNames to char* array for LJM_eWriteNames
	std::vector<const char*> clockNamePtrs;
	for (const auto& name : clockNames) {
		clockNamePtrs.push_back(name.c_str());
	}

	err = LJM_eWriteNames(handle, numFrames, clockName, clockNum);
	ErrorCheck(err, "LJM_eWriteNames");

	//Give time to get a sensor reading
	std::this_thread::sleep_for(std::chrono::seconds(8));

	//Measures ToF of sonar in seconds.
	err = LJM_eReadName(handle, "DIO0_EF_READ_A_F_AND_RESET", &pwm);
	ErrorCheck(err, "LJM_eReadName");
	printf("The ToF is %f seconds.\n", pwm);

	//Converts to distance.
	pwmf = round(pwm*1000*3.28084*1000)/1000;
	pwmm = round(pwm*1000*1000)/1000;
	//Print results for viewer
	printf("The PWM output measured a distance of: %f feet and %f meters.\n", pwmf, pwmm);

	//Measures the ain output.
	err = LJM_eReadName(handle, "AIN3", &ain);
	ErrorCheck(err, "LJM_eReadName");

	//Converts to distance.
	double ainf = round(ain*((5.120*3.28084)/vsupply)*1000)/1000;
	double ainm = round(ain*(5.120/vsupply)*1000)/1000;
	//Print results for viewer
	printf("The analog output measured a distance of: %f feet and %f meters.\n", ainf, ainm);

	// Close device handle 
	err = LJM_Close(handle); 
	ErrorCheck(err, "LJM_Close"); 
	return LJME_NOERROR; 

}
