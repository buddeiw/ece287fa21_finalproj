# ECE 287 A (Fall 2021) Final Project -- Isaac Budde & Alyssa Winn

## **Proportional Integral Derivative (PID) Control Implementation**
Excecuted on Cyclone IV FPGA Hardware (_Altera DE2-115 Demonstrator_)

### **Project Synopsis :**
PID control is a common industrial control algorithm used to stabilize system control and response time. This algorithm, often referred to as PID,
    constantly calculates an error value e(t) as the difference between a desired value, or setpoint, SP, and the real-time measured value, or process variable, PV. The algorithm then performs a correction for this error by calculation of proportional (real-time), integral (past response), and derivative (future response) terms for controller output.

### **Background Information :**
Starting in 1911, the first controller similar to a PID was created by Elmer Sperry. It was not until working with the US military on automatic steering systems in 1922 that a man named Nicolas Minorsky created the first theoretical analysis of a PID controller. In the year 1933, the Taylor Instrument Company (TIC), known for their efforts in machine accuracy during WWII, implemented the proportional controller into their pneumatic controller. To improve the overshooting and steady state errors, TIC created a new controller that implements both integration and derivative calculations in 1940. 

 As for the creation of this final project, we thought it would be a good idea to test the limits of a PID controller. Because of the FPGA’s real time value, the PID controller can update much quicker than a programmable logic controller (PLC) is able to. Therefore, Dr. Peter Jamieson suggested that formulating a PID controller module that runs much more efficiently than a PLC would be a good approach to our final project. In a real world setting, it is important to keep in mind that although a working machine is critical to obtain, one that contains systematic timing is very important as well.

### **Where To Find More Information On PID :**
_For more information on proportional-integral-derivative control, you can reference Karl Johan Åström’s document, provided with the link below:_

 http://www.cds.caltech.edu/~murray/courses/cds101/fa02/caltech/astrom-ch6.pdf

### **What We Did (***Description of the Project Outline***) :**
 In this repository, we added the proportional-integral-derivative control features with Verilog on the DE2-115 FPGA that can be extended to a servo motor drive output.

 To start, we designed a PID controller module t3o execute on the FPGA (Altera Cyclone IV) DE2-115 demonstrator. Once the PID controller module was created, we designed another Verilog module that allows the user to adjust the K values for error calculations. These error calculations allow the user to switch on the DE2-115 for more accurate machine response times. The active K value (Kp, Ki, or Kd) is selectable using the toggle switches on the DE2-115 board, and the PID controller continuously scans the set K values with the implementation of a set of automatic clock registers. The current value is displayed on the DE2-115 LCD, and can be adjusted in up/down increments with two pushbuttons.

 For the purposes of this project, the PID controller implementation focuses on the servo motor operations and hall-effect encoder feedback. The GPIO header of the DE2-115 is used to interface with this hardware, and a basic test program is designed to control the servo for testing. The K values for the PID controller can be adjusted until the process is deemed to be at-or near-RPM unity.

### **Improvements/Result :**
_By setting our C value to 1000 RPM, we are able to implement the PID to control a consistent speed within 10 RPM of our desired output._

_* Here are some major improvements made throughout the process of this project:_

    - Module’s ability to have automatic updating values.

    -   Ability to speed up the LCD’s display time.

    - Numerical speed of calculated values improved.
    (including the removal of any numerical error values)

    - Module’s ability to output a signal pulse to the servo motor. 


### **Photo/Video Of Project :**
_photos and video will be added later after demo_
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

