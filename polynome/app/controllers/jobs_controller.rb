class JobsController < ApplicationController
  def create
    @job = Job.new(:nodes => 3);
  end
  def generate
    @job = Job.new(params[:job]);
    @perl_output = `./polynome.pl #{@job.nodes}`
  end
end
