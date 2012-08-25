class InputQFromOutside
    def initialize
		@user_input =  Array.new  #level, direction
		@input_queue = Array.new([@user_input])
		#@input_queue = Array.new
    end
	
	def set_user_input (lev,dir)
		@user_input.push(lev,dir)
		#@input_queue.push(lev,dir)	
	end
	
	def get_user_input ()	
		lev = @user_input.shift
		dir = @user_input.shift
		return lev,dir
	end
	
	def displayout
		for index in 0 ... @user_input.length
		puts "#{@user_input[index].inspect}"
		end
	end	
	
end

class Elevator
    def initialize
        @service_cnt = 0
		@level = Array.new(4,0)					#contains level for current status, SR1, SR2, SR3
        @direction = Array.new(4,0)				#contains direction for current status, SR1, SR2, SR3
		@user_destination = Array.new(29,0)		#user input information for	
    end
	
	def set_value(array_id,index,value)			#1 for level and 2 for direction
		case array_id
			when 1
				@level[index] = value
			when 2
				@direction[index] = value
			else
				puts "wrong array identified"
		end	
	end
	
	def add_sr_to_elev(lev,dir)
		for index in 1 ... 3
			if @direction[index]==0
				@direction[index]= dir
				@level[index] = lev
				@service_cnt = @service_cnt+1 
				break
			else	
				next
			end
		end
		if dir == 2 #down
			@direction.sort!{|x,y| y<=>x}
			@level.sort!{|x,y| y<=>x}
		else
			@direction.sort!
			@level.sort!
		end
	end
	
	def set_user_destination(index,value)
		@user_destination[index] = value
	end

	def get_user_destination
		if (dir == 2) #down
			for index in 29 ... 0
				if @user_destination[index] then return index end
			end
		elsif (dir == 1) #up 
			for index in 0 ... 29
				if @user_destination[index] then return index end
			end		
		else
			puts "System failure"
		end	
		if !@user_destination[index] then return -1 end
	end

	def get_service_cnt
		return @service_cnt
	end
	def get_level(i)
		return @level[i]
	end
	def get_dir i
		return @direction[i]
	end
	def dispatch_pending_elv
		# if there is a service request, dispatch it
		if (@serivce_cntr)
		puts "dispatch"
			for index in 1 ... 3
				if @direction[index]!=0
					@level[0] = @level[index]
					@direction[0] = @direction[index]
					#invoke low level function to dispatch elevator eg : dispatch_elv (@level[0],@direction[0])
					#if status is success, clear the corresponding service request
					@level[index] = @direction[index] = 0
					@serivce_cntr= @serivce_cntr-1 
				else	
					break
				end
			end	
		end
	end
end

$elevators = [Elevator.new, Elevator.new, Elevator.new]
$ext_input = InputQFromOutside.new	


def find_closest_elv lev	
	closest_elevator = 1
	
 	for index in 1 ... $elevators.length
		elev_lev = $elevators[index].get_level 0
		diff = (elev_lev-lev).abs
		lev_current_closest = $elevators[closest_elevator].get_level 0
		lev_current_closest = lev_current_closest - lev
		if diff < lev_current_closest.abs
			close_elevator = index
		end
	end
	return closest_elevator
end 

#finds the closest elevator for the 'lev' passed and sets it	
def find_close_elv_and_setlevel(lev)
closest_elevator = find_closest_elv(lev) #compute closest elevator. should i pass closest_elevator or closest_elevator+1 ?? 
$elevators[closest_elevator].set_value(1,0,lev)
end

def decision_algo(lev,dir)
	for index in 0 ... $elevators.length
		closest_elevator = find_closest_elv lev 
		case $elevators[closest_elevator].get_service_cnt
			when  1.. 2	
				#Check if the directions of SR is matching
				elev_dir = $elevators[closest_elevator].get_dir 1
				elev_curr_lev = $elevators[closest_elevator].get_level 0
				if (elev_dir == dir )
					#check the direction
					case dir
						when 1 #Up
							highest_lev = $elevators[closest_elevator].get_level 3
							if elev_curr_lev  < lev &&  highest_lev >= dir
							#add this request service to this lift 
							$elevators[closest_elevator].add_sr_to_elev(lev,dir)
							end	
						when 2 #Down
							lowest_lev = $elevators[closest_elevator].get_level 1
							if elev_curr_lev > lev && lowest_lev <= dir
								#add this request service to this lift
								$elevators[closest_elevator].add_sr_to_elev(lev,dir)
							end
						else
							puts "System Fialure"
					end		
				else
					# Direction is opposite,Find next closest elevator
					break
				end
			when  0	
				#add this request service to this lift
				#this will be SR1 
				$elevators[closest_elevator].add_sr_to_elev(lev,dir)
			when 3
				#SR queue full. find next closest elevator
				next
			else
				puts "System Fialure"
		end
		
	end
		
end

#set idle levels for the elevator default position and dispatched them properly
def set_elevator_idle_levels
	
	time1 = Time.new
	case time1.hour 
	when (7..9) 
		find_close_elv_and_setlevel 5
		find_close_elv_and_setlevel 16
		find_close_elv_and_setlevel 26		
	when (17..20) 
		find_close_elv_and_setlevel 0
		find_close_elv_and_setlevel 10
		find_close_elv_and_setlevel 20		
	else
		find_close_elv_and_setlevel 0
		find_close_elv_and_setlevel 14
		find_close_elv_and_setlevel 23		
	end		
end

#Main thread

#user input from outside the elevator
$ext_input.set_user_input(28,1) #dummy value lev 28, dir Down 
$ext_input.set_user_input(23,2) #dummy value lev 23, dir Down 
$ext_input.set_user_input(27,2) #dummy value lev 27, dir Down 
$ext_input.set_user_input(21,2) #dummy value lev 21, dir Down 
$ext_input.set_user_input(20,2) #dummy value lev 20, dir Down 

sleep_flag = TRUE
timer_expiry = FALSE
while 1
	
	sleep_flag ? timer_expiry = FALSE : set_elevator_idle_levels
	#extract the user input 
	level , direction = $ext_input.get_user_input
	break if direction == nil
	#make the decision
	#dir - 1 is Up and 2 is Down
	decision_algo(level ,direction)	
	#dispatch the elevators to address the SR		
	$elevators[0].dispatch_pending_elv  
	$elevators[1].dispatch_pending_elv  
	$elevators[2].dispatch_pending_elv  
	
	sleep_flag = TRUE
	#invoke sleep for X minutes here and set the timer_expiry flag accordingly
	timer_expiry ? sleep_flag = FALSE :  sleep_flag = TRUE
end

#Create new thread to receive user inputs from inside the elevators, once passenger is on board
#this thread should run whenever the input is key-ed in by the passenger
input_recv = Thread.new do
	def user_internal_input_recv
		#receive user input from low level function, for selected elevator
		user_input, elevator_id = 0
		case user_input 
			when 0 .. 29
				$elevators[elevator_id].set_user_destination(user_input, TRUE)
			else
				puts "System failure"
		end		
	end
end

#Create new thread to process user inputs parallely
#this thread should run whenever an elevator is in dispatch state
input_proc = Thread.new do
	def user_internal_input_proc
		#receive user input from low level function, for selected elevator
		for index in 0 ... 2
			level = $elevators[index].get_user_destination
			#if level is valid(0-29), trigger function to set door to open at the level
			#set_door_to_open(level)
			#clear the user_destination values
			$elevators[index].set_user_destination(level, FALSE)
		end			
	end
end
