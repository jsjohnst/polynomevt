require 'interpolation_parser'
require 'parameter_estimation'
require 'tempfile'
require 'pp'

class FakeJobHack < Struct.new(:pvalue, :nodes, :file_prefix)
end


def run_gfan(truth_table)
	Algorithm.macaulay_path = "../../macaulay"
	Algorithm.job = FakeJobHack.new(3, truth_table['variables'].length, '/tmp')
	discretized_file = Tempfile.open('tmpfile')
	functionfile = Tempfile.open('tmpfile')
	discretized_file.write truth_table['timecourse_data']
	discretized_file.flush
	ParameterEstimation.run_gfan(discretized_file.path, functionfile.path)
	functionfile.read
end

variable_mapping = "LabileIron\nHO1\nHO1\nALAS1\nTfR1\nFt\nDMT1\nFpn\nROS\nHeme\nIRP\nJAK2\nHepc\nHP\nXFe".split(/\s+/)
#variable_mapping = "GeneA\nGeneB\nGeneC".split(/\s+/)

ip = InterpolationParser.new("./functions_without_first_sheet.xls", variable_mapping)
ip.parse_excel

ip.each do |truth_table|
	truth_table['function_data'] = run_gfan(truth_table)
	pp truth_table
end

fdata = ip.generate_function_list

pp variable_mapping
puts fdata
