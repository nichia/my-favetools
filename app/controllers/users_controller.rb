class UsersController < ApplicationController

  # GET /users #index action
  get '/users' do
    #binding.pry
    if logged_in?
      @users = User.all.sort_by do |user|
        user.name
      end
      erb :'/users/index'
    else
      flash[:message] = "You must be logged in to list users."
      redirect :"/login"
    end
  end

  # GET /users/:slug #show user's tools action
  # Read action to list this user's account settings
  get '/users/:slug' do
    #binding.pry
    if logged_in?
      @user = User.find_by_slug(params[:slug])
      if @user
        if @user == current_user
          #find non-private tools that does not belong to current user, order by latest tools
          @tools = Tool.find_by_user(@user.id)
        else
          #find non-private tools that belong to username, order by latest tools
          @tools = Tool.find_by_privacy_user(false, @user.id)
        end
        erb :'/tools/index'
      else
        flash[:message] = "Username #{params[:slug]} not found."
        redirect :"/"
      end
    else
      flash[:message] = "You must be logged in to view user's info."
      redirect :"/login"
    end
  end

end
