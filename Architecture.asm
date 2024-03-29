.data
file_loc: .asciiz "C:\\Users\\yazan\\mips\\calendar-1.txt"
ex : .asciiz "123"
wrong_option : .asciiz "Enter a number from 1 to 5 only.\n"
menuTitle : .asciiz "************ Calendar ************\n\n"
invalid_time_input : .asciiz "time should be between 8 and 5! try again\n"
option1 : .asciiz "1) View the calendar\n"
option2 : .asciiz "2) View statistics\n"
option3 : .asciiz "3) Add a new appointment\n"
option4 : .asciiz "4) Delete an appointment\n"
option5: .asciiz "5) Exit program and save changes\n\n"
enter : .asciiz "Enter a number corresponding to one of the options\n"
day_number : .asciiz "Enter day\n"
start_day : .asciiz "Enter start time"
end_day : .asciiz "Enter end time"
#intersection: .asciiz "the time you entered is invalid"
create_day : .asciiz "rrrr"
appointment: .asciiz  "what is the type of the appointment" 
printCalendar1 : .asciiz "Enter one of these options : \n\n"
printCalendar2 : .asciiz "1) View per day\n"
printCalendar3 : .asciiz "2) View per set of days\n"
printCalendar4 : .asciiz "3) View a given slot for a day\n"
printCalendar_day : .asciiz "Enter the day\n"
calendarDay_input : .asciiz "What day do you want to show?\n"
printCalendar_dayCount : .asciiz "How many days do you want to show?\n"
printCalendar_dayList : .asciiz "Enter day"
printCalendar_not_found : .asciiz "The day you entered does not exist.\n\n"
print_end : .asciiz "Terminating program...\n"
newLine : .asciiz "\n"
startTime : .asciiz "Enter start time\n"
startTime_error : .asciiz "Start time cannot be outside 8-5\n"
endTime : .asciiz "Enter end time\n"
endTime_error : .asciiz "end time cannot be outside 8-5"
statistics : .asciiz "************ Statistics ************\n\n"
number_of_lectures : .asciiz "Hours of lectures : "
number_of_office : .asciiz "Hours of Office hours : " 
number_of_meetings : .asciiz "Hours of meetings : " 
average_lectures : .asciiz "Average lectures per day : "
ratio : .asciiz "Ratio between lecture hours and office hours : "
temp_string : .space 50
substring_time : .space 7
type_count : .word 0 : 3 # index 0 for number of lectures, 1 for OH, 2 for meetings
time_slot_not_found : .asciiz "The time slot you entered does not exist. Delete failed.\n"
temp : .space 3

fileLoaded : .asciiz "File has been loaded"
time_slot_does_not_exist : .asciiz "The time slot you entered does not exist.\n"

array_pointers : .word 0 : 31 	#initialize an array of pointers, the strings will be dynamically allocated (each will hold an address)
strings : .byte 0 : 100
#error strings
readErrorMsg: .asciiz "\nError in reading file\n"
openErrorMsg: .asciiz "\nError in opening file\n"
colon: .asciiz ":"
dash: .asciiz "-"
comma: .asciiz ","
slot_type_input : .asciiz "Enter slot type (0 for L, 1 for OH, 2 for M)\n"



array_strings_letters : .word 0 : 3
L : .space 3
M : .space 3
OH : .space 3

day_num : .byte 0
create_status : .byte 0
 

out_of_Range: .asciiz "Out of range\n"
there_conflict: .asciiz "There is a conflict re enter the time\n\n"
buffer1: .space 8   # Space for the first string
buffer2: .space 8
buffer3: .space 8
buffer4: .space 8
buffer5: .space 50
substring_slot : .space 7



Delete_slot_day: .asciiz "Enter the day you want to delete the slote from:"
Delete_slot: .asciiz "Enter slot to delete\n" 
slot_type : .asciiz "Enter slot type\n"
Delete_slot_buffer: .space 7
Delete_slot_buffer2: .space 5
test_buffer: .space 50
first_buffer: .space 32
second_buffer: .space 32


.macro print_string (%string)
	li $v0, 4
	la $a0, %string
	syscall
.end_macro

.macro print_int (%int)
	li $v0, 1
	move $a0, %int
	syscall
.end_macro

.macro exit (%status)
	li $v0, 17
	li $a0, %status
	syscall
.end_macro

.macro in_range (%number, %begin, %end) #end and start are registers
	blt %number, %begin, skip_if
	bgt %number, %end, skip_if
	li $v0, 1
	j skip_2
	skip_if : 
	li $v0, 0
	skip_2 : 
.end_macro 

.macro in_range_exc (%number, %begin, %end) #end and start are registers
	ble %number, %begin, skip_if
	bge %number, %end, skip_if
	li $v0, 1
	j skip_2
	skip_if : 
	li $v0, 0
	skip_2 : 
.end_macro 

.macro add12 (%number)
	bgt %number, 5, do_not_add_12_start
	addi %number, %number, 12
	do_not_add_12_start : 
.end_macro

.macro sub12 (%number)
	ble %number, 12, do_not_add_12_start
	subi %number, %number, 12
	do_not_add_12_start : 
.end_macro

.macro open_file (%file_loc, %flag)
	#Open file for for reading purposes
	li $v0, 13          #syscall 13 - open file
	la $a0, %file_loc        #passing in file name
	li $a1, %flag               #set flag 0 (read), 1 (write)
	li $a2, 0               #mode is ignored
	syscall
	bltz $v0, openError     #if $v0 is less than 0, there is an error found
.end_macro

.macro close_file (%fd) 
	li $v0, 16
	move $a0, %fd
	syscall
.end_macro

.text
main:
	jal initialize_array_letters
	open_file (file_loc, 0) #open file for reading
	
	move $s6, $v0 #save $v0 to be used later in readLine procedure and in closing the file
	move $a0, $v0
	li $v1, 1
	loop_array : #read all lines and store in array_pointers defined above
		move $a0, $s6
		beqz $v1, end_read
		jal readLine
	j loop_array
	end_read:
	
	li $s0, 0 # store the index
	li $s7, 0 # store the number of days on the calendar
	
	loop_traverse_array : # get the statistics at the start of the program and store in the global array
		beq $s0, 30, end_loop_traverse_array 
		sll $t1, $s0, 2
		lw $a0, array_pointers + 0($t1)
		beqz $a0, skip_get_statistics
		addi $s7, $s7, 1
		jal get_statistics 
		skip_get_statistics:
		addi $s0, $s0, 1
		j loop_traverse_array
		
	end_loop_traverse_array : 
	
	loop_menu :	
		jal showMenu
		li $v0, 5
		syscall
		
		beq $v0, 1, case1
		beq $v0, 2, case2
		beq $v0, 3, case3
		beq $v0, 4, case4
		beq $v0, 5, case5
		j default
		
		case1 :
			jal printCalendar
			print_string (newLine)
			j loop_menu
		
		case2: 
			print_string (statistics)
			print_string (number_of_lectures)
			lw $a0, type_count
			li $v0, 1
			syscall
			move $s2, $a0 		# store the number of lecture hours
			mtc1 $a0, $f12 		# store the number of lecture hours here
			mtc1 $s7, $f1		# store the number of days
			print_string (newLine)
			print_string (number_of_office)
			lw $a0, type_count + 4
			li $v0, 1
			syscall
			mtc1 $a0, $f11		# store the number of office hours
			
			print_string (newLine)
			print_string (number_of_meetings)
			
			lw $a0, type_count + 8
			li $v0, 1
			syscall
			
			
			print_string (newLine)
			print_string (average_lectures)
			div.s $f12, $f12, $f1 	# divide the number of lectures and number of days
			li $v0, 2	 	# syscall code #2 : print a float number
			syscall
			
			print_string (newLine)
			print_string (ratio)
			mtc1 $s2, $f12
			div.s $f12, $f12, $f11 	# divide the number of lectures and number of office hours
			li $v0, 2	 	# syscall code #2 : print a float number
			syscall
			print_string(newLine)
			
			j loop_menu
		case3:
		     
                    print_string(day_number)
                    li $v0,5
                    sb $0, create_status
                    syscall
                    move $s1,$v0 # $s1->the day 
                    sll $t0,$v0,2 # index *  size
                    lw $t1, array_pointers + 0($t0)
                    move $t4,$t1 # move the address into $t4
                  
                    bnez $t1, enterTime # if null create a new slot
                    
                    	move $a0,$t1 # $a0 contains the address of the day slot
                    	move $a1,$v0 # $a1 contains the day number
                    	subi $sp, $sp, 4
                    	sw $ra,($sp)
                    	addi $s7, $s7, 1 # update days count for stats section
                    	jal create
                    	sb $v1, create_status # create_status = create();
                    	lw $ra,($sp)
   		    	addi $sp, $sp, 4  
   		    	move $a0,$v0  
   		       
                    enterTime:
                    
                     	print_string (start_day)
                     	print_string (newLine)
                     	
                    	li $v0,5 	# syscall #5 :  reading a number and saving in $v0
                  	syscall
                  	
                  	move $t0,$v0
                  	add12($t0)	# add 12 if $t0 is between 0 and 5
                     	in_range($t0,8,17)#17=5+12
                    	beq $v0,1 continue
                     	print_string(out_of_Range)
                     	
                  	 j enterTime
                     
                  continue:
                  
                    	print_string (end_day)
                    	print_string (newLine)
                    	li $v0,5 #read day
                    	syscall
                    	
                    	move $t1,$v0
                    	add12($t1)
                    	in_range($t1,8,17)#17=5+12
                     	beq $v0,1 continue2
                     	print_string(out_of_Range)
                     	
                     	j enterTime
                     
                    continue2:
                    
                    	blt $t0,$t1  continue3
                    	print_string(invalid_time_input)
                      	j enterTime
                      	 
                    continue3:
                    
                     	sub12($t0)
                     	sub12($t1)
                     	
                     	move $s3, $t0 # start time
			move $s4, $t1 # end time
			sll $t0, $s1, 2
			lw $a0, array_pointers + 0($t0)
			move $s5, $a0
                     	
                     	lb $t2, create_status
                     	beq $t2,1 concats # is a nw day no need to check for conflict
                    		move $a1,$s3 #start time
                    		move $a2,$s4 #end,time
                    	
                    		subi $sp, $sp, 4
				sw $ra, 0($sp)
				jal check_for_conflict
				lw $ra, 0($sp)
				addi $sp, $sp, 4
				bnez $v0, conflict
			
			j concats
		
			conflict:
			
			print_string(there_conflict)
                        j enterTime
                        
                     concats:
                     
                     	print_string (slot_type_input)
                     	li $v0, 5
                     	syscall # read type
                     	 #  preparing to call create_string_slot to create a temp slot in a buffer
                     	 # and then concat the new slot to the original array
                     	 
                     	sll $v0, $v0, 2 # make it an index of the array
                     	
                     	#update stats here
                     	add12($s3)
                     	add12($s4)
                     	
                     	lw $t0, type_count + 0($v0)
                     	sub $t1, $s4, $s3
                     	add $t0, $t0, $t1
                     	sw $t0, type_count + 0($v0)
                     	
                     	sub12($s3)
                     	sub12($s4)
                     	
                     	lw $a2, array_strings_letters + 0($v0) #load the string into $a2
                     	move $a0, $s3
                     	move $a1, $s4
                     	lb $v1, create_status
                  	jal create_string_slot # creates a slot and saves it into buffer1
                  	
                  	
                  	move $a0, $s5 # moving the array index address into $a0
                  	la $a1, buffer1 
                  	jal concat # modifies the string pointed to by $a0
			
                 
                    j loop_menu
                    
                    
		case4 :  
	
		
    		 	print_string(Delete_slot_day)  
              		li $v0,5
              	  	syscall
               	 	move $s2,$v0 # $s2->the day 
                  	sll $t0,$s2,2
                  		
                  	lw $a0,array_pointers+0($t0)
                  	move $s5, $a0
                  	bnez $a0, continue_case_4
                  	
                  		print_string(printCalendar_not_found)
                  		j loop_menu
                  		
                  	continue_case_4: 
                  	
                  	
                  	 enterTime_case4:
                    
                     		print_string (start_day)
                     		print_string (newLine)
                     	
                    		li $v0,5 	# syscall #5 :  reading a number and saving in $v0
                  		syscall
                  	
                  		move $t0,$v0
                  		move $s3, $v0
                  		add12($t0)	# add 12 if $t0 is between 0 and 5
                     		in_range($t0,8,17)#17=5+12
                    		beq $v0,1 continue_case_4_2
                     		print_string(out_of_Range)
                     	
                  		j enterTime_case4
                  		
                     	continue_case_4_2 : 
              
                  	print_string (endTime)
                     	print_string (newLine)
                     	
                    	li $v0,5 	# syscall #5 :  reading a number and saving in $v0
                  	syscall
                  	
                  	move $s4,$v0  
                  	move $t0, $v0  
                  	add12($t0)
                  	in_range($t0,8,17)#17=5+12
                    		beq $v0,1 continue_case_4_3
                     		print_string(out_of_Range)
                     		j enterTime_case4
                     	
                     	continue_case_4_3 :               		
                  		
                  	
                     	print_string (slot_type_input)
                     	li $v0, 5
                     	syscall # read type
                  
                     	
                  	move $a1,$s3
                  	move $a2,$s4
                	move $a0, $s5
                	move $a3, $s2 # move day num to $a3
                	
                  	jal Delete_slot_fun
                  	
                  	beqz $v1, endcase_4 # slot deleted
                  		sll $s2, $s2, 2 # make it an index of the array
                     		#update stats here
                     		add12($s3)
                     		add12($s4)
                     	
                     		lw $t0, type_count + 0($s2)
                     		sub $t1, $s4, $s3
                     		add $t0, $t0, $t1
                     		sw $t0, type_count + 0($s2)
                     	                                                                                             
                     		sub12($s3)
                     		sub12($s4)
                  
    		   endcase_4:
    		
		  
    		
		    j loop_menu
		    
		case5 : 
			print_string (print_end)
			close_file($s6) #close the file
			open_file(file_loc, 1) # open the same file for writing
			move $a0, $v0
			jal print_to_file
			close_file($a0)
			
			exit(0)
			
		default : 
			print_string(wrong_option)
			j loop_menu
		
			
		
	
	
	
	


#--------------------------------------------------------------------------------------------------------

print_to_file : 

	li $t0, 0 # counter for the loop to traverse the array of strings
	loop_print_to_file :
		bgt $t0, 31 end_print_to_file
		sll $t1, $t0, 2
		lw $t1, array_pointers + 0($t1)
		bnez $t1, continue_print_to_file
			addi $t0, $t0, 1
			j loop_print_to_file
		continue_print_to_file :
		move $a1, $t1 # keep reading from the same array index
		loop_print_untill_null:
			li $v0, 15 # syscall code 15 : write to file
			lb $t2, 0($a1)
			beqz $t2, exit_loop_print_untill_null
			li $a2, 1 #write character by character untill seeing the null character
			syscall
			bltz $v0, readError     #if error it will go to read error
			addi $a1, $a1, 1
			j loop_print_untill_null
		exit_loop_print_untill_null:
		la $a1, newLine # store the new line character instead of the null character 
		li $a2, 1
		syscall
		bltz $v0, readError
		addi $t0, $t0, 1
	j loop_print_to_file
	
	end_print_to_file : 
	jr $ra
	
#---------------------------------------------------------------

printCalendar : 
	
	print_string (printCalendar1)
	print_string (printCalendar2)
	print_string (printCalendar3)
	print_string (printCalendar4)
	
	# get user input and store in $v0
	li $v0, 5
	syscall
	
	beq $v0, 1, case1_calendar
	beq $v0, 2, case2_calendar
	beq $v0, 3, case3_calendar
		
	#j default #if non of those options was chosen
		
	case1_calendar: 
		
		print_string (calendarDay_input)  #print prompt (what day)
		# get user input and store in $v0
		li $v0, 5
		syscall
		
		sll $v0, $v0, 2
		lw $a0, array_pointers + 0($v0)
		beqz $a0, not_found
		li $v0, 4
		syscall
		j end_case1 #return to menu
		
		not_found :
		print_string (printCalendar_not_found) 
		j end_case1 #return to menu
		
	case2_calendar :
		print_string (printCalendar_dayCount)
		# get user input and store in $v0
		li $v0, 5
		syscall
		move $s0, $v0 # $s0 will be used as a counter
		li $t0, 1 # register for the day prompt
		 
		loop_case2_calendar :# $s0 will be used as the loop counter
			blez $s0, end_case1
			print_string (printCalendar_dayList)  #print prompt (what day)
			print_int ($t0)
			print_string (newLine)
			# get user input and store in $v0
			li $v0, 5
			syscall
			move $s1, $v0 # next line alters $v0 so we will move it to $ s1
			print_string (newLine) # this line alters $v0 so we will move it to $ s1
		
			sll $s1, $s1, 2
			lw $a0, array_pointers + 0($s1)
			subiu $s0, $s0, 1
			addi $t0, $t0, 1
			beqz $a0, not_found_case2_calendar
			li $v0, 4
			syscall
			print_string (newLine)
			j loop_case2_calendar
		
			not_found_case2_calendar :
			print_string (printCalendar_not_found) 
			j loop_case2_calendar
	
	case3_calendar : 
			print_string (calendarDay_input)
			li $v0, 5
			syscall
			sll $v0, $v0, 2
			lw $t0, array_pointers + 0($v0)
			bnez $t0, enter_start_time
				print_string(printCalendar_not_found)
				j end_case1
			
			
			enter_start_time : 
			print_string (startTime)
			li $v0, 5
			syscall
			move $s1, $v0 #store start time in $s1
			add12($s1)
			in_range ($s1, 8, 17)
			bnez $s1, enter_end_time
				print_string(invalid_time_input)
				j enter_start_time
			
			enter_end_time:
			print_string (endTime)
			li $v0, 5
			syscall
			move $s2, $v0 # store end time in $s2
			add12($s2)
			in_range ($s2, 8, 17)
			bnez $v0, continue1_case3_calendar
				print_string(invalid_time_input)
				j enter_end_time 
				
			continue1_case3_calendar:
			
			# preparing to call check_slot
			sub12($s1) # subtract 12 to better represent the original time (17 becomes 5)
			sub12($s2)
			move $a0, $t0 # get the address of the string
			move $a1, $s1 # put start time in $a1
			move $a2, $s2 # put end time in $a2
			subi $sp, $sp, 4
			sw $ra, 0($sp)
			jal check_slot # modify substring_slot to contain the slot we seek
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			bnez $v0, continue_case3_calendar
				print_string (time_slot_does_not_exist)
				j end_case1
			continue_case3_calendar :
			print_string (newLine)
			print_string (substring_slot)
			
	end_case1 : jr $ra
	
#-------------------------------------------------------------------------------------
	
	
# Function that recieves a string that represents a day of appointments in $a0
# and modifies the array for the statistics

get_statistics :
	
	subi $sp, $sp, 8
	sw $s1, 0($sp) 
	sw $s0, 4($sp) # store $ s0, s1 as they are going to be used in this function
	
	loop_skip_colon : # loop that makes $a0 point to the first character after the colon
		lb $t1, 0($a0)
		addi $a0, $a0, 1
		beq $t1, ':' end_loop_skip_colon # exit loop if the character is a colon
		j loop_skip_colon
	
	end_loop_skip_colon : 
	
	move $s0, $a0 # store the begining of the string because $a0 is going to be modified
	loop_traverse_string : #keep traversing string untill null terminator is reached
		move $a0, $s0
		lb $s1, 0($s0)
		beqz $s1, end_loop_traverse_string
		loop_till_letter : 
			lb $s1, 0($s0)
			sge $t1, $s1, 'A'
			sle $t2, $s1, 'Z'
			and $t2, $t2, $t1
			beq $t2, 1, continue_loop_get_number # go to label if char in $s1 is between A and Z
			addi $s0, $s0, 1
			j loop_till_letter
		continue_loop_get_number :
			# preparing to call get_numbers 
			move $a1, $s0
			subi $sp, $sp, 4
			sw $ra, 0($sp)
			jal get_numbers
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			add12 ($v0)
			add12 ($v1)
			sub $t1, $v1, $v0 # get number of hours in $t1
			# $s1 contains the letter
			bne $s1, 'L', continue_loop # branch if the letter is not L
				lw $t2, type_count # load the number of previous hours to $ t2
				add $t2, $t2, $t1  # compute the new number of hours
				sw $t2, type_count # update the number of hours
				j continue_loop3
			continue_loop: 
			bne $s1, 'O', continue_loop2
				lw $t2, type_count + 4
				add $t2, $t2, $t1  # add the number of hours to index
				sw $t2, type_count + 4
				j continue_loop3
			continue_loop2 : 
			bne $s1, 'M', continue_loop3 
				lw $t2, type_count + 8
				add $t2, $t2, $t1  # add the number of hours to index
				sw $t2, type_count + 8
			continue_loop3 : 
			loop_till_comma :
				lb $t2, 0($s0) 
				addi $s0, $s0, 1
				beqz $t2, end_loop_traverse_string
				beq $t2, ',', loop_traverse_string
				j loop_till_comma
			
			# restoring registers from the stack
			end_loop_traverse_string : 
			
			lw $s1, 0($sp) 
			lw $s0, 4($sp)
			addi $sp, $sp, 8
	
			jr $ra		
			
		
#-------------------------------------------------------------------------------------

# Function that takes a string that represents a day in $a0 and start and end time in %a1, $a2
# as well as type (0, 1, 2) in the stack, and modifies according to the given information
delete_appointment : 







#-------------------------------------------------------------------------------------
	

showMenu :
	print_string (menuTitle)
	print_string (option1)
	print_string (option2)
	print_string (option3)
	print_string (option4)
	print_string (option5)
	print_string (enter)
	
	jr $ra
	
#-------------------------------------------------------------------------------------

open_file_read:
	#Open file for for reading purposes
	li $v0, 13          #syscall 13 - open file
	la $a0, file_loc        #passing in file name
	li $a1, 0               #set to read mode
	li $a2, 0               #mode is ignored
	syscall
	bltz $v0, openError     #if $v0 is less than 0, there is an error found
	jr $ra

#-------------------------------------------------------------------------------------

openError:
	la $a0, openErrorMsg
	li $v0, 4
	syscall
	j endProgram
	
#-------------------------------------------------------------------------------------

readError:
	la $a0, readErrorMsg
	li $v0, 4
	syscall
	j endProgram
	
#-------------------------------------------------------------------------------------

endProgram:
	li $v0, 10
	syscall
	
#-------------------------------------------------------------------------------------
	
	
#takes address in $a0 and returns length in $v0	
strlen : 
	li $v0, 0 #counter
	move $t1, $a0

	loop_strlen : 
	     lb $t2, 0($t1) #load the character from src to a temp register
	     beqz $t2, end_strlen #end loop if null terminator is encountered
	     addi $v0, $v0, 1 #increment string
	     addi $t1, $t1, 1
	     j loop_strlen
	     
	end_strlen : jr $ra	
	
	
#-------------------------------------------------------------------------------------	


#function that reads one line from the file and saves into an array of pointers ($a0 contains fd)
readLine : 
	move $t1, $a0
	#allocate memory in the heap
	li $a0, 50 #number of bytes
	li $v0, 9 
	syscall
	
	move $t0, $v0 #holds the address of the allocated string
	li $t2, 10
	li $t3, 1 #flag
	li $t4, 0 #address base
	move $t6, $v0
	move $a0, $t1
	loop_readLine : 
		#Read input from file
		li $v0, 14          #syscall 14 - read filea
		move $a1, $t0          #stores read info into buffer
		li $a2, 1            #hardcoded size of buffer
		syscall
		lb $t1, 0($t0)
		bltz $v0, readError     #if error it will go to read error
		beqz $v0, end_readLine #end loop if eof is reached
		beq $t1, 32, loop_readLine #skip iteration if the character is space
		bne $t1, 58, hi #branch if the character is a colon
			li $t3, 0	
		hi : beqz $t3, cont
			sb $t1, temp + 0($t4)
			addi $t4, $t4, 1		
		
		cont :
		beq $t1, '\r', end_readLine_newLine #end loop if carriage return is found (end of line is reached)
		beq $t1, '\n', end_readLine_newLine #end loop if new line character is found
		addi $t0, $t0, 1     
		j loop_readLine
	
	end_readLine_newLine :
		sb $0, 0($t0) #store null character instead of newline
	end_readLine :
	move $v1, $v0
	beqz $v0, skip_readLine
		sb $0, temp + 0($t4) #store null terminator at the end of the string representing the day
		la $a0, temp
		sw $ra, 0($sp)
		jal atoi #return the number in decimals in $v0
		lw $ra, 0($sp) 
		move $t2, $v0
		sll $t2, $t2, 2 # address = array + day_number * 4 -> day number is in $t2
		sw $t6, array_pointers + 0($t2) #store the pointer in the array
	
	skip_readLine : 
	jr $ra
	
	
	
	
	
	
#-------------------------------------------------------------------------------------

	
#Function that takes file pointer ($a0) and address of the array of pointers ($a1)
fill_Array :
	move $t0, $a0
	li $t1, 0 #counter
	li $t2, 30
	li $a0, 50 #number of characters for each string 
	
	
	
#-------------------------------------------------------------------------------------


#takes a numeric string in $a0 and returns numeric value in $v0
atoi :
	subiu $sp, $sp, 8 #save return address and $t0
	sw $ra, 0($sp)
	sw $t0, 4($sp)
	jal strlen #return length in $v0
	lw $ra, 0($sp)
	addi $sp, $sp, 4 #pop from the stack
	move $t0, $t1 # $t1 points to the null char
	subiu $t0, $t0, 1 # make $t0 point to the last char
	move $t1, $v0
	
	li $v0, 0
	li $t2, 1 #register to have 10^n
	li $t5, 10 
	loop_atoi :
		beqz $t1, end_atoi
		lb $t3, 0($t0)
		subiu $t3, $t3, 48
		mul $t4, $t3, $t2
		add $v0, $v0, $t4
		subiu $t1, $t1, 1
		subiu $t0, $t0, 1
		mul $t2, $t2, $t5
		j loop_atoi
	
	end_atoi :
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	 jr $ra
	
#-------------------------------------------------------------------------------------	
	
	
#function that takes an array in $a0, start and end time in $a1 and $a2 respectively, and returns 
# a pointer to the begining of the string in $v0, 0 if not found
#assumes that each number is of length 1 or 2
check_slot :
	
	subi $sp, $sp, 12
	sw $s1, 0($sp) 
	sw $s2, 4($sp)
	sw $s0, 8($sp) # store $ s0, s1, s2 as they are going to be used in this function
	move $s1, $a1
	move $s2, $a2
	
	loop_skip_colon_check_slot : # loop that makes $a0 point to the first character after the colon
		lb $t1, 0($a0)
		addi $a0, $a0, 1
		beq $t1, 58 end_loop_skip_colon_check_slot # exit loop if the character is a colon
		j loop_skip_colon_check_slot
	
	end_loop_skip_colon_check_slot : 

	move $s0, $a0 # store the begining of the string because $a0 is going to be modified
	move $t1, $a0 # point to the begining of the number
	move $t2, $a0
	loop_traverse_string_check_slot : #keep traversing string untill null terminator is reached
		lb $t2, 0($s0)
		beqz $t2, end_loop_traverse_string_check_slot
		move $a0, $s0 # make $a0 point to the begining of the number
		loop_till_letter_check_slot : 
			lb $t3, 0($s0)
			sge $t1, $t3, 'A'
			sle $t2, $t3, 'Z'
			and $t2, $t2, $t1
			beq $t2, 1, continue_loop_get_number_check_slot # go to label if char in $s1 is between A and Z
				addi $s0, $s0, 1
				j loop_till_letter_check_slot
		continue_loop_get_number_check_slot :
			# preparing to call get_numbers 
			move $a1, $s0
			subi $sp, $sp, 8
			sw $ra, 0($sp)
			sw $a0, 4($sp) # save $a0 to get string length later
			jal get_numbers
			lw $ra, 0($sp)
			lw $a0, 4($sp)
			addi $sp, $sp, 8 # pop $ra and $a0

				#preparing to call strncpy to copy that substring into a temp buffer
				# now $a0 contains the begining of the number and $a1 the end
				
				loop_till_comma_check_slot : 
				lb $t2, 0($s0) 
				beqz $t2, copy_number_check_slot
				addi $s0, $s0, 1 # make $s0 point to the number after the comma
				beq $t2, ',', copy_number_check_slot
				j loop_till_comma_check_slot
				
			# now we have the numbers in $v0 $v1
			# now check if those numbers are equal to the given one
			copy_number_check_slot : 
		 	subi $a1, $s0, 1 #make $a1 point to the comma
			
			bne $v0, $s1, loop_traverse_string_check_slot	
			bne $v1, $s2, loop_traverse_string_check_slot
				
			sub $a2, $a1, $a0 # store length in $a2
			la $a1, substring_slot
				
			subi $sp, $sp, 4
			sw $ra, 0($sp)
			jal strncpy #copies that slot into a temp string
			lw $ra, 0($sp)
			addi $sp, $sp, 4				
			sb $0, 1($v0) # null terminate the string
				
			lw $s1, 0($sp) 
			lw $s2, 4($sp)
			lw $s0, 8($sp) # retrieve the values from the stack	
			addi $sp, $sp, 12
			jr $ra
				
	end_loop_traverse_string_check_slot:
	li $v0, 0
	lw $s1, 0($sp) 
	lw $s2, 4($sp)
	lw $s0, 8($sp) # retrieve the values from the stack
	addi $sp, $sp, 12
	jr $ra
			
		
#-------------------------------------------------------------------------------------
			
		

# Function that recieves a string in in the form ( number1 - number2), $a0 points to the begining of
# number1, $a1 points to the letter after the end of number2 and returns number1 in $v0 number2 in $v1	
#this one can be reused later	
get_numbers : 
	move $t1, $a0 
	# $t1 will be used as a temp register to point to the end of number1
	# $a0 will point to the begining of the number1
	loop_till_hyphen :  #exit the loop when $t1 points to the hyphen (end of the number)
		lb $t5, 0($t1)
		beq $t5, 45   end_loop_till_hyphen # exit if $t1 points to a hyphen
		addi $t1, $t1, 1
		j loop_till_hyphen
	
	end_loop_till_hyphen :
	sub $v0, $t1, $a0 # get the length of the number
	beq $v0, 1, continue_this_get #execute branch if length is 1
		# $a0 contains the begining of the number
		subi $sp, $sp, 4
		sw $ra, 0($sp)
		jal atoi_2
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		j continue_get_numbers
		continue_this_get : 
		lb $v0, 0($a0)
		subi $v0, $v0, 48
	# now $v0 will contain the numeric value of number1
	# make $t1 and $t2 point to the next number
	
	continue_get_numbers :
		addi $t1, $t1, 1 #make $t1 point to the begining of the next number
		move $a0, $t1 # make $a0 point to that number to call atoi
	
		move $t3, $v0 # store temporarily
		sub $v0, $a1, $a0 # get the length of the number
		beq $v0, 1, continue_this2 #execute if the length is 1
		subi $sp, $sp, 4
		sw $ra, 0($sp)
		jal atoi_2
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		j continue_get_numbers2
		continue_this2 : 
		lb $v0, 0($a0)
		subi $v0, $v0, 48
	continue_get_numbers2 : 
	
	# store the results in $v0 and $v1
	move $v1, $v0
	move $v0, $t3
	jr $ra
	


#-------------------------------------------------------------------------------------

	
# function that copies a string to another (dest in $a1 and src in $a0) (maximum length to be copied in $a2 without the null terminator)
# $v0 will point to the last character in the string
strncpy : 
	move $v0, $a1
	move $t2, $a2

	loop_strcpy : 
	     subi $t2, $t2, 1 #decrement counter
	     lb $t1, 0($a0) #load the character from src to a temp register
	     sb $t1, 0($v0) #store the character in dest
	     beqz $t1, end_strcpy #end loop if null terminator is encountered
	     beqz $t2, end_strcpy #end loop maximum number of characters were copied 
	     addi $v0, $v0, 1 #increment string
	     addi $a0, $a0, 1
	     j loop_strcpy
	
	      
	end_strcpy : jr $ra
	
	
#-------------------------------------------------------------------------------------

	
#takes a numeric string of length 2 in $a0 and returns numeric value in $v0
atoi_2 :
	
	li $v0, 10
	lb $t0, 0($a0)
	subi $t0, $t0, 48
	mul $t0, $t0, $v0
	lb $v0, 1($a0)
	subi $v0, $v0, 48
	add $v0, $v0, $t0
	
	jr $ra
	
	
#-------------------------------------------------------------------------------------
	
	
# Function that takes two intervals A and B where A = [$v0, $v1], B = [$a0, $a1] 
# and returns their intersection as [$v0, $v1]
intersection : 

	add12 ($v0)
	add12 ($v1)
	add12($a0)
	add12($a1)

	bne $v0, $a0, continue_intersection
	bne $v1, $a1, continue_intersection
		j end_intersection
		
		
	continue_intersection :
	seq $t0, $v1, $a0
	move $t1, $v0
	in_range_exc($v0, $a0, $a1)
	not $v0, $v0
	and $t3, $t0, $v0
	move $v0, $t1
	beq $t3, 1, no_intersection
	
	seq $t0, $v0, $a1
	move $t1, $v0
	in_range_exc($v1, $a0, $a1)
	not $v0, $v0
	and $t3, $t0, $v0
	move $v0, $t1
	beq $t3, 1, no_intersection
	
	move $t0, $v0 # move $v0 because it is modified by in_range macro
	move $t1, $v1
	in_range_exc ($t0, $a0, $a1)
	move $t2, $v0 # hold the result of the first
	in_range_exc ($t1, $a0, $a1)
	move $t3, $v0 # hold the result of the second
	and $t3, $t2, $v0 # if $t3 is 1 then both are true, and A is completely inside B
	
	beqz $t3, go_there 
		move $v0, $t0
		move $v1, $t1
		j end_intersection
	go_there : 
	beq $t2, $v0, both_zero #both are zero
	not $t3, $t2 
	and $t3, $t3, $v0
	beqz $t3, here
		move $v0, $a0  # if $v0 is not in range but $v1 is in range 
		# $ v1 has not been modified and is returned
		j end_intersection
	here :   # if $v0 is in range but $v1 is not in range 
	move $v0, $t0
	move $v1, $a1
	j end_intersection
	both_zero :
	# either A is a superset of B or they do not intersect
	# if $v0 ($t0) is less than $a1, then A is a superset, else they do not intersect
	 in_range_exc($a0, $t0, $t1)
	 beqz $v0, no_intersection
	 	move $v0, $a0
	 	move $v1, $a1
	 	j end_intersection
	no_intersection : 
	li $v0, 0 # no intersection
	end_intersection : 
	sub12 ($v0)
	sub12 ($v1)
	sub12($a0)
	sub12($a1)
	jr $ra
			 
#----------------------------------------------------------------------			
	
# $a1 the day
# $a0 is the address of the string
#return  $v0 and return the num in it if one digit
# $v1 = 1 if create was called 
create: 
     move $t1,$a0
     li $t3, 10
     
     sll $t7,$a1, 2
     li $a0, 50 #number of bytes
        li $v0, 9 
	syscall
	sw, $v0, array_pointers + 0($t7)
	
	move $t2, $v0 # save the address
	
	in_range($a1,0,9)#$v0 1 if yes 
	bne $v0,1,twoDigit
		addi $t0,$a1,48 # convert to string
		sb $t0, 0($t2)
		li $t0, ':'
		sb $t0, 1($t2)
	
	
	j end_create
	twoDigit:
		li $t0, ':'
		div $a1, $t3 # divide by 10
		mflo $t1
		addi $t1, $t1, 48
		sb $t1, 0($t2)
		mfhi $t1
		addi $t1, $t1, 48
		sb $t1, 1($t2)
		addi $t2, $t2, 2
		sb $t0, 0($t2)
        
        end_create:
                 li $v1,1
        jr $ra   

#-----------------------------------------------------------------------

 # this function  will connect two string together
 # input: $a0 = address of the first string
 # input:$a1 = address of the second string                                    
concat:

    # Find the length of the first string (str1)
    	move $t0, $a0
    	subi $sp,$sp,4
    	sw $ra,0($sp)
    	jal strlen
    	lw $ra,0($sp)
    	addi $sp,$sp,4
    	add $a0,$a0,$v0
    	
    copy_str2_loop:
    	lb $t4, 0($a1)      # Load the byte at the current position in str2
    	sb $t4, 0($a0)      # Store the byte at the end of str1
    	beqz $t4, concatenate_done  
    	
    	addi $a0, $a0, 1    # Move to the next position in str1
    	addi $a1, $a1, 1    # Move to the next position in str2
    	j copy_str2_loop   



	concatenate_done:
		move $a0, $t0
    		jr $ra              # Return to the caller	
    		
    			
    				
#-----------------------------------------------------------------------------------	

		
# Function that recieves a string that represents a day of appointments in $a0
#$a1->start timee $a2->end time
#v0=0 if there is no conflict
check_for_conflict:

        subi $sp, $sp, 16
	sw $s1, 0($sp) 
	sw $s2, 4($sp)
	sw $s0, 8($sp) # store $ s0, s1, s2 as they are going to be used in this function
	sw $s3, 12($sp)
	move $s1, $a1
	move $s2, $a2
	
	loop_skip_colon_add_slot : # loop that makes $a0 point to the first character after the colon
		lb $t1, 0($a0)
		addi $a0, $a0, 1
		beq $t1, ':' end_loop_skip_colon_add_slot# exit loop if the character is a colon
		j loop_skip_colon_add_slot
	
	end_loop_skip_colon_add_slot: 
	
	move $s0, $a0 
	loop_traverse_string_add_slot : 
	
		move $a0, $s0	
		lb $s3, 0($s0)
		beqz $s3, end_loop_traverse_string_add_slot
		loop_till_letter_add_slot : 
			lb $t3, 0($s0)
			sge $t1, $t3, 'A' 
			sle $t2, $t3, 'Z'
			and $t2, $t2, $t1 
			beq $t2, 1, continue_loop_get_number_add_slot # go to label if char in $s1 is between A and Z
			addi $s0, $s0, 1
			j loop_till_letter_add_slot

		continue_loop_get_number_add_slot :
			# preparing to call get_numbers 
			move $a1, $s0
			subi $sp, $sp, 4
			sw $ra, 0($sp)
			jal get_numbers
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			move $a0,$v0
			move $a1,$v1
			move $v0,$s1
			move $v1,$s2
			subi $sp,$sp,4
			sw $ra, 0($sp)
			jal intersection
			lw $ra,($sp)
			addi $sp,$sp,4
			bnez $v0, end_loop_traverse_string_add_slot
			loop_till_comma_add_slot :
				lb $t2, 0($s0) 
				addi $s0, $s0, 1
				beqz $t2, end_loop_traverse_string_add_slot
				beq $t2, ',', loop_traverse_string_add_slot
				j loop_till_comma_add_slot
				
			# restoring registers from the stack
			end_loop_traverse_string_add_slot : 
			lw $s1, 0($sp) 
			lw $s2, 4($sp)
			lw $s0, 8($sp) # store $ s0, s1, s2 as they are going to be used in this function
			lw $s3, 12($sp)
			addi $sp, $sp, 16
	
                     jr $ra
                     

#--------------------------------------------------------------------------------
                     
                 
                     
 #$a0 start time $a1 end time, string in $a2, $v1 to indicate whether this is a newly created string               
create_string_slot:

	li $t3, '-'
	li $t4, 10 # to divide by 10
	la $t1, buffer1
	li $t0, ','	#add a comma to the buffer
	beq $v1, 1, skip_colon_create_string_slot
		sb $t0, 0($t1)
		addi $t1, $t1, 1
	skip_colon_create_string_slot : 
	
	in_range ($a0, 0, 9)
	bnez $v0, digit_1 
		
		div $a0, $t4
		mflo $t2
		addi $t2, $t2, 48
		sb $t2, 0($t1)
		mfhi $t2
		addi $t2, $t2, 48
		sb $t2, 1($t1)
		addi $t1, $t1, 2
		j continue_create_string_slot
		
	digit_1: 
		addi $t2, $a0, 48
		sb $t2, 0($t1)
		addi $t1, $t1, 1
		
	continue_create_string_slot :
	
	 sb $t3, 0($t1) # add the dash to the string
	 addi $t1, $t1, 1
	
	in_range ($a1, 0, 9)
	bnez $v0, digit_1_2 
		
		div $a1, $t4
		mflo $t2
		addi $t2, $t2, 48
		sb $t2, 0($t1)
		mfhi $t2
		addi $t2, $t2, 48
		sb $t2, 1($t1)
		addi $t1, $t1, 2
		j continue_create_string_slot1
		
	digit_1_2 : 
		addi $t2, $a1, 48
		sb $t2, 0($t1)
		addi $t1, $t1, 1
		
	continue_create_string_slot1 :
	lb $t0, 0($a2)
	sb $t0, 0($t1) 
	lb $t0, 1($a2)
	sb $t0, 1($t1)
	lb $t0, 2($a2)
	sb $t0, 2($t1)
       
      jr $ra
      
      
#--------------------------------------------------------------
      
initialize_array_letters : 
	
	li $t0, 'O'
	li $t1, 'H'
	sb $t0, OH
	sb $t1, OH + 1
	la $t0, OH
	sw $t0, array_strings_letters + 4
	
	li $t0, 'L'
	sb $t0, L
	la $t0, L
	sw $t0, array_strings_letters
	
	li $t0, 'M'
	sb $t1, M
	la $t0, M
	sw $t0, array_strings_letters + 8
	jr $ra

#---------------------------------------------------------------------

#$a0-> address of the string which we want to delete the slot from
#$a1-> the start time in the slot
#$a2->the end time in the slot
# $a3 contains day num

Delete_slot_fun:


     subi $sp, $sp, 24
	sw $s1, 0($sp) 
	sw $s2, 4($sp)
	sw $s0, 8($sp) # store $ s0, s1, s2 as they are going to be used in this function
	sw $s3,12($sp)
	sw $s4,16($sp)
	sw $s5, 20($sp)
	move $s1, $a1
	move $s2, $a2
	
	loop_skip_colon_Delete_slot : # loop that makes $a0 point to the first character after the colon
	
		lb $t1, 0($a0)
		addi $a0, $a0, 1
		beq $t1, 58 end_loop_skip_colon_Delete_slot # exit loop if the character is a colon
		j loop_skip_colon_Delete_slot
		end_loop_skip_colon_Delete_slot : 
		
       	move $s0, $a0 # store the begining of the string because $a0 is going to be modified
       	move $s5, $a0 # store this point of the string 
       
	move $t1, $a0 # point to the begining of the number
	
	loop_traverse_string_Delete_slot : #keep traversing string untill null terminator is reached

	        lb $t2, 0($s0)
		beqz $t2, end_loop_not_found_number
		
		move $a0, $s0 # make $s0 point to the begining of the number
		loop_till_letter_Delete_slot : 
			lb $t3, 0($s0)
			sge $t1, $t3, 'A'
			sle $t2, $t3, 'Z'
			and $t2, $t2, $t1
			beq $t2, 1, continue_loop_get_number_Delete_slot # go to label if char in $t3 is between A and Z
				addi $s0, $s0, 1
				j loop_till_letter_Delete_slot
		continue_loop_get_number_Delete_slot :
	     		
			# preparing to call get_numbers 
			move $a1, $s0
			subi $sp, $sp, 8
			sw $ra, 0($sp)
			sw $a0, 4($sp) # save $a0 to get string length later
			jal get_numbers
			lw $ra, 0($sp)
			lw $a0, 4($sp)
			addi $sp, $sp, 8 # pop $ra and $a0
			
			
			loop_till_comma_Delete_slot : 
				lb $t2, 0($s0) 
				beqz $t2, Delete_number_check_slot
				addi $s0, $s0, 1 # make $s0 point to the number after the comma
				beq $t2, ',', Delete_number_check_slot
	            j loop_till_comma_Delete_slot
	           
	            # now we have the numbers in $v0 $v1
			# now check if those numbers are equal to the given one
			Delete_number_check_slot : 
	
			move $a1,$s0
			bne $v0, $s1, loop_traverse_string_Delete_slot	
			bne $v1, $s2, loop_traverse_string_Delete_slot
			sub $a2, $a1, $a0 # store length in $a2
			
	             
			shift_slot: 
                        
                         lb $s4,0($a1)
                          sub $s3,$a1,$a2
                         sb $s4,0($s3)
                         addi $a1,$a1,1
                         bnez $s4, shift_slot
        
        end_loop_traverse_string_Delete_slot:
        		
        		lb $t0, 0($s5)
        		bnez $t0, delete_day
        		sll $a3, $a3, 2
        		       sw $0, array_pointers + 0($a3)
        		delete_day : 
        		
     
                       lw $s1, 0($sp) 
			lw $s2, 4($sp)
			lw $s0, 8($sp) # retrieve the values from the stack	
			sw $s3,12($sp)
	                sw $s4,16($sp)
	                sw $s5, 20($sp)
			addi $sp, $sp, 24
			j end_Delete_slot
	
	end_loop_not_found_number : 
	li $v1, 0
	print_string(time_slot_not_found)
			
      end_Delete_slot : jr $ra

#------------------------------------------------------------------------------