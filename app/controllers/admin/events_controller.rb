class Admin::EventsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_event, only: %i[ show  destroy ]
  
    # GET /users or /users.json
    def index
      @events = Event.all
    end
  
    # GET /users/1 or /users/1.json
    def show
      @options_all = EventCategory.pluck(:event_category,:id)
      @option = EventCategory.find_by(id:@event.event_categories_id)
      @selected = [@option[:event_category],@option[:id]]

    end

    def update
      @event = Event.find_by(id:params[:id])
      @event.update(update_params)
      redirect_to admin_event_path(@event)
    end
    

    def update_status
      @event = Event.find(params[:id])
      @user = User.find_by(id: @event.user_id)
      if @user.status == "active"
        @event.update(is_approved: !@event.is_approved)
      end
      if @event.is_approved == true && @event.event_status == 'suspended'
        @event.update(event_status: :active)

      else
        @event.update(is_approved: false, event_status: :suspended)
      end
      redirect_to admin_events_url
    end
    
   
  
    # DELETE /users/1 or /users/1.json
    def destroy
      @event.destroy
  
      respond_to do |format|
        format.html { redirect_to admin_events_url, notice: "Event was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event
        @event = Event.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def event_params
        params.fetch(:event, {})
      end
      
      def update_params
        params.require(:event).permit(:title,:location,:latitude,:longitude,:start_date,:start_time,:end_date,:end_time,:description,:image)
      end

end