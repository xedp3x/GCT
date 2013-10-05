class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :init
  def init
    @MENU = {:home =>{
        :text => "Home",
        :controller => "user",
        :action => "index"
       },
       :people =>{
        :text => "Benutzer",
        :controller => "people",
        :action => "index",
        :hidden => true
       },
       :groups =>{
        :text => "Gruppen",
        :controller => "groups",
        :action => "index",
        :hidden => true
       },
       :pads =>{
        :text => "Pads",
        :controller => "pads",
        :action => "index"
       }
    }

    @config = YAML.load(File.open('config/gct.yml'))

    if request.subdomain.empty? then
      redirect_to :host => "www.#{@config["site"]["host"]}"
    else

      if request.subdomain == "www" then
        @GROUP = nil
        @GROUP_NAME = "General Community Toolbar"
        @MENU[:people][:hidden] = false
        @MENU[:groups][:hidden] = false
      else
        begin
          @GROUP = Group.find request.subdomain
        rescue ActiveLdap::EntryNotFound
          render :state => 404, :text => "Die Gruppe '#{request.subdomain}' ist unbekannt"
        return true
        end
        @GROUP_NAME = @GROUP.name
      end

      if !session[:user_id].nil? then
        begin
          @USER_LOGIN = true
          @USER = Person.find session[:user_id]
          if !@GROUP.nil? then
            if @GROUP.admin? @USER.id then
            @MENU[:group_admin] = {
              :text => "Admin",
              :url => {:host => "www.#{@config["site"]["host"]}", controller: :groups, action: :edit, id: @GROUP} 
            }
            end
          end
        rescue
          session[:user_id]= nil
        end
      end
      if (controller_name != 'user' or (controller_name == 'user' and action_name == 'index'))and session[:user_id].nil? then
        redirect_to :controller => "user", :action => "auth", :host => "www.#{request.host.split('.').last(2).join('.')}"
      end
    end
    @PAGE_TITLE = "GCT -  #{@GROUP_NAME}"
  end

end