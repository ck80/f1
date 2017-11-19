class TipsController < ApplicationController
  before_action :get_tip, only: [:show, :edit, :update, :destroy]
  before_action :check_auth, only: [:destroy]
  
  def get_tip
    @tip = Tip.find(params[:id])
  end
  
  def check_auth
    if session[:user_id] != @tip.user_id
      flash[:notice] = "Sorry, you can't edit this tip"
      redirect_to(tips_path)
    end
  end
  
  # GET /tips
  # GET /tips.json
  def index
    if params[:name]
      @user = User.where(name: params[:name]).first
      @tips = @user.tips
    else
      @tips = Tip.all
      @users = User.all
      @races = Race.all
      @drivers = Driver.all
    end
  end

  # GET /tips/1
  # GET /tips/1.json
  def show

  end

  # GET /tips/new
  def new
    @tip = Tip.new
    @users = User.all
    @races = Race.all
    @drivers = Driver.all
  end

  # GET /tips/1/edit
  def edit
    @users = User.all
    @races = Race.all
    @drivers = Driver.all

  end

  # POST /tips
  # POST /tips.json
  def create
    @tip = Tip.new(tip_params)

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
      params.require(:tip).permit(:qual_first, :qual_second, :qual_third, :race_first, :race_second, :race_third, :race_tenth, :user_id, :race_id)
    end
end
