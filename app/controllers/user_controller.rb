class UserController < ApplicationController
  def init
    super
    @MENU[:home][:active] = true
  end

  def index
    @user = @USER
    if params[:new] then
      @hide_data = true
      if params[:new] != params[:new2] then
        @error = "Die Passwort wiederholung ist falsch!"
      elsif !@user.auth params[:old] then
        @error = "Dein bisheriges Password ist falsch!"
      else
        @user.auth= params[:new]
        @user.save
        @hide_data = false
      end
    end
  end

  def token
    begin
      u= Person.find params[:uid]
      if params[:time] then
        if params[:time].to_i + 6*60*60 < Time.now.to_i then
          @error = "Der Link ist älter als 6 Stunden und daher ungültig"
        else
          if Base64.encode64(Digest::MD5.digest("#{params[:time]}#{u.userPassword}")).gsub('/','|') != params[:token] then
            @error = "Der Link ist alt oder defekt!"
          end
        end
      else
        if !u.auth params[:token] then
          @error = "Der Link ist alt oder defekt!"
        end
      end
    rescue ActiveLdap::EntryNotFound
      @error = "Der Link ist alt oder defekt!"
    end
    if params[:password] and !@error.nil? then
      if params[:password] != params[:password2] then
        @error = "Deine Passwordwiederholung ist falsch"
      else
        u.auth= params[:password]
        u.save
        redirect_to :controller => "user", :action => "auth", :uid => u.uid
      end
    end
  end

  def auth
    @MENU[:home][:active] = false
    if params[:name] then
      begin
        u= Person.find params[:name]
        if u.auth params[:password] then
          session[:user_id]= u.id
          redirect_to :action => "index"
        else
          @error = "Username oder Passwort ist falsch"
        end
      rescue ActiveLdap::EntryNotFound
        @error = "Username oder Passwort ist falsch"
      end
    end
  end

  def reset
    if !@config["user"]["recovery"] then
      render state: :forbidden, text: "Password recovery is diabled!"
      return
    end
    @MENU[:home][:active] = false
    begin
      u= Person.find params[:name]
      UserMailer.reset_email(u).deliver
      render text: "Sie erhlaten gleich eine Mail."
    rescue ActiveLdap::EntryNotFound
      @error = "Username ist falsch"
      render 'auth'
    end

  end

  def logout
    reset_session
    redirect_to :action => 'auth', :host => @config["site"]["host"]
  end
end
