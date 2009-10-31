require 'test_helper'
require 'parameter_estimation'


class ParameterEstimationTest < ActiveSupport::TestCase
  
  
  consistent_data = <<-EOS
0 0 1
1 0 1
0 1 0
0 0 1
     EOS
  
  inconsistent_data = <<-EOS
0 0 1
1 0 1
0 1 0
0 0 1
0 0 1
     EOS

  consistent_with_hash_data = <<-EOS
1 0 1
0 1 0
0 0 1
#
0 0 1
1 0 0
#
1 1 0
0 1 0
     EOS
  
  inconsistent_with_hash_data = <<-EOS
0 0 1
1 0 1
0 1 0
#
0 0 1
0 0 1
     EOS
  def setup
    @fake_job = FakeJob4PE.new(2, 3, "/tmp")
  end  

  test "generate function file with minsets" do 
    file_prefix = "/tmp/xxxwd"
		@fake_job.file_prefix = file_prefix
    Algorithm.job = @fake_job
    
    consistent_data_file = file_prefix + ".consistent.txt"
    create_file(consistent_data_file, consistent_data) 
    ParameterEstimation.run_minsets(consistent_data_file, "#{file_prefix}.minset.txt")
    assert File.exists?("#{file_prefix}.minset.txt")
    expected_data = [
"f1 = x1+x2+1",
"f2 = x1",
"f3 = x1+1"
    ]
    compare_content("#{file_prefix}.minset.txt", expected_data)

    inconsistent_data_file = file_prefix + ".inconsistent.txt"
    create_file( inconsistent_data_file, inconsistent_data) 
    assert_raise MacaulayError do 
      GenerateWiringDiagram.run_minsets(inconsistent_data_file, "#{file_prefix}.dummy.txt" )
    end
  end


end

class FakeJob4PE < Struct.new(:pvalue, :nodes, :file_prefix) 
end
