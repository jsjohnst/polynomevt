class UsersController < ApplicationController
  before_filter :check_authentication, :only => [:profile, :edit, :destroy]
  
  def authenticate
    session[:user] = nil # force logout
    @user = User.new
    if request.post?
      @user = User.find_by_login(params[:user][:login])
      
      if(@user.password != params[:user][:password]) 
        flash[:notice] = 'Authentication failed. Invalid login / password'
      else
        session[:user] = @user.id
        
        # TODO: Find a cleaner way to do the below 4 lines of code
        redirect_action = session[:intended_action]
        session[:intended_action] = nil
        redirect_controller = session[:intended_controller]
        session[:intended_controller] = nil
        
        if !redirect_action || !redirect_controller
          redirect_action = :profile
          redirect_controller = :users
        end
        
        redirect_to :action => redirect_action, :controller => redirect_controller
      end
    end
  end
  
  def register
    # We set this to nil, otherwise when we redirect we could be 
    # logged in still as the previous user
    session[:user] = nil
    @user = User.new
    if request.post?
      @user = User.new(params[:user])
      if @user.save
        flash[:notice] = 'User was successfully created.'
        session[:user] = @user.id
        redirect_to :action => :profile
      else
        render :action => :register
      end
    end
  end
  
  def logout
    session[:user] = nil
    redirect_to :action => :authenticate
  end
  
  def index
    redirect_to :action => :profile
  end
  
  def profile
    @user = User.find(session[:user])
  end
  
  def lostpassword
    
  end
  
  def lostlogin
    
  end

  def edit
    @user = User.find(session[:user])
    if request.put?
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        redirect_to :action => :profile
      end
    end
  end
  
  def destroy
    @user = User.find(session[:user])
    if request.delete?
      session[:user] = nil
      @user.destroy
      redirect_to :action => :logout
    end
  end
end
