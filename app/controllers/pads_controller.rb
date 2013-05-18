class PadsController < ApplicationController
  def init
    super
    @MENU[:pads][:active] = true
  end
  
  def index
    begin
      etherpad = EtherpadLite.connect("http://#{@config["pad"]["host"]}:#{@config["pad"]["port"]}",@config["pad"]["key"], @config["pad"]["version"])

      group = etherpad.group(@GROUP.id)
      @pads = group.pads
    rescue Exception => e
      @error = "Etherpad Fehler"
      @mesage = e.message
      render :action => 'error'
    end
  end

  def new
    id = if params[:pad] != '' then params[:pad] else Time.now.strftime "%Y%m%d-%H%M" end

    begin
      etherpad = EtherpadLite.connect("http://#{@config["pad"]["host"]}:#{@config["pad"]["port"]}",@config["pad"]["key"], @config["pad"]["version"])
      group_name =  if @GROUP.nil? then 'PUBLIC' else @GROUP.id end
      group = etherpad.group(group_name)
      pad = group.create_pad id
    rescue
    end
    redirect_to action: :show, pad: id
  end

  def delete
    etherpad = EtherpadLite.connect("http://#{@config["pad"]["host"]}:#{@config["pad"]["port"]}",@config["pad"]["key"], @config["pad"]["version"])
    etherpad.group(@GROUP.id).pad(params[:pad]).delete
    redirect_to action: :index
  end

  def show
    begin
      etherpad = EtherpadLite.connect("http://#{@config["pad"]["host"]}:#{@config["pad"]["port"]}",@config["pad"]["key"], @config["pad"]["version"])

      group_name =  if @GROUP.nil? then 'PUBLIC' else @GROUP.id end
      group = etherpad.group(group_name)

      pad = group.get_pad params[:pad]
      pad.text
      author = etherpad.author(@USER.id, :name => @USER.givenName)

      session[:ep_sessions] = {} if session[:ep_sessions].nil?

      sess = session[:ep_sessions][group_name] ? etherpad.get_session(session[:ep_sessions][group_name]) : group.create_session(author, 60)
      if sess.expired?
      sess.delete
      sess = group.create_session(author, 60)
      end
      session[:ep_sessions][group_name] = sess.id

      cookies[:sessionID] = {:value => sess.id, :domain => @config["pad"]["host"]}

      @url = "http://#{@config["pad"]["host"]}:#{@config["pad"]["port"]}/p/#{pad.id}"
      @PAGE_TITLE = params[:pad]
    rescue Exception => e
      @error = "Etherpad Fehler"
      @mesage = e.message
      render :action => 'error'
    end
  end
end
