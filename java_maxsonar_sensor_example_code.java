//The following is made for the T7/T7-Pro and is most effective when no condensation is expected on the sensor.
//The sensor has a range of 300mm to 5000mm
//Expected connections: Sensor - FIO0, AIN3, OBA(DAC0), GND
import com.sun.jna.ptr.IntByReference;
import com.sun.jna.ptr.DoubleByReference;
import com.labjack.LJM;
import com.labjack.LJMException;
import java.Math;

public class MaxsonarSensor{
	public static void main(String [] args){
		try{
			//The following value can be set to a range of 2.7 V to 5.0 V.
			double vsupply = 3.3;

			//Find LabJack device
			IntByReference handleRef = new IntByReference(0);
			LJM.openS("ANY", "ANY", "ANY", handleRef);
			int handle = handleRef.getValue();

			//Initialize variables
            		DoubleByReference valueRef = new DoubleByReference(0);
			String[] name = ["DIO_EF_CLOCK0_ENABLE", "DIO_EF_CLOCK1_ENABLE", "DIO_EF_CLOCK2_ENABLE", "DIO_EF_CLOCK0_DIVISOR", "DIO_EF_CLOCK0_OPTIONS", "DIO_EF_CLOCK0_ROLL_VALUE", "DIO0_EF_ENABLE", "DAC0"];
			double[] nums = {0, 0, 0, 1, 0, 0, 0, vsupply};
			numFrames = name.length();

			//Power sensor and makes sure all settings are default
			LJM.eWriteNames(handle, numFrames, name, num);
			System.out.println("Measuring...");

			//The following sets up the DIO_EF to measure PWM output
			String[] clockName = ["DIO0_EF_INDEX", "DIO_EF_CLOCK0_ENABLE", "DIO0_EF_ENABLE"];
			int[] clockNum = {5, 1, 1};
			numFrames = clockName.length();
			LJM.eWriteNames(handle, numFrames, clockName, clockNum);
		
			//Give time to ensure sensor can get a reading.
			wait(8);

			//Measures ToF of sonar in seconds.
			ljm.eReadName(handle, "DIO0_EF_READ_A_F_AND_RESET", valueRef);
			double pwm = valueRef.getValue();
			System.out.println("The ToF is " + pwm + " seconds");
			//Converts to distance.
			double pwmf = math.trunc(pwm*1000*3.28084*1000)/1000;
			double pwmm = math.trunc(pwm*1000*1000)/1000;
			//Print results for viewer
			System.out.println("The PWM output measured a distance of: " + pwmf + " feet and " + pwmm + " meters.");
		
			//Measures the ain output.
			ljm.eReadName(handle, "AIN3", valueRef);
			double ain =  valueRef.getValue();
			//Converts to distance.
			double ainf = Math.round(ain*((5.120*3.28084)/vsupply)*1000)/1000;
			double ainm = Math.round(ain*(5.120/vsupply)*1000)/1000;
			//Print results for viewer
			System.out.println("The analog output measured a distance of: " + ainf + " feet and " + ainm + " meters.");

			//Close Device
			LJM.close(handle);
		}catch (LJMException le){
			le.printStackTrace();
		}
	}
}