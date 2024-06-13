# MIPS Assembly Calendar Application

## Project Description

The objective of this assignment is to write a MIPS code for viewing, editing, and managing appointments within a monthly calendar. The application provides users with a user-friendly interface to interact with the calendar functionality, allowing them to add, edit, and view appointments for specific dates.

### Calendar Format:

The calendar will be stored in a text file with the following format:
    
1. Each line represents a day.
2. The line starts with an index indicating the day in the month.
3. The working day starts from 8 AM to 5 PM.
4. There are three types of appointments: Lectures (L), Office Hours (OH), and Meetings (M).
5. To reserve a slot, provide the start and end time with the type of appointments separated by a comma. For example, the following line represents the following appointments:
          
   `11: 8-9 L, 10-12 OH, 12-2 M`
          
   - From 8 to 9 there is a lecture.
   - From 10 to 12 reserved for office hours.
   - From 12 to 2 for a meeting.
   - The other slots are free. 

### Functionality:

The program provides the following functionality: 
    
1. `View the Calendar`: The program lets the user view the calendar per day, per set of days, or for a given slot in a given day.
2. `View Statistics`: Number of lectures (in hours), number of OH (in hours), and number of meetings (in hours). Additionally, the program shows the average number of lectures per day and the ratio between the total number of hours reserved for lectures and the total number of hours reserved for OH.
3. `Add a New Appointment`: The user provides the required information: day number, slot, and type. The program checks for conflicts with existing appointments.
4. `Delete an Appointment`: The user provides the required information: day number, slot, and type. If there are two slots of the same type, the program deletes the first one.

### Examples:

A set of test cases is provided where each functionality from the menu is tested and verified. For instance, a new office hour is added on day 20 from 8 to 9.

## How to Run the Program Using MARS Simulator

To run the MIPS calendar application using the MARS (MIPS Assembler and Runtime Simulator) simulator, follow these steps:

1. **Download and Install MARS:**
   - Download the MARS simulator from [MARS official website](http://courses.missouristate.edu/kenvollmar/mars/).
   - Install the MARS simulator on your computer.

2. **Prepare the Calendar Text File:**
   - Ensure you have the calendar text file in the required format as described above.
   - Place the text file in the same directory as your MIPS assembly code.

3. **Load the MIPS Assembly Code:**
   - Open the MARS simulator.
   - Load your MIPS assembly code file (`.asm`) into MARS by clicking `File` -> `Open` and selecting your file.

4. **Configure Program Arguments:**
   - If your program requires command-line arguments (e.g., the name of the calendar text file), configure them by clicking on `Settings` -> `Program Arguments` and entering the required arguments.

5. **Assemble the Code:**
   - Assemble your code by clicking the `Assemble` button (or pressing `F3`). This checks your code for syntax errors and prepares it for execution.

6. **Run the Program:**
   - Run your assembled program by clicking the `Run` button (or pressing `F5`).
   - Follow the on-screen instructions to interact with the calendar application.

7. **Debugging:**
   - Use MARS’s debugging tools to step through your code, set breakpoints, and inspect registers and memory to troubleshoot any issues that arise.

### Notes:
- Ensure that your MIPS code handles file input/output correctly and that it can read from and write to the calendar text file.
- Test your program thoroughly with the provided test cases to ensure all functionalities work as expected.

By following these steps, you can successfully run and interact with your MIPS calendar application using the MARS simulator.
