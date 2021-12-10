# ECE 287 A (Fall 2021) Final Project


## **Proportional Integral Derivative (PID) Control Implementation on FPGA Architecture - Isaac Budde & Alyssa Winn**

Excecuted on Intel/Altera Cyclone IV FPGA (_Terasic DE2-115 Demonstrator_)

### **Project Synopsis :**
PID control is a common industrial control algorithm used to enhance system stability and error response time. This algorithm, often referred to as PID, regularly calculates an error value _e(t)_ as the difference between a desired control value (setpoint), _SP_, and the real-time execution value obtained from the control feedback loop (process variable), _PV_. The algorithm then performs a correction for identified error by incrementing the command output with calculated values of proportional (real-time), integral (past response), and derivative (future response) terms in the equation below:

<img src="https://latex.codecogs.com/gif.latex?u(t)&space;=&space;K_pe(t)&space;&plus;&space;K_i\int_{0}^{t}e(\tau)d\tau&plus;K_d\frac{d}{dt}e(t)" title="u(t) = K_pe(t) + K_i\int_{0}^{t}e(\tau)d\tau+K_d\frac{d}{dt}e(t)" />

By performing a Z-transform (conversion of the discrete time signal into an equivalent expression in the frequency domain) of the above equation, we derive the following algorithm for implementation:

<img src="https://latex.codecogs.com/gif.latex?u[k]=u[k-1]&plus;(K_p&plus;K_i&plus;K_d)e[k]&plus;(-K_p-2K_d)e[k-1]&plus;(K_d)e[k-2]" title="u[k]=u[k-1]+(K_p+K_i+K_d)e[k]+(-K_p-2K_d)e[k-1]+(K_d)e[k-2]" />

The identification of the above approach allowed for the implementation of PID control in Verilog for synthesis on FPGA hardware.

### **Background Information :**
Development of the control approach known today as the PID algorithm began in 1911 with the creation of a feedback-reactive pneumatic controller by Elmer Sperry. In 1922, Nicolas Minorsky introduced the theoretical analysis of the PID concept through collaboration with the US military, and the first implementation of the proportional control (P) algorithm was achieved in 1933 by the Taylor Instrument Company. Taylor added the integral and derivative terms to improve accuracy in 1940, leading to the foundation of PID as a reliable control algorithm that is still used today.

Modern implementations of user-programmable PID controllers are often found in industrial environments where programmable logic controllers (PLCs) are used for process control. PLCs possess the inherent limitation of serial updating, wherein the set analysis of input, control, and output conditions is performed only once per clock cycle.

The use of FPGA hardware, however, allows for parallel execution of numerous logic paths with each clock cycle. Therefore, the parallel execution of non-interdependent logic paths allows for more rapid response to changing control loop conditions, as well as user interface updating.


### **Additional Reading**

_Additional information on PID control can be obtained from Karl Johan Åström’s_ Control System Design _linked here:_
 http://www.cds.caltech.edu/~murray/courses/cds101/fa02/caltech/astrom-ch6.pdf

### **Project Implementation Outline**

Contained within this repository is the working directory of the Intel Quartus Prime project. The top-level module of the project is `pid.v`, which implements the PID algorithm as well as control and instantiation of:
- User interface functions
- Command system functions
- Feedback system functions

This module is intended to be used in conjunction with a Kollmorgen AKD servo controller with associated motor and encoder. 

General outline of project features:
- User interface on DE2-115 board including LCD overview of `Kp`, `Ki`, and `Kd` scalar terms, as well as `control and feedback velocities` in RPM.
- User-editable parameters for `Kp`, `Ki`, `Kd`, and `control velocity` selectable with `SW[3:0]`, whereby:
    - Activation of `SW[3]` selects `control velocity (C)` as the active parameter
    - Activation of `SW[2]` selects `Kp (P)` as the active parameter
    - Activation of `SW[1]` selects `Ki (I)` as the active parameter
    - Activation of `SW[0]` selects `Kd (d)` as the active parameter
- Display of active parameter on `HEX[5:0]` and its value, wherein:
    - `HEX[5]` displays the selected parameter `(C, P, I, d)`
    - `HEX[4]` displays an equality representation, `=`
    - `HEX[3]` displays the thousands place of the active parameter (`C` parameter only)
    - `HEX[2]` displays the hundreds place of the active parameter
    - `HEX[1]` displays the tens place of the active parameter
    - `HEX[0]` displays the ones place of the active parameter
    - _Note: Values of `K*` are represented as three-digit values bounded within [0, 999], but their implementation is scaled by division such that their actual values are bounded within [0, 0.999] with linear correlation. Value of `C` is represented at true scale as RPM._
- Selected parameter can be changed using `KEY[3]` (increment) and `KEY[2]` (decrement).
- DE2-115 demonstrator receives encoder feedback on `EX_IO[0]` at a rate of 60 pulses per revolution.
- DE2-115 demonstrator returns PWM-encoded control signal on `EX_IO[1]` such that the linear relation between the command RPM and a valid control RPM of [0, 10000] RPM is represented as a 0 - 100% duty cycle signal on a 100 Hz carrier.

Hardware interface information:
- The Kollmorgen AKD is configured such that enable/disable state control is implemented without interaction with the FPGA - this includes safe torque off (STO), start/stop command, and all other discrete features.
- The Kollmorgen AKD is configured such that the received encoder status is replicated on connector X9 for transmission to the DE2-115: Encoder Emulation Mode 1 - A quad B with once per rev index pulse; Emulation resolution 60 lines/rev; Index offset 0
- Connector X9 Pin 3 serves as the output ground reference, while Connector X9 Pin 7 serves as the rotational index output.
- DRV.CMDSOURCE is set to 3 (Analog) and DRV.OPMODE is set to 1 (Velocity).
- Analog input (X8) is set to mode 2 (MT Target Velocity) with a LPF at 5KHz, 0 V offset and deadband, and a 1000 rpm/V scale to achieve a 0 - 10,000 RPM command over a 0 - 10V input range.
- Conversion from FPGA command output (PWM) to drive command input (0 - 10V analog) is achieved with the PWM command connected to an RC filter (10k ohm/22uF), which is in turn connected to the non-inverting input of an LM358 operational amplifier configured for non-inverting operation with a gain of 3 and rail voltage of 12VDC.
- Conversion from drive feedback output (5V TTL) to FPGA feedback input (3.3V TTL) is achieved with the use of a TI SN74AHCT125 logic level buffer.
 
Description of project modules:
- `pid.v`: Top level module as described above
- `lcd.v`: FSM to provide constant update of LCD values
- `motor_rpm_count.v`: Module to count number of motor rotation pulses in one second and return numeric representation
- `output_pwm_gen.v`: Module instantiated with command value obtained from PID algorithm calculation to generate PWM output as described above
- `seg7_act_val.v`: Module to display a varied-width register value on the 7-segment displays based on a 4-bit select signal
- `seven_segment.v`: Module to drive an individual 7-segment display with a 4-bit decimal input dependent on a 1-bit enable signal
- `decimal_val.v`: Module to convert a 12-bit input number (K parameter) into three, 8-bit ASCII values for passage to LCD FSM
- `velocity_decimal_val.v`: Module to convert a 16-bit input number (C parameter) into four, 8-bit ASCII values for passage to LCD FSM

### **Implementation Results**
_The following describes the validation of the PID controller in a simulated environment, using a signal generator to provide an encoder pulse input and an oscilloscope to demonstrate control output duty cycle._

For testing of the PID controller, a simulation setup was created to achieve a reliable 1,000 RPM output control pulse based on an encoder feedback input that represented the feedback velocity as constantly changing and lower than actual velocity.

The photos and video below detail the testing setup as well as user control to achieve a reliable command velocity of 1000 RPM.



// Add photos/video 12/10/21


### **Conclusion :**
In conclusion, the PID project was a success. Although we were unable to test our PID module on the servo motor (unable to get access to a necessary logic converter PWM to voltage component before project deadline), we were able to test our PID controller through simulation on Dr. P. Jamieson’s request. As stated in the **Background Information** section of this README file, the PID is able to update much quicker on the FPGA, proving that there is significant improvement in acquiring a desired RPM.


**_The completion time of our project was approximately 100 working hours, with a turn in date of December 11th, 2021._**

### **Citations :**
Åström, K.L. Control System Design: PID Control (2002). University of California Santa Barbara, Department of Mechanical and Environmental Engineering. Retrieved from www.cds.caltech.edu/~murray/courses/cds101/fa02/caltech/astrom-ch6.pdf

Brunner, D. et al. Transforming Ladder Logic to Verilog for FPGA Realization of
Programmable Logic Controllers (2017). Miami University, Departments of Mechanical and Manufacturing Engineering and Electrical and Computer Engineering. Retrieved from https://www.researchgate.net/publication/319228771_Transforming_Ladder_Logic_to_Verilog_for_FPGA_Realization_of_Programmable_Logic_Controllers

J. Cahill, “PID control history and advancements,” Emerson Automation Experts,      03-Apr-2013. Retrieved from https://www.emersonautomationexperts.com/2013/control-safety-systems/pid-control-history-and-advancements/

Mizuno, N. Hashigo (2016). Repository on GitHub. Miami University, Department of Electrical and Computer Engineering. Retrieved from https://github.com/NigoroJr/hashigo

N.p., Omega Engineering, N.d. Retrieved from https://www.omega.co.uk/prodinfo/pid-controllers.html


Simply Embedded, Youtube, 07-Nov-2018. Retrieved from
https://youtu.be/zNln9hJ5J78

