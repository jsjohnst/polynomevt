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
#  
0 0 1
1 0 1
0 1 0
#
0 0 1
1 1 1
1 0 1
0 1 0
0 0 1
     EOS

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
    assert !DataIntegrity.consistent?(inconsistent_with_hash_data_file)
  end
  
  test "basic make consistent test" do
    file_prefix = "/tmp/xxxcons"
    Macaulay.pvalue = 2 
    Macaulay.nodes = 3
    
    inconsistent_data_file = file_prefix + ".inconsistent.txt"
    create_file( inconsistent_data_file, inconsistent_data)
    assert !DataIntegrity.consistent?(inconsistent_data_file)
    new_consistent_data_file = file_prefix + ".new_consistent.txt"
    DataIntegrity.makeConsistent(inconsistent_data_file, new_consistent_data_file )
    expected_data = [
"#TS1",
"0 1 0",
"0 0 1",
"#TS2",
"1 0 1",
"0 1 0"
    ]
    compare_content(new_consistent_data_file, expected_data)
  end
  
  test "basic make consistent with hash symbols test" do
    file_prefix = "/tmp/xxxcons"
    Macaulay.pvalue = 2 
    Macaulay.nodes = 3
    
    inconsistent_with_hash_data_file = file_prefix + ".inconsistent_with_hash.txt"
    create_file( inconsistent_with_hash_data_file, inconsistent_with_hash_data)
    assert !DataIntegrity.consistent?(inconsistent_with_hash_data_file)
    new_consistent_with_hash_data_file = file_prefix + ".new_consistent_with_hash.txt"
    DataIntegrity.makeConsistent(inconsistent_with_hash_data_file, new_consistent_with_hash_data_file )
    expected_data = [
"#TS1",
"1 1 1 ",
"1 0 1 ",
"#TS2",
"0 1 0 ",
"0 0 1 ",
"#TS3",
"1 0 1 ",
"0 1 0 "
    ]
    compare_content(new_consistent_with_hash_data_file, expected_data)
  end

end
