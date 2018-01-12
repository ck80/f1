class TipsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_tip, only: [:show, :edit, :update, :destroy]
  before_action :get_year
  before_action :check_auth, only: [:destroy]

  def get_year
    if params[:year].present? then
      @year = params[:year]
    else
      @year = Time.current.year
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
      @tips = Tip.joins(:race).where('races.year' => @year)
      @user = User.all
    else
      @tips = Tip.where(user_id: current_user.id).joins(:race).where('races.year' => @year)
      @user = current_user
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
    @users = User.all
    @races = Race.all
    @drivers = Driver.all
  end

  # GET /tips/1/edit
  def edit
    @users = User.all
    @user = current_user
    @races = Race.all
    @drivers = Driver.all

  end

  # POST /tips
  # POST /tips.json
  def create
    @tip = Tip.new(tip_params)
    @user = current_user
    @users = User.all
    @races = Race.all
    @drivers = Driver.all
    respond_to do |format|
      if @tip.save
        format.html { redirect_to @tip, notice: 'Tip was successfully created.' }
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
    @races = Race.all
    @drivers = Driver.all
    respond_to do |format|
      if @tip.update(tip_params)
        format.html { redirect_to @tip, notice: 'Tip was successfully updated.' }
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
      params.require(:tip).permit(:qual_first, :qual_second, :qual_third, :race_first, :race_second, :race_third, :race_tenth, :user_id, :race_id, :updated_by)
    end
end