class  Admin::HashtagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_hashtag, only: %i[ show edit update destroy ]

  # GET /hashtags or /hashtags.json
  def index
    @hashtags = Hashtag.all
  end

  # GET /hashtags/1 or /hashtags/1.json
  def show
  end

  # GET /hashtags/new
  def new
    @hashtag = Hashtag.new
  end

  # GET /hashtags/1/edit
  def edit
  end

  # POST /hashtags or /hashtags.json
  def create
    @hashtag = Hashtag.new(hashtag_params)
    if @hashtag.save
      redirect_to admin_hashtag_url(@hashtag), status: :created
    else
      render :new, status: :unprocessable_entity
    end
  end
  

  

  # PATCH/PUT /hashtags/1 or /hashtags/1.json
  def update
      if @hashtag.update(hashtag_params)
        redirect_to admin_hashtags_url
      else
        redirect_to edit_admin_hashtag_path, status: :unprocessable_entity
      end
  end


  def update_status
    @hashtag = Hashtag.find(params[:id])
    @hashtag.update(status: @hashtag.status==true ? false : true)
    redirect_to admin_hashtags_url
  end
  

  # DELETE /hashtags/1 or /hashtags/1.json
  def destroy
    @hashtag.destroy

    respond_to do |format|
      format.html { redirect_to admin_hashtags_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hashtag
      @hashtag = Hashtag.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def hashtag_params
      params.require(:hashtag).permit(:name, :status)
    end
    
end
