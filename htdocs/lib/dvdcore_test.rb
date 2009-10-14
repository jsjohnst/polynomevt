require 'test_helper'
require 'dvdcore'

class DvdcoreTest < ActiveSupport::TestCase
  test "dummy" do 
    assert true
  end

  deterministic_function_file = <<-EOS
f1 = x1+x2
f2 = x1*x2*x3
f3 = x1*x2+x3^2
      EOS

  deterministic_wiring_diagram = <<-EOS
digraph test {
node1 -> node1;
node1 -> node2;
node1 -> node3;
node1 [label="x1", shape="box"];
node2 -> node1;
node2 -> node2;
node2 -> node3;
node2 [label="x2", shape="box"];
node3 -> node2;
node3 -> node3;
node3 [label="x3", shape="box"];
}
    EOS

  deterministic_state_space = <<-EOS
digraph test {
node0 [label=" 0 0 0"];
node1 [label=" 0 0 1"];
node2 [label=" 0 1 0"];
node3 [label=" 0 1 1"];
node4 [label=" 1 0 0"];
node5 [label=" 1 0 1"];
node6 [label=" 1 1 0"];
node7 [label=" 1 1 1"];
node0 -> node0; 
node1 -> node1;
node2 -> node4;
node3 -> node5;
node4 -> node4;
node5 -> node5;
node6 -> node1;
node7 -> node2;
}
    EOS

  deterministic_state_space_with_probabilities = <<-EOS
digraph test {
node0 [label=" 0 0 0"];
node1 [label=" 0 0 1"];
node2 [label=" 0 1 0"];
node3 [label=" 0 1 1"];
node4 [label=" 1 0 0"];
node5 [label=" 1 0 1"];
node6 [label=" 1 1 0"];
node7 [label=" 1 1 1"];
node0 -> node0 [label= "1.00"];
node1 -> node1 [label= "1.00"];
node2 -> node4 [label= "1.00"];
node3 -> node5 [label= "1.00"];
node4 -> node4 [label= "1.00"];
node5 -> node5 [label= "1.00"];
node6 -> node1 [label= "1.00"];
node7 -> node2 [label= "1.00"];
}
    EOS

  stochastic_function_file = <<-EOS
f1 = {
x1+x2   #.9
x1      #.1
}
f2 = x1*x2*x3
f3 = {
x1*x2+x3^2
x2
}
    EOS

  stochastic_wiring_diagram= <<-EOS
digraph test {
node1 -> node1;
node1 -> node2;
node1 -> node3;
node1 [label="x1", shape="box"];
node2 -> node1;
node2 -> node2;
node2 -> node3;
node2 [label="x2", shape="box"];
node3 -> node2;
node3 -> node3;
node3 [label="x3", shape="box"];
}
  EOS

  stochastic_state_space = <<-EOS
digraph test {
node0 [label=" 0 0 0"];
node1 [label=" 0 0 1"];
node2 [label=" 0 1 0"];
node3 [label=" 0 1 1"];
node4 [label=" 1 0 0"];
node5 [label=" 1 0 1"];
node6 [label=" 1 1 0"];
node7 [label=" 1 1 1"];
node0 -> node0;
node1 -> node0;
node1 -> node1;
node2 -> node0;
node2 -> node1;
node2 -> node4;
node2 -> node5;
node3 -> node1;
node3 -> node5;
node4 -> node4;
node5 -> node4;
node5 -> node5;
node6 -> node1;
node6 -> node5;
node7 -> node2;
node7 -> node3;
node7 -> node6;
node7 -> node7;
}
  EOS

stochastic_state_space_with_probabilities = <<-EOS
digraph test {
node0 [label=" 0 0 0"];
node1 [label=" 0 0 1"];
node2 [label=" 0 1 0"];
node3 [label=" 0 1 1"];
node4 [label=" 1 0 0"];
node5 [label=" 1 0 1"];
node6 [label=" 1 1 0"];
node7 [label=" 1 1 1"];
node0 -> node0 [label= "1.00"];
node1 -> node0 [label= "0.50"];
node1 -> node1 [label= "0.50"];
node2 -> node0 [label= "0.05"];
node2 -> node1 [label= "0.05"];
node2 -> node4 [label= "0.45"];
node2 -> node5 [label= "0.45"];
node3 -> node1 [label= "0.10"];
node3 -> node5 [label= "0.90"];
node4 -> node4 [label= "1.00"];
node5 -> node4 [label= "0.50"];
node5 -> node5 [label= "0.50"];
node6 -> node1 [label= "0.90"];
node6 -> node5 [label= "0.10"];
node7 -> node2 [label= "0.45"];
node7 -> node3 [label= "0.45"];
node7 -> node6 [label= "0.05"];
node7 -> node7 [label= "0.05"];
}
  EOS

  def create_file( absolute_path, content )
    File.open(absolute_path, "w") do |f|
      f.write(content)
    end
  end

  test "creates wiring diagram" do
    file_prefix = "/tmp/xxxw"
    create_file( "#{file_prefix}.functionfile.txt", deterministic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.run
    assert FileTest.exists?( "#{file_prefix}.wiring_diagram.dot" )
  end

  test "creates state space" do
    file_prefix = "/tmp/xxxs"
    create_file( "#{file_prefix}.functionfile.txt", deterministic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.run
    assert FileTest.exists?( "#{file_prefix}.state_space.dot" )
  end

  test "check deterministic wiring diagram" do 
    file_prefix = "/tmp/xxxw1"
    create_file( "#{file_prefix}.functionfile.txt", deterministic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.run
    assert FileTest.exists?( "#{file_prefix}.wiring_diagram.dot" )
    assert_equal deterministic_wiring_diagram, File.read( "#{file_prefix}.wiring_diagram.dot" ), "Wiring diagram not as expected"
  end

  test "check stochastic wiring diagram" do 
    file_prefix = "/tmp/xxxs1"
    create_file( "#{file_prefix}.functionfile.txt", stochastic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.run
    assert FileTest.exists?( "#{file_prefix}.wiring_diagram.dot" )
    assert_equal stochastic_wiring_diagram, File.read( "#{file_prefix}.wiring_diagram.dot" ), "Wiring diagram not as expected"
  end

  test "check deterministic state space" do 
    file_prefix = "/tmp/xxxs2"
    create_file( "#{file_prefix}.functionfile.txt", deterministic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.run
    assert FileTest.exists?( "#{file_prefix}.state_space.dot" )
    assert_equal deterministic_state_space, File.read( "#{file_prefix}.state_space.dot" ), "State space not as expected"
  end

  test "check stochastic state space" do 
    file_prefix = "/tmp/xxxs3"
    create_file( "#{file_prefix}.functionfile.txt", stochastic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.run
    assert FileTest.exists?( "#{file_prefix}.state_space.dot" )
    assert_equal stochastic_state_space, File.read( "#{file_prefix}.state_space.dot" ), "State space not as expected"
  end


end
