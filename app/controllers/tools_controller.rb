class ToolsController < ApplicationController

  # GET /tools route #index action
  # index page to display all public tools
  get "/tools" do
    if logged_in?
      #find non-private tools that does not belong to current user, order by latest tools
      @tools = Tool.find_by_privacy_not_user(false, session[:user_id])

      erb :'/tools/index'
    else
      flash[:message] = "You must be logged in to view the Tools."
      redirect :"/login"
    end
  end

  # GET /tools/:id/:slug route # Show action
  # displays one article based on ID and slug in the url
  get '/tools/:id/:slug' do
    #binding.pry
    if logged_in?
      @tool = Tool.find_by_id(params[:id])
      if @tool && @tool.slug == params[:slug]
        erb :'/tools/show'
      else
        flash.now[:message] = "Tool's id and name combination not found, please try again."
        redirect :"/tools"
      end
    else
      flash[:message] = "You must be logged in to view Tool's information."
      redirect :"/login"
    end
  end

end
