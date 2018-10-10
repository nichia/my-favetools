require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'

    enable :sessions
    set :session_secret, "favtools password_security"

    register Sinatra::Flash
  end #-- configure --

  # GET / route #index action
  get "/" do
    erb :index
  end

  # handle 404 errors
  not_found do
    if logged_in?
      erb :'not_found'
    else
      flash[:message] = "You need to be logged in"
      redirect :'/login'
    end
  end #-- not_found --

  helpers do

    def logged_in?
      !!current_user
      # !!session[:user_id]
    end

    def current_user
      @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
      # User.find(session[:user_id])
    end

    def logout
      session.clear
    end

    def path_info
      request.path_info
    end
  end #-- helpers --
end
