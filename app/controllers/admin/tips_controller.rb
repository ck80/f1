class Admin::TipsController < ApplicationController
  before_action :set_admin_tip, only: [:show, :edit, :update, :destroy]

  # GET /admin/tips
  # GET /admin/tips.json
  def index
    @admin_tips = Admin::Tip.all
  end

  # GET /admin/tips/1
  # GET /admin/tips/1.json
  def show
  end

  # GET /admin/tips/new
  def new
    @admin_tip = Admin::Tip.new
  end

  # GET /admin/tips/1/edit
  def edit
  end

  # POST /admin/tips
  # POST /admin/tips.json
  def create
    @admin_tip = Admin::Tip.new(admin_tip_params)

    respond_to do |format|
      if @admin_tip.save
        format.html { redirect_to @admin_tip, notice: 'Tip was successfully created.' }
        format.json { render :show, status: :created, location: @admin_tip }
      else
        format.html { render :new }
        format.json { render json: @admin_tip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/tips/1
  # PATCH/PUT /admin/tips/1.json
  def update
    respond_to do |format|
      if @admin_tip.update(admin_tip_params)
        format.html { redirect_to @admin_tip, notice: 'Tip was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_tip }
      else
        format.html { render :edit }
        format.json { render json: @admin_tip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/tips/1
  # DELETE /admin/tips/1.json
  def destroy
    @admin_tip.destroy
    respond_to do |format|
      format.html { redirect_to admin_tips_url, notice: 'Tip was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_tip
      @admin_tip = Admin::Tip.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_tip_params
      params.fetch(:admin_tip, {})
    end
end
