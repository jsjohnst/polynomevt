
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
    assert File.exists?("#{file_prefix}.minset_wd.dot")
    expected_data = [
      "digraph { ",
      "{x1; x2} -> x1;",
      "{x1} -> x2;",
      "{x1} -> x3;",
      "}"
    ]
    compare_content("#{file_prefix}.minset_wd.dot", expected_data)

    inconsistent_data_file = file_prefix + ".inconsistent.txt"
    create_file( inconsistent_data_file, inconsistent_data) 
    assert_raise MacaulayError do 
      GenerateWiringDiagram.run_minsets(inconsistent_data_file, "#{file_prefix}.dummy_dw.dot" )
    end
  end

  test "generate wd with gfan" do 
    file_prefix = "/tmp/xxxwd"
		@fake_job.file_prefix = file_prefix
    Algorithm.job = @fake_job
    
    consistent_data_file = file_prefix + ".consistent.txt"
    create_file(consistent_data_file, consistent_data) 
    GenerateWiringDiagram.run_gfan(consistent_data_file, "#{file_prefix}.gfan_wd.dot")
    assert File.exists?("#{file_prefix}.gfan_wd.dot")
#    expected_data = [
#      "digraph {",
#      "x1 [shape=\"box\"];",
#      "x2 [shape=\"box\"];",
#      "x3 [shape=\"box\"];",
#      "x1->x1 [label=\"1\"];",
#      "x2->x1 [label=\".466667\"];",
#      "x3->x1 [label=\".533333\"];",
#      "x1->x2 [label=\"1\"];",
#      "x1->x3 [label=\"1\"];",
#    ]
#    compare_content("#{file_prefix}.gfan_wd.dot", expected_data)

    inconsistent_data_file = file_prefix + ".inconsistent.txt"
    create_file( inconsistent_data_file, inconsistent_data) 
    assert_raise MacaulayError do 
      GenerateWiringDiagram.run_gfan(inconsistent_data_file, "#{file_prefix}.dummy_wd.dot" )
    end
  end

end

class FakeJob < Struct.new(:pvalue, :nodes, :file_prefix) 
end
