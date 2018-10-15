class SessionsController < ApplicationController

  # GET /login route #login/new action
  # renders a form for logging in
  get '/login' do
    if logged_in?
      redirect :"/"
    else
      erb :'/sessions/login'
    end
  end #-- /login --

  # POST /login route #create action
  # find the user by username and check that the password matches up before registering the session data
  post '/login' do
    #raise params.inspect
    if params[:name].empty? || params[:password].empty?
      flash.now[:message] = "Username and password cannot be left blank."
      erb :'/sessions/login'
    else
      @user = User.find_by(name: params[:name])
      if @user
        if @user.authenticate(params[:password])
          # set session
          set_session
          redirect :"/users/#{current_user.slug}"
        else
          flash.now[:message] = "Username and password combination do not match, please try again."
          erb :'/sessions/login'
        end
      else
        flash.now[:message] = "Account not found, please try again."
        erb :'/sessions/login'
      end
    end
  end #-- post /login --

  # GET /logout route #logout action
  # clears the session data and redirects to the home page
  get '/logout' do
    if logged_in?
      # clear session
      logout
    end
    redirect :"/"
  end #-- /logout --
end
