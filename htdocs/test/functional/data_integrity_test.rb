require 'test_helper'
require 'data_integrity'


class DataIntegrityTest < ActiveSupport::TestCase
  
  
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
0 0 1
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

  def create_file( absolute_path, content )
    File.open(absolute_path, "w") do |f|
      f.write(content)
    end
  end
  
  def compare_content(file_name, expected_data)
    # check that the file has at least as many lines as the dummy data, so
    # that we don't generate empty graphs anymore
    number_of_lines = `wc -l < #{file_name}`
    assert expected_data.length <= number_of_lines.to_i, "data should have at least #{expected_data.length} lines, but only has #{number_of_lines}"
    my_file = File.open( file_name, "r")
    expected_data.each_with_index do |data, line|
      file_data = my_file.gets
      file_data = file_data.chop
      assert file_data.include?( data ), "#{data} is not included in #{file_data}, line #{line}"
    end
  end

  test "basic consistent test" do
    file_prefix = "/tmp/xxxcons"
    Macaulay.pvalue = 3
    Macaulay.nodes = 3
    
    consistent_data_file = file_prefix + ".consistent.txt"
    create_file( consistent_data_file, consistent_data)
    assert DataIntegrity.consistent?(consistent_data_file)
    
    inconsistent_data_file = file_prefix + ".inconsistent.txt"
    create_file( inconsistent_data_file, inconsistent_data)
    assert !DataIntegrity.consistent?(inconsistent_data_file)
  end

  test "consistent test with hash" do
    file_prefix = "/tmp/xxxconshash"
    Macaulay.pvalue = 3
    Macaulay.nodes = 3
    
    consistent_with_hash_data_file = file_prefix + ".consistent_with_hash.txt"
    create_file( consistent_with_hash_data_file, consistent_with_hash_data)
    assert DataIntegrity.consistent?(consistent_with_hash_data_file)
    
    inconsistent_with_hash_data_file = file_prefix + ".inconsistent_with_hash.txt"
    create_file( inconsistent_with_hash_data_file, inconsistent_with_hash_data)
    assert !DataIntegrity.consistent?(inconsistent_with_hash_data)
  end
  
  test "basic make consistent test" do
    file_prefix = "/tmp/xxxcons"
    Macaulay.pvalue = 2 
    Macaulay.nodes = 3
    
    inconsistent_data_file = file_prefix + ".inconsistent.txt"
    create_file( inconsistent_data_file, inconsistent_data)
    assert !DataIntegrity.consistent?(inconsistent_data_file)
    new_consistent_data_file = file_prefix + ".new_consistent.txt"
    DataIntegrity.makeConsistent(inconsistent_data, new_consistent_data_file )
    expected_data = [
"0 0 1",
"1 0 1",
"0 1 0",
"0 0 1",
"#",
"0 0 1"
    ]
    compare_content(new_consistent_data_file, expected_data)

  end

end
