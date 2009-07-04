class JobsController < ApplicationController
  def create
    @job = Job.new(:nodes => 3);
  end
  def generate
  end
end
