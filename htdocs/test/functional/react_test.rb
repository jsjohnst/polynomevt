require 'test_helper'
require 'react'

class ReactTest < ActiveSupport::TestCase
  
  
  deterministic_function_file = <<-EOS
f1 = x1+x2
f2 = x1*x2*x3
f3 = x1*x2+x3^2
      EOS

  discretized_data_file = <<-EOS
0 0 1
1 0 1
0 1 0
0 0 1
     EOS

  def create_file( absolute_path, content )
    File.open(absolute_path, "w") do |f|
      f.write(content)
    end
  end

  test "basic react test" do
    file_prefix = "/tmp/xxxw"
    create_file( "#{file_prefix}.discretized.txt", discretized_data_file)
    react = React.new(file_prefix, 3)
    react.discretized_data_file = "#{file_prefix}.discretized.txt"
    assert react.run
    assert FileTest.exists?( "#{file_prefix}.model.txt" ), "modelfile missing"
    assert FileTest.exists?( "#{file_prefix}.functionfile.txt" ), "functionfile missing"
    assert FileTest.exists?( "#{file_prefix}.multiplefunctionfile.txt" ), "multiplefunctionfile missing"
  end

  test "assert react fails if file cannot be written" do 
    file_prefix = "/tmp/xxxnot"
    create_file( "#{file_prefix}.discretized.txt", discretized_data_file)
    react = React.new(file_prefix, 3)
    react.discretized_data_file = "#{file_prefix}.discretized.txt"
    FileUtils.touch( "#{file_prefix}.model.txt")
    File.chmod( 0222, "#{file_prefix}.model.txt")
    assert_raise Errno::EACCES do
      react.run
    end
    File.chmod( 0644, "#{file_prefix}.model.txt")
   
    File.chmod( 0000, "#{file_prefix}.model.txt")
    assert_raise Errno::EACCES do 
      react.run
    end
    File.chmod( 0644, "#{file_prefix}.model.txt")
   
    File.chmod( 0000, "#{file_prefix}.fileman.txt")
    assert_raise Errno::EACCES do 
      react.run
    end
    File.chmod( 0644, "#{file_prefix}.fileman.txt")
   
  end


end
