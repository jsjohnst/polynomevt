require 'test_helper'
require 'dvdcore'

class DvdcoreTest < ActiveSupport::TestCase
  
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
node0 [label="000"];
node1 [label="001"];
node2 [label="010"];
node3 [label="011"];
node4 [label="100"];
node5 [label="101"];
node6 [label="110"];
node7 [label="111"];
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
node0 [label="000"];
node1 [label="001"];
node2 [label="010"];
node3 [label="011"];
node4 [label="100"];
node5 [label="101"];
node6 [label="110"];
node7 [label="111"];
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
node0 [label="000"];
node1 [label="001"];
node2 [label="010"];
node3 [label="011"];
node4 [label="100"];
node5 [label="101"];
node6 [label="110"];
node7 [label="111"];
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
node0 [label="000"];
node1 [label="001"];
node2 [label="010"];
node3 [label="011"];
node4 [label="100"];
node5 [label="101"];
node6 [label="110"];
node7 [label="111"];
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

stochastic_state_space_threshold_0_5_with_probabilities = <<-EOS
digraph test {
node0 [label="000"];
node1 [label="001"];
node2 [label="010"];
node3 [label="011"];
node4 [label="100"];
node5 [label="101"];
node6 [label="110"];
node7 [label="111"];
node0 -> node0 [label= "1.00"];
node1 -> node0 [label= "0.50"];
node1 -> node1 [label= "0.50"];
node3 -> node5 [label= "0.90"];
node4 -> node4 [label= "1.00"];
node5 -> node4 [label= "0.50"];
node5 -> node5 [label= "0.50"];
node6 -> node1 [label= "0.90"];
}
  EOS

stochastic_state_space_threshold_0_5 = <<-EOS
digraph test {
node0 [label="000"];
node1 [label="001"];
node2 [label="010"];
node3 [label="011"];
node4 [label="100"];
node5 [label="101"];
node6 [label="110"];
node7 [label="111"];
node0 -> node0;
node1 -> node0;
node1 -> node1;
node3 -> node5;
node4 -> node4;
node5 -> node4;
node5 -> node5;
node6 -> node1;
}
  EOS


  test "creates wiring diagram" do
    file_prefix = "/tmp/xxxw"
    create_file( "#{file_prefix}.functionfile.txt", deterministic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.create_wiring_diagram = true
    dvd.run #false
    assert FileTest.exists?( "#{file_prefix}.wiring_diagram.dot" )
  end

  test "creates state space" do
    file_prefix = "/tmp/xxxs"
    create_file( "#{file_prefix}.functionfile.txt", deterministic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.create_state_space = true
    dvd.run #false
    assert FileTest.exists?( "#{file_prefix}.state_space.dot" )
  end

  test "check deterministic wiring diagram" do 
    file_prefix = "/tmp/xxxw1"
    create_file( "#{file_prefix}.functionfile.txt", deterministic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.create_wiring_diagram = true
    dvd.run #false
    assert FileTest.exists?( "#{file_prefix}.wiring_diagram.dot" )
    assert_equal deterministic_wiring_diagram, File.read( "#{file_prefix}.wiring_diagram.dot" ), "Wiring diagram not as expected"
  end

  test "check stochastic wiring diagram" do 
    file_prefix = "/tmp/xxxs1"
    create_file( "#{file_prefix}.functionfile.txt", stochastic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.create_wiring_diagram = true
    dvd.run #false
    assert FileTest.exists?( "#{file_prefix}.wiring_diagram.dot" )
    assert_equal stochastic_wiring_diagram, File.read( "#{file_prefix}.wiring_diagram.dot" ), "Wiring diagram not as expected"
    File.delete("#{file_prefix}.functionfile.txt")
    File.delete("#{file_prefix}.wiring_diagram.dot")
  end

  test "check deterministic state space" do 
    file_prefix = "/tmp/xxxs2"
    create_file( "#{file_prefix}.functionfile.txt", deterministic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.create_state_space = true
    dvd.run #false
    assert FileTest.exists?( "#{file_prefix}.state_space.dot" )
    assert_equal deterministic_state_space, File.read( "#{file_prefix}.state_space.dot" ), "State space not as expected"
    File.delete("#{file_prefix}.functionfile.txt")
    File.delete("#{file_prefix}.state_space.dot")
  end

  test "check stochastic state space" do 
    file_prefix = "/tmp/xxxs3"
    create_file( "#{file_prefix}.functionfile.txt", stochastic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.create_state_space = true
    dvd.run #false
    assert FileTest.exists?( "#{file_prefix}.state_space.dot" )
    assert_equal stochastic_state_space, File.read( "#{file_prefix}.state_space.dot" ), "State space not as expected"
    File.delete("#{file_prefix}.functionfile.txt")
    File.delete("#{file_prefix}.state_space.dot")
  end
  
  test "check deterministic state space with probabilities" do 
    file_prefix = "/tmp/xxxs2"
    create_file( "#{file_prefix}.functionfile.txt", deterministic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.show_probabilities = true
    dvd.create_state_space = true
    dvd.run #true
    assert FileTest.exists?( "#{file_prefix}.state_space.dot" )
    assert_equal deterministic_state_space_with_probabilities, File.read( "#{file_prefix}.state_space.dot" ), "State space not as expected"
    File.delete("#{file_prefix}.functionfile.txt")
    File.delete("#{file_prefix}.state_space.dot")
  end

  test "check stochastic state space with probabilities" do 
    file_prefix = "/tmp/xxxs3"
    create_file( "#{file_prefix}.functionfile.txt", stochastic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.show_probabilities = true
    dvd.create_state_space = true
    dvd.run #true
    assert FileTest.exists?( "#{file_prefix}.state_space.dot" )
assert_equal stochastic_state_space_with_probabilities, File.read( "#{file_prefix}.state_space.dot" ), "State space not as expected"
    File.delete("#{file_prefix}.functionfile.txt")
    File.delete("#{file_prefix}.state_space.dot")
  end
  
  test "check stochastic state space with threshold .5 show probabilities" do 
    file_prefix = "/tmp/xxxs4"
    create_file( "#{file_prefix}.functionfile.txt", stochastic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.show_probabilities = true
    dvd.create_state_space = true
    dvd.probability_threshold = 0.5
    dvd.run #true
    assert FileTest.exists?( "#{file_prefix}.state_space.dot" )
assert_equal stochastic_state_space_threshold_0_5_with_probabilities, File.read( "#{file_prefix}.state_space.dot" ), "State space not as expected"
    File.delete("#{file_prefix}.functionfile.txt")
    File.delete("#{file_prefix}.state_space.dot")
  end

  test "check stochastic state space with threshold .5" do 
    file_prefix = "/tmp/xxxs4"
    create_file( "#{file_prefix}.functionfile.txt", stochastic_function_file )
    dvd = DVDCore.new(file_prefix, 3, 2)
    dvd.create_state_space = true
    dvd.probability_threshold = 0.5
    dvd.run #true
    assert FileTest.exists?( "#{file_prefix}.state_space.dot" )
assert_equal stochastic_state_space_threshold_0_5, File.read( "#{file_prefix}.state_space.dot" ), "State space not as expected"
    File.delete("#{file_prefix}.functionfile.txt")
    File.delete("#{file_prefix}.state_space.dot")
  end


end
