class PeopleController < ApplicationController
  def init
    super
    @MENU[:people][:active] = true
    #redirect_to :controller => 'home', :action => 'error_403' if !@USER.member? 'ldapmanager'
  end

  # GET /people
  # GET /people.json
  def index
    @people = Person.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @people }
    end
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @person = Person.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @person }
    end
  end

  # GET /people/1/attribute/sn
  def get_attribute
    person = Person.find(params[:id]);

    mime = "application/octet-stream"

    atr = person.must + person.may
    atr.each { |e|
      if e.name == params[:attribute] then
        case e.syntax.id
        when "1.3.6.1.4.1.1466.115.121.1.28"
          mime = "image/jpeg"
        end
      end
    }
    a = person.attributes[params[:attribute]]
    if a.kind_of?(Array) then a = a[0] end

    if a.nil?  then
      render :status => 404
    else
      send_data a, :type => mime
    end
  end

  # GET /people/new
  # GET /people/new.json
  def new
    @person = Person.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
  end

  # POST /people
  # POST /people.json
  def create
    if !params[:upload].nil? then
      params[:upload].each { |n,f|
        params[:person][n] = f.tempfile.read
      }
    end

    @person = Person.new(params[:person])

    token = SecureRandom.hex(20)

    @person.homeDirectory= "/home/ldap/#{@person.uid}"
    @person.gidNumber= 500
    @person.uidNumber= 1000
    @person.auth= token
    Person.all.each{|p|
      @person.uidNumber = p.uidNumber + 1 if p.uidNumber >= @person.uidNumber
    }

    respond_to do |format|
      if @person.save
        #UserMailer.welcome_email(@person,@USER,token).deliver
        format.html { redirect_to @person, notice: 'Person was successfully created.' }
        format.json { render json: @person, status: :created, location: @person }
      else
        format.html { render action: "new" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.json
  def update
    @person = Person.find(params[:id])

    if !params[:upload].nil? then
      params[:upload].each { |n,f|
        params[:person][n] = f.tempfile.read
      }
    end

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end
end
