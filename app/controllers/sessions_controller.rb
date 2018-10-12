class SessionsController < ApplicationController

  # GET /login route #login/new action
  # renders a form for logging in
  get '/login' do
    if logged_in?
      redirect :"/"
    else
      erb :'/sessions/login'
    end
  end

  # POST /login route #create action
  # find the user by username and check that the password matches up before registering the session data
  post '/login' do
    #raise params.inspect
    if params[:name].empty? || params[:password].empty?
      flash.now[:message] = "Username and password cannot be left blank."
      erb :'/sessions/login'
    else
      @user = User.find_by(name: params[:name])
      if !@user
        flash.now[:message] = "Account not found, please try again."
        erb :'/sessions/login'
      else
        if @user.authenticate(params[:password])
          # set session
          set_session
          redirect :"/"
        else
          flash.now[:message] = "Username and password combination do not match, please try again."
          erb :'/sessions/login'
        end
      end
    end
  end

  # GET /signup route #signup/new action
  # renders a form to signup a new user. The form includes fields for username, email and password
  # user registration
  get '/signup' do
    if logged_in?
      redirect :"/folders"
    else
      erb :'/sessions/signup'
    end
  end

  # POST /signup route #create action
  # create a new instance of user class with a username, email and password. Fill in the session data
  post '/signup' do
    #raise params.inspect
    if params[:name].empty? || params[:email].empty? || params[:password].empty?
      flash.now[:message] = "Username, email and password can not be left blank."
      erb :'/sessions/signup'
    elsif User.find_by(name: params[:name])
      flash.now[:message] = "Username already taken, please use another name."
      erb :'/sessions/signup'
    elsif User.find_by(email: params[:email])
      flash.now[:message] = "An account already exists with this email, please use another email."
      erb :'/sessions/signup'
    else
      @user = User.new
      @user.name = params[:name]
      @user.email = params[:email]
      @user.password = params[:password]
      @user.save

      # set session
      set_session
      redirect :"/folders"
    end
  end

  # GET /logout route #logout action
  # clears the session data and redirects to the homepage/landing page
  get '/logout' do
    if logged_in?
      # clear session
      logout
    end
    redirect :"/"
  end

end
