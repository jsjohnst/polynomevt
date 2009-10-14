require 'test_helper'

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

  test "creates wiring diagram" do
  end

  test "check deterministic wiring diagram" do 
  end

  test "check stochastic wiring diagram" do 
  end

  test "creates state space" do
  end

  test "check deterministic state space" do 
  end

  test "check stochastic state space" do 
  end

end
