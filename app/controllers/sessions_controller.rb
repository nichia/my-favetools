class SessionsController < ApplicationController

  # GET /login route #login/new action
  # renders a form for logging in
  get '/login' do
    if logged_in?
      redirect :"/users/#{current_user.slug}"
    else
      erb :'/sessions/login'
    end
  end #-- /login --

  # POST /login route #login validation action
  # find the user by username and check that the password matches up before registering the session data
  post '/login' do
    #raise params.inspect
    if params[:name_or_email].rindex('@')
      @user = User.find_by(email: params[:name_or_email])
    else
      @user = User.find_by(name: params[:name_or_email])
    end

    if @user
      if @user.authenticate(params[:password])
        # set session
        set_session
        flash[:message] = "Successfully logged in as #{current_user.name}"
        redirect :"/users/#{current_user.slug}/folders"
      else
        flash.now[:message] = "Username/email and password combination do not match, please try again"
        erb :'/sessions/login'
      end
    else
      flash.now[:message] = "User account not found, please try again"
      erb :'/sessions/login'
    end
  end #-- post /login --

  # GET /logout route #logout action
  # clears the session data and redirects to the home page
  get '/logout' do
    if logged_in?
      # clear session
      logout
      flash[:message] = "You've successfully logged out"
    end
    redirect :"/"
  end #-- /logout --
end
