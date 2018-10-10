class UsersController < ApplicationController

  # GET /users #index action
  get '/users' do
    if logged_in?
      @users = User.all.sort_by do |user|
        user.name
      end
      erb :'/users/index'
    else
      redirect :"/login"
    end
  end

  # GET /users/:slug #show action
  # Read action to list this user's recipes
  get '/users/:slug' do
    if logged_in?
      @user = User.find_by_slug(params[:slug])
      if @user
        erb :'/users/show'
      else
        erb :'not_found'
      end
    else
      flash[:message] = "You must be logged in to view users info."
      redirect :"/login"
    end
  end

end
