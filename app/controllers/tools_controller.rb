class ToolsController < ApplicationController

  # GET /tools route #index action
  # index page to display all public tools
  get "/tools" do
    if logged_in?
      #find non-private tools that does not belong to current user, order by latest tools
      @tools = Tool.find_by_privacy_not_user(false, session[:user_id])

      erb :'/tools/index'
    else
      flash[:message] = "You must be logged in to view the tools."
      redirect :"/login"
    end
  end

  # GET /tools/new route #new action
  get "/tools/new" do
    if logged_in?
      @folders = Folder.where(user_id: current_user).sort_by do |folder|
        folder.name
      end
      erb :'/tools/new'
    else
      flash[:message] = "You must be logged in to create tools."
      redirect :"/login"
    end
  end

  # POST /tools route #create action
  # create new tool
  post '/tools' do
    #raise params.inspect
    #binding.pry
    if logged_in?
      tool = Tool.find_by(name: params[:tool][:name])
      if tool && tool.folder_id == params[:tool][:folder_id]
        # Flash Message when the new tool name already exists for this folder
        flash[:message] = "You already have a tool with this name for this folder, please use another name."
        erb :'/folders/new'
      else
        @tool = Tool.create(params[:tool])
        # Flash Message when a new tool is created
        flash[:message] = "Successfully created a tool."
        redirect :"/tools/#{@tool.id}/#{@tool.slug}"
      end
    else
      flash[:message] = "You must be logged in to create tools."
      redirect :"/login"
    end
  end

  # GET /tools/:id/:slug route # Show action
  # displays one tool based on ID and slug in the url
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
      flash[:message] = "You must be logged in to view the Tool information."
      redirect :"/login"
    end
  end


  # DELETE /tools/:slug/delete route #delete action
  delete '/tools/:id/:slug/delete' do
    #binding.pry
    if logged_in?
      @tool = Tool.find_by_id(params[:id])
      if @tool && @tool.folder.user == current_user
        @tool.delete
        flash[:message] = "You've successfully deleted your tool #{params[:slug]}!"
        redirect :"/users/#{current_user.slug}"
      else
        flash[:message] = "You must be the tool owner to delete this record."
        redirect :"/tools/#{@tool.id}/#{@tool.slug}"
      end
    else
      flash[:message] = "You must be logged in to delete a tool."
      redirect :"/login"
    end
  end
end
