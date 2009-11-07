require 'interpolation_parser'
require 'pp'

ip = InterpolationParser.new("../../designdocs/test-truthtable.xls")
ip.parse

ip.each do |truth_table|
	pp truth_table
end
