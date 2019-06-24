class TipsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_tip, only: [:show, :edit, :update, :destroy]
  before_action :get_year
  before_action :check_auth, only: [:destroy]

  def get_year
    if params[:year].present? then
      @year = params[:year].to_s
    else
      @year = Time.current.year.to_s
    end
  end
  
  def get_tip
    @tip = Tip.find(params[:id])
  end
  
  def check_auth
    if current_user.id != @tip.user.id
      flash[:notice] = "Sorry, you can't edit this tip, it doesn't belong to you"
      redirect_to(tips_path)
    end
  end

  # GET /tips
  # GET /tips.json
  def index
    if current_user.admin?
      @tips = Tip.joins(:race).where('races.year' => @year).order('races.race_number ASC')
      @users = User.all
    else
      @user = current_user
      @tips = Tip.joins(:race).where("races.year = ? AND races.ical_dtstart < ? AND user_id != ?", @year, Time.current, @user.id)
      @tips = @tips + Tip.joins(:race).where("races.year = ? AND user_id = ?", @year, @user.id)

    end
  end

  # GET /tips/1
  # GET /tips/1.json
  def show
  end

  # GET /tips/new
  def new
    @tip = Tip.new
    @user = current_user
    @users = User.where(approved: true).where('name ASC')
    @races = Race.where(year: @year).order('race_number ASC')
    @drivers = Driver.where(year: @year).order('abbr_name ASC')

  end

  # GET /tips/1/edit
  def edit
    @user = current_user
    @users = User.where(approved: true).where('name ASC')
    @races = Race.where(year: @year).order('race_number ASC')
    @drivers = Driver.where(year: @year).order('abbr_name ASC')

  end

  # POST /tips
  # POST /tips.json
  def create
    @tip = Tip.new(tip_params)
    @user = current_user
    @users = User.all
    @races = Race.where(year: @year).order('race_number ASC')
    @drivers = Driver.where(year: @year).order('abbr_name ASC')

    respond_to do |format|
      if @tip.save
        format.html { redirect_to tips_path, notice: 'Tip was successfully created.' }
        format.json { render :show, status: :created, location: @tip }
      else
        format.html { render :new }
        format.json { render json: @tip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tips/1
  # PATCH/PUT /tips/1.json
  def update
    @users = User.all
    @user = current_user
    @races = Race.where(year: @year).order('race_number ASC')
    @drivers = Driver.where(year: @year).order('abbr_name ASC')
    respond_to do |format|
      if @tip.update(tip_params)
        format.html { redirect_to tips_path, notice: 'Tip was successfully updated.' }
        format.json { render :show, status: :ok, location: @tip }
      else
        format.html { render :edit }
        format.json { render json: @tip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tips/1
  # DELETE /tips/1.json
  def destroy
    @tip.destroy
    respond_to do |format|
      format.html { redirect_to tips_url, notice: 'Tip was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def tip_params
      params.require(:tip).permit(:qual_first, :qual_second, :qual_third, :race_first, :race_second, :race_third, :race_tenth, :user_id, :race_id, :updated_by, :modifier_is_admin)
    end
end
