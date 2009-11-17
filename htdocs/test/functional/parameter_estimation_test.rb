require 'test_helper'
require 'parameter_estimation'


class ParameterEstimationTest < ActiveSupport::TestCase
  
  
  consistent_data = <<-EOS
0 0 1
1 0 1
0 1 0
0 0 1
     EOS
  
  consistent_data_3 = <<-EOS
# another
0 0 
0 0 
#
0 1 
0 0 
#
0 2 
0 0 
#
1 0 
0 0 
#
1 1 
1 0 
#
1 2 
2 0 
#
2 0 
0 0 
#
2 1 
2 0 
#
2 2 
1 0 
#
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
#
1 1 1
0 1 1
0 0 0
0 0 0
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
    @another_fake_job = FakeJob4PE.new(5, 3, "/tmp")

    # this one has 2 variables but pvalue 3
    @fake_job_pvalue_3= FakeJob4PE.new(3, 2, "/tmp")
  end  

  test "generate function file with minsets" do 
    file_prefix = "/tmp/xxxff"
		@fake_job.file_prefix = file_prefix
    Algorithm.job = @fake_job
    
    # checked by hand and is correct
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
	
    # another test with pvalue = 5
    file_prefix = "/tmp/xxxff5"
    @another_fake_job.file_prefix = file_prefix
    Algorithm.job = @another_fake_job
    
    # checked by hand and is correct
    consistent_data_file = file_prefix + ".consistent.txt"
    create_file(consistent_data_file, consistent_data) 
    ParameterEstimation.run_minsets(consistent_data_file, "#{file_prefix}.minset.txt")
    assert File.exists?("#{file_prefix}.minset.txt")
  end

  test "generate function file with minsets witih hash symbols" do 
    file_prefix = "/tmp/xxxff2"
		@fake_job.file_prefix = file_prefix
    Algorithm.job = @fake_job
    
    # checked by hand and is correct
    consistent_data_file = file_prefix + ".consistentwith_hash.txt"
    create_file(consistent_data_file, consistent_with_hash_data) 
    ParameterEstimation.run_minsets(consistent_data_file, "#{file_prefix}.minsetwith_hash.txt")
    assert File.exists?("#{file_prefix}.minsetwith_hash.txt")
    expected_data = [
"f1 = x1*x2+x2*x3+x1+x3",
"f2 = x1",
"f3 = x1*x2+x2*x3+x2"
    ]
    compare_content("#{file_prefix}.minsetwith_hash.txt", expected_data)
  end

  test "generate function file with gfan" do 
    file_prefix = "/tmp/xxxff"
		@fake_job.file_prefix = file_prefix
    Algorithm.job = @fake_job
    
    # checked by hand and is correct
    consistent_data_file = file_prefix + ".consistent.txt"
    create_file(consistent_data_file, consistent_data) 
    ParameterEstimation.run_gfan(consistent_data_file, "#{file_prefix}.gfan.txt")
    assert File.exists?("#{file_prefix}.gfan.txt")
#    expected_data = [
#"f1 = x1+x2+1",
#"f2 = x1",
#"f3 = x1+1"
#    ]
#    compare_content("#{file_prefix}.gfan.txt", expected_data)

    inconsistent_data_file = file_prefix + ".inconsistent.txt"
    create_file( inconsistent_data_file, inconsistent_data) 
    assert_raise MacaulayError do 
      GenerateWiringDiagram.run_gfan(inconsistent_data_file, "#{file_prefix}.dummy.txt" )
    end
  end
  
  test "generate function file with gfan where pvalue is 3" do 
    file_prefix = "/tmp/xxxpvalue3"
		@fake_job_pvalue_3.file_prefix = file_prefix
    Algorithm.job = @fake_job_pvalue_3
    
    # checked by hand and is correct
    consistent_data_file = file_prefix + ".consistent.txt"
    create_file(consistent_data_file, consistent_data_3) 
    ParameterEstimation.run_gfan(consistent_data_file, "#{file_prefix}.gfan.txt")
    assert File.exists?("#{file_prefix}.gfan.txt")
    expected_data = [
"f1 = x1*x2",
"f2 = 0",
    ]
    compare_content("#{file_prefix}.gfan.txt", expected_data)

  end


  test "generate function file with gfan with hash symbols" do 
    file_prefix = "/tmp/xxxff2"
		@fake_job.file_prefix = file_prefix
    Algorithm.job = @fake_job
    
    # checked by hand and is correct
    consistent_data_file = file_prefix + ".consistentwith_hash.txt"
    create_file(consistent_data_file, consistent_with_hash_data) 
    ParameterEstimation.run_gfan(consistent_data_file, "#{file_prefix}.gfanwith_hash.txt")
    assert File.exists?("#{file_prefix}.gfanwith_hash.txt")
#    expected_data = [
#"f1 = x1*x2+x2*x3+x1+x3",
#"f2 = x1",
#"f3 = x1*x2+x2*x3+x2"
#    ]
#    compare_content("#{file_prefix}.gfanwith_hash.txt", expected_data)
  end


end

class FakeJob4PE < Struct.new(:pvalue, :nodes, :file_prefix) 
end
