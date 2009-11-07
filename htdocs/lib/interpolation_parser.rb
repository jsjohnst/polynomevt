require 'parseexcel_patch'

# Class which takes an excel spreadsheet as input, then
# parses it and generates timecourses from the truth
# tables inside it

class InterpolationParser < Struct.new(:filename, :variable_map)
	include Enumerable

	# allows us to do an ip.each to iterate over the truth tables	
	def each(&block)
		@truth_tables.each(&block)
	end

	attr_accessor :truth_tables

	def parse_excel
		@truth_tables = []

		# open the excel spreadsheet and parse it
		workbook = Spreadsheet::ParseExcel.parse(filename)

		# loop over all the sheets in this workbook
		workbook.each_with_index do |worksheet, sheet_index|
			truth_table = Hash.new
			truth_table['variables'] = []
			truth_table['variable_to_calculate'] = worksheet.row(0).at(0).to_s('latin1')
			truth_table['timecourse_data'] = "" 
			
			# A,0 in the sheet must be our variable_to_calculate
			if truth_table['variable_to_calculate'] == ""
				raise RuntimeException.new("Invalid sheet format for sheet # #{sheet_index}: variable_to_calculate not found")
			end

			found_headers = false
			computed_cell_index = -1
			data = []

			# loop over all the rows
			worksheet.each_with_index(1) do |row,row_index|
				# check if the row is not empty
				if row != nil
					data_row = []
					
					# loop over all the cells
					row.each_with_index do |cell,cell_index|
						if cell != nil
							content = cell.to_s('latin1')
				
							# if we haven't found the header row yet, do so now
							if !found_headers
								if content == (truth_table['variable_to_calculate'] + " (t+1)")
									# store away the calculated variable index for later
									computed_cell_index = cell_index
								else
									# the variables in our truth table don't include the calculated cell
									# the order should be the same as the discretized input so that after
									# running gfan, x1 == truth_table['variables'][0]
									truth_table['variables'].push content
								end
							else
								# just normal truth table data
								data_row.push content
							end
						end
					end

					# first non-empty row has to be the variables, so if we didn't find a computed_cell_index,
					# we know this data isn't properly formatted					
					if computed_cell_index == -1
						raise RuntimeException.new("Invalid sheet format for sheet # #{sheet_index}: variable_to_calculate not found in table")
					end

					found_headers = true

					# if this was a non-header row, save the row for later
					data.push data_row unless data_row.empty?
				end
			end

			data.each_with_index do |row,index|
				computed_cell_value = -1

				# add a comment to the data saying which timecourse we are on, 1 based
				truth_table['timecourse_data'] += "#TS#{index+1}\n"

				# build up the first row of the discretized data for this timecourse
				line = ""
				row.each_with_index do |cell,cell_index|
					if cell_index == computed_cell_index
						computed_cell_value = cell.to_i
					else
						line += "#{cell.to_i} "
					end
				end

				# if we somehow don't find the value for the variable_to_calculate field
				# our data is invalid, so throw an exception (this should only happen if some
				# columns are erroneously blank)
				if computed_cell_value == -1
					raise RuntimeException.new("Unable to find value for variable_to_calculate")
				end

				# first line of the timecourse is the data from the truth table
				# the second line is the variable_to_calculate's value in the first column
				truth_table['timecourse_data'] += "#{line.strip}\n"
				truth_table['timecourse_data'] += "#{computed_cell_value}"

				# and then we zero fill the rest of the line
				zero_fill = ""
				1.upto(row.length-2) { zero_fill += " 0" } # -2 because we are removing the calculated value's column + adding it in the row
				truth_table['timecourse_data'] += "#{zero_fill}\n"
			end

			# last line of the timecourse data is a comment with the variables in order
			truth_table['timecourse_data'] += "# #{truth_table['variables'].join(", ")}"
			
			# we've got a good truth table now, so store it!
			@truth_tables.push truth_table	
		end
	end
	
	def generate_function_list
		function_data = []
		@truth_tables.each do |truth_table|
			if truth_table['function_data'].nil?
				raise RuntimeException.new("Please run gfan on the parsed timecourses before attempting to build a function list")
			end
			fdata = truth_table['function_data'].split("\n").first
			truth_table['variables'].each_with_index do |variable,index|
				fdata.gsub!(/x#{index+1}/, "x#{get_variable_map_index(variable)}")
			end
			function_data.push fdata.gsub(/f1/, "f#{get_vtc_map_index(truth_table)}")
		end
		function_data.join("\n")
	end

	def get_variable_map_index(val)
		variable_map.index(val)
	end

	def get_vtc_map_index(truth_table)
		get_variable_map_index(truth_table['variable_to_calculate'])
	end
end
