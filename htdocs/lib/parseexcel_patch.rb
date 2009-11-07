require 'rubygems'
require 'parseexcel'

# parseexcel narrow sightedly doesn't make worksheets iterable
# so we do it add that capability ourselves to the class
module Spreadsheet
	module ParseExcel
		class Workbook
			include Enumerable
			def each(skip=0, &block)
				@worksheets[skip..-1].each(&block)
			end
			def each_with_index(skip=0, &block)
				@worksheets[skip..-1].each_with_index(&block)
			end
		end
		class Worksheet
			def each_with_index(skip=0, &block)
				@cells[skip..-1].each_with_index(&block)
			end
		end
	end
end

