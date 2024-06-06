import com.sun.jna.ptr.IntByReference;
import com.sun.jna.ptr.DoubleByReference;
import java.util.concurrent.TimeUnit;
import com.labjack.LJM;
import com.labjack.LJMException;

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
			String[] name = {"DIO_EF_CLOCK0_ENABLE", "DIO_EF_CLOCK1_ENABLE", "DIO_EF_CLOCK2_ENABLE", "DIO_EF_CLOCK0_DIVISOR", "DIO_EF_CLOCK0_OPTIONS", "DIO_EF_CLOCK0_ROLL_VALUE", "DIO0_EF_ENABLE", "DAC0"};
			double[] num = {0, 0, 0, 1, 0, 0, 0, vsupply};
			int numFrames = name.length;

			//Power sensor and makes sure all settings are default
			LJM.eWriteNames(handle, numFrames, name, num, handleRef);
			System.out.println("Measuring...");

			//The following sets up the DIO_EF to measure PWM output
			String[] clockName ={"DIO0_EF_INDEX", "DIO_EF_CLOCK0_ENABLE", "DIO0_EF_ENABLE"};
			double[] clockNum = {5, 1, 1};
			int clockFrames = clockName.length;
			LJM.eWriteNames(handle, clockFrames, clockName, clockNum, handleRef);
		
			//Give time to ensure sensor can get a reading.
			try {
				TimeUnit.SECONDS.sleep(8);
			} catch (InterruptedException e) {
				e.printStackTrace();
                Thread.currentThread().interrupt();
			}

			//Measures ToF of sonar in seconds.
			LJM.eReadName(handle, "DIO0_EF_READ_A_F_AND_RESET", valueRef);
			double pwm = valueRef.getValue();
			System.out.println("The ToF is " + pwm + " seconds");
			//Converts to distance.
			double pwmf = Math.round(pwm*1000*3.28084*1000)/1000.0;
			double pwmm = Math.round(pwm*1000*1000)/1000.0;
			//Print results for viewer
			System.out.println("The PWM output measured a distance of: " + pwmf + " feet and " + pwmm + " meters.");
		
			//Measures the ain output.
			LJM.eReadName(handle, "AIN3", valueRef);
			double ain =  valueRef.getValue();
			//Converts to distance.
			double ainf = (Math.round(ain*((5.120*3.28084)/vsupply)*1000))/1000.0;
			double ainm = (Math.round(ain*(5.120/vsupply)*1000))/1000.0;
			//Print results for viewer
			System.out.println("The analog output measured a distance of: " + ainf + " feet and " + ainm + " meters.");

			//Close Device
			LJM.close(handle);
		}catch (LJMException le){
			le.printStackTrace();
		}
	}
}