require 'sinatra/base'

module Authenticate
  def auth_required(_)
    condition do
      redirect EnvironmentHelper.route("login") unless authenticated?
    end
  end

module Helpers
  def authenticated?
    @user != nil
  end
end

  def self.registered(app)
    app.before do
      @user = User[session[:user_id]]
    end

    app.helpers Authenticate::Helpers
    app.get EnvironmentHelper.route("login") do
      @errors = session[:errors] || {}
      session.delete(:errors)
      haml :login
    end

    app.post EnvironmentHelper.route("login") do
      errors = {}
      if !params[:name] || params[:name].empty?
        errors[:name] = "Invalid name"
      end

      if !params[:password] || params[:password].empty?
        errors[:password] = "Invalid password"
      end

      if !errors.empty?
        session[:errors] = errors
        redirect EnvironmentHelper.route("login")
      end

      user = User.authenticate(params[:name], params[:password])
      if user.nil?
        session[:errors] = { general: "Invalid name or password" }
        redirect EnvironmentHelper.route("login")
      end

      # Success
      session[:user_id] = user.id
      redirect EnvironmentHelper.route("")
    end

    app.get EnvironmentHelper.route("register") do
      @errors = session[:errors] || {}
      session.delete(:errors)
      haml :register
    end

    app.post EnvironmentHelper.route("register") do
      errors = {}
      if !params[:name] || params[:name].empty?
        errors[:name] = "Invalid name"
      end

      if !params[:password] || params[:password].empty?
        errors[:password] = "Invalid password"
      end

      if !errors.empty?
        session[:errors] = errors
        redirect EnvironmentHelper.route("register")
      end

      # Success, create user
      user = User.register(params[:name], params[:password])
      if user.nil?
        session[:errors] = {:general => "Name already taken!"}
        redirect EnvironmentHelper.route("register")
      end

      # Add to session and proceed
      session[:user_id] = user.id
      redirect EnvironmentHelper.route("")
    end

    app.get EnvironmentHelper.route("logout") do
      session.delete(:user_id)
      redirect EnvironmentHelper.route("")
    end
  end
end

register Authenticate
