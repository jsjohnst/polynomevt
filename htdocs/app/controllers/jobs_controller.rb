require 'ftools'

class JobsController < ApplicationController
  before_filter :check_authentication, :except => :show
  
  # GET /jobs
  # GET /jobs.xml
  def index
    @jobs = Job.find(:all, :conditions => { :user_id => session[:user] })

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @jobs }
    end
  end

  # GET /jobs/1
  # GET /jobs/1.xml
  def show
    @job = Job.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @job }
    end
  end

  # GET /jobs/new
  # GET /jobs/new.xml
  def new
    @job = Job.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @job }
    end
  end

  # GET /jobs/1/edit
  def edit
    @job = Job.find(params[:id])
    
    respond_to do |format|
      format.html { render :action => "new" }
      format.xml { render :xml => @job }
    end
  end

  # POST /jobs
  # POST /jobs.xml
  def create
    if params[:job][:input_file]
      params[:job][:input_data] = params[:job][:input_file].read
      params[:job].delete(:input_file)
    end
    
    if params[:job][:known_functions_file]
      params[:job][:known_functions] = params[:job][:known_functions_file].read
      params[:job].delete(:known_functions_file)
    end
    
    params[:job][:user_id] = session[:user]
    
    @job = Job.new(params[:job])

    respond_to do |format|
      if @job.save
        Delayed::Job.enqueue ComputationJob.new(@job.id)
        flash[:notice] = 'Job was successfully created.'
        format.html { redirect_to(jobs_url) }
        format.xml  { render :xml => @job, :status => :created, :location => @job }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.xml
  def update
    if params[:job][:input_file]
      params[:job][:input_data] = params[:job][:input_file].read
      params[:job].delete(:input_file)
    end
    
    if params[:job][:known_functions_file]
      params[:job][:known_functions] = params[:job][:known_functions_file].read
      params[:job].delete(:known_functions_file)
    end
    
    params[:job][:user_id] = session[:user]
    
    @job = Job.new(params[:job])

    respond_to do |format|
      if @job.save
        Delayed::Job.enqueue ComputationJob.new(@job.id)
        flash[:notice] = 'Job was successfully created.'
        format.html { redirect_to(jobs_url) }
        format.xml  { render :xml => @job, :status => :created, :location => @job }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.xml
  def destroy
    @job = Job.find(params[:id])
 	
    if @job.file_prefix
    	Dir.glob("public/" + @job.file_prefix + "*") { |filename|
		logger.info("Deleting file: " + filename);
		if File.directory?(filename) 
			FileUtils.rm_rf(filename)
		else 
			FileUtils.rm(filename)
		end
	}  
    end

    @job.destroy

    respond_to do |format|
      format.html { redirect_to(jobs_url) }
      format.xml  { head :ok }
    end
  end
end
