class JobsController < ApplicationController
  def create
    @job = Job.new(:nodes => 3, :simulate => true);
  end
  def generate
  end
end
