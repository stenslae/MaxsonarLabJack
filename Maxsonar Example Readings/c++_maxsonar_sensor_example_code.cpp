//The following is made for the T7/T7-Pro and is most effective when no condensation is expected on the sensor.
//The sensor has a range of 300mm to 5000mm
//Expected connections: Sensor - FIO0, AIN3, OBA(DAC0), GND

//For printing and rounding
#include <stdio.h>
#include <math.h>

//LJM
#include <LabJackM.h>

//For sleep
#ifdef _WIN32
#include <windows.h>
#else
#include <unistd.h>
#endif


int main() {
	//The following value can be set to a range of 2.7 V to 5.0 V.
	double vsupply = 3.3;


	int err, handle, erraddress;
	double value = 0;
	const char* NAME = { "SERIAL_NUMBER" };

	//Find LabJack device
	err = LJM_Open(LJM_dtANY, LJM_ctANY, "LJM_idANY", &handle);

	//Initialize variables
	double pwm = 0;
	double ain = 0;

	//Initialize variables
	# define NUM_FRAMES 8
	const char *names[NUM_FRAMES] = {"DIO_EF_CLOCK0_ENABLE", "DIO_EF_CLOCK1_ENABLE", "DIO_EF_CLOCK2_ENABLE", "DIO_EF_CLOCK0_DIVISOR", "DIO_EF_CLOCK0_OPTIONS", "DIO_EF_CLOCK0_ROLL_VALUE", "DIO0_EF_ENABLE", "DAC0"};
	double nums[NUM_FRAMES] = {0, 0, 0, 1, 0, 0, 0, vsupply};

	//Powers sensor and makes sure all settings are default.
	err = LJM_eWriteNames(handle, NUM_FRAMES, names, nums, &erraddress);
	printf("Measuring...");

	//The following sets up the DIO_EF to measure PWM output
	# define NUM_FRAMES_2 3
	const char *clockNames[NUM_FRAMES_2] = {"DIO0_EF_INDEX", "DIO_EF_CLOCK0_ENABLE", "DIO0_EF_ENABLE"};
	double clockNums[NUM_FRAMES_2] = {5, 1, 1};

	err = LJM_eWriteNames(handle, NUM_FRAMES_2, clockNames, clockNums, &erraddress);

	//Give time to get a sensor reading
	#ifdef _WIN32
	Sleep(8 * 1000);
	#else
	sleep(8);
	#endif

	//Measures ToF of sonar in seconds.
	err = LJM_eReadName(handle, "DIO0_EF_READ_A_F_AND_RESET", &pwm);
	printf("The ToF is %f seconds.\n", pwm);

	//Converts to distance.
	double pwmf = round(pwm * 1000 * 3.28084 * 1000) / 1000;
	double pwmm = round(pwm * 1000 * 1000) / 1000;
	//Print results for viewer
	printf("The PWM output measured a distance of: %f feet and %f meters.\n", pwmf, pwmm);

	//Measures the ain output.
	err = LJM_eReadName(handle, "AIN3", &ain);

	//Converts to distance.
	double ainf = round(ain * ((5.120 * 3.28084) / vsupply) * 1000) / 1000;
	double ainm = round(ain * (5.120 / vsupply) * 1000) / 1000;
	//Print results for viewer
	printf("The analog output measured a distance of: %f feet and %f meters.\n", ainf, ainm);

	// Close device handle 
	err = LJM_Close(handle);

	return err;
}