class JobsController < ApplicationController
  def index
    @job = Job.new(:nodes => 3, :input_data => 
"1.2  2.3  3.4
1.1  1.2  1.3
2.2  2.3  2.4
0.1  0.2  0.3");
  end
  def generate
    @job = Job.new(params[:job]);
    @perl_output = `./polynome.pl #{@job.nodes}`
  end
end
