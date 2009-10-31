
require 'test_helper'
require 'generate_wiring_diagram'


class GenerateWdTest < ActiveSupport::TestCase
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
    @fake_job = FakeJob.new(2, 3, "/tmp")
  end  

  test "generate wd with minsets" do 
    file_prefix = "/tmp/xxxwd"
		@fake_job.file_prefix = file_prefix
    Algorithm.job = @fake_job
    
    consistent_data_file = file_prefix + ".consistent.txt"
    create_file(consistent_data_file, consistent_data) 
    GenerateWiringDiagram.run_minsets(consistent_data_file, "#{file_prefix}.minset_wd.dot")
    inconsistent_data_file = file_prefix + ".inconsistent.txt"
    create_file( inconsistent_data_file, inconsistent_data) 
    assert_raise MacaulayError do 
      GenerateWiringDiagram.run_minsets(inconsistent_data_file, "#{file_prefix}.minset_wd.dot" )
    end
  end

  test "generate wd with gfan" do 
    #wd.me
  end

  test "generate wd with react" do 
  end
end

class FakeJob < Struct.new(:pvalue, :nodes, :file_prefix) 
end
