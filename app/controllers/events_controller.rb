class EventsController < ApplicationController

  include Responses
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

# all events 
  def index
    @events = Event.all.where(is_approved:true, event_status: [:active])
    user = current_user
    if @events.present?
      event_data = build_event_data(@events)
      
      success(data: event_data)
    else
      error_404("No event found")
    end
  end

  def create
    @event = current_user.events.build(set_params)
    image = params[:image]
    if image.present?
      @event.image.attach(image)
    end

    if params[:hashtags].present?
      hashtag_names = params[:hashtags].first.gsub(/[\[\]\s]/, '').split(',').map { |name| name.delete('#') }.join(',')
      hashtags = hashtag_names.split(",")
      h = create_or_find_hashtags(hashtags) 
    end
  
    if @event.start_date.present? && @event.start_date > Time.zone.now
      @event.update(event_status: :active)
      if @event.save
        if h.present?
          h.each do |hashtag|
            EventHashtag.create(event_id: @event.id, hashtag_id: hashtag.id)
          end 
        end
        success("Event successfully created", id: @event.id)
      else
        error("all fields are required")
      end
    else
      error("Event date must be in the future")
    end
  end
 
  def destroy
    @event = Event.find_by(id: params[:id])
  
    if @event
      if @event.user == current_user
        EventHashtag.where(event_id: @event.id).destroy_all
        FavouriteEvent.where(event_id: @event.id).destroy_all
        EventAttendee.where(event_id: @event.id).destroy_all
        LikeEvent.where(event_id: @event.id).destroy_all
        Report.where(report_type: 1 ).destroy_all
       
  
        @event.destroy
        success("Event deleted successfully")
      else
        error_403("You are not authorized") # User is not authorized to delete the event
      end
    else
      error_404("Event not found") # Display custom error message for event not found
    end
  end
  
  
  
  def update
    @event = current_user.events.find_by(id: params[:id])
    if @event.present?

    image = params[:image]
    if image.present?
      @event.image.attach(image)
    end
  
    if params[:hashtags].present?
      hashtag_names = params[:hashtags].first.gsub(/[\[\]\s]/, '').split(',').map { |name| name.delete('#') }.join(',')
      hashtags = hashtag_names.split(",")
      h = create_or_find_hashtags(hashtags)
    end
  
    if @event.start_date.present? && @event.start_date > Time.zone.now
      if @event.update(set_params)
        if h.present?
          @event.event_hashtags.destroy_all
          h.each do |hashtag|
            EventHashtag.create(event_id: @event.id, hashtag_id: hashtag.id)
          end
        end
        success("Event successfully updated", id: @event.id)
      else
        error_400("all fields are required")
      end
    else
      error("Event date must be in the future")
    end
  else
    error_404("Event not found")
  end
  end
  
  
  
# all events of current user
  def show_all
    @events = Event.where(user_id: current_user)
    if @events.present?
      event_data = build_event_data(@events)
      success(data: event_data)
    else
      error_404("No event found for the user")
    end
  end



  # def sort_events
  #   order_by = params[:order_by]
  #   case order_by
  #   when "start_time"
  #     @events = Event.order(start_time: :asc)
  #   when "start_date"
  #     @events = Event.order(start_date: :asc)
  #   else
  #     @events = Event.all
  #   end
    
  #   if @events.present?
  #     event_data = build_event_data(@events)
  #     success(data: event_data)
  #   else
  #     error_404("not found")
  #   end
  # end
  
  def search_events
    search_by = params[:search_by]
    case search_by
    when 'location'
      search_query = params[:location]
      @events = Event.where(location: search_query)
    when 'start_date'
      search_query = params[:start_date]
      @events = Event.where(start_date: search_query)
    when 'title'
      search_query = params[:title]
      @events = Event.where(title: search_query)
    when 'hashtags'
      search_query = params[:hashtags]
      @events = Event.joins(:event_hashtags, :hashtags).where(hashtags: { name: search_query })
    when 'event_categories'
      search_query = params[:event_categories]
      @events = Event.joins(:event_categories, :category_name).where(hashtags: { name: search_query })
    else
      @events = Event.all
    end
    if @events.present?
      event_data = build_event_data(@events)
      success(data: event_data)
    else
      error_404("Not found")
    end
  end
  



  def event_categories
    @categories = EventCategory.all
    data = @categories.map { |category| { id: category.id, category_name: category.event_category } }
    success(event_category: data)
  end
  

  def events_details
    @event = Event.find_by(id: params[:id])
    if @event.present?
      category_name = EventCategory.find(@event.event_categories_id).event_category
      user = Profile.find_by(user_id: @event.user_id)
      hashtags = @event.hashtags.pluck(:name)
      if user.image.present?
        profileimage = url_for(user.image)
      else
        profileimage = nil
      end
      follower_count = UserFollower.where(user_id: @event.user_id).count
      event_attendees_count = EventAttendee.where(event_id: @event.id).count
  
      liked_by_current_user = LikeEvent.find_by(user_id: current_user.id, event_id: @event.id)
      is_liked = liked_by_current_user.present?
  
      joined_by_current_user = EventAttendee.find_by(user_id: current_user.id, event_id: @event.id)
      is_joined = joined_by_current_user.present?
  
      favourite = FavouriteEvent.find_by(user_id: current_user.id, event_id: @event.id)
      is_favourite = favourite.present?
  
      followed = UserFollower.find_by(user_id: @event.user_id, followed_by_id: current_user.id)
      is_followed = followed.present?
  
      like_count = LikeEvent.where(event_id: @event.id).count
      
      can_join = current_user.id != @event.user_id # Check if current user is different from the event creator
  
      event_data = {
        id: @event.id,
        title: @event.title,
        location: @event.location,
        latitude: @event.latitude,
        longitude: @event.longitude,
        is_approved: @event.is_approved,
        event_status: @event.event_status,
        start_date: @event.start_date,
        start_time: @event.start_time.strftime('%H:%M'),
        end_date: @event.end_date,
        end_time: @event.end_time.strftime('%H:%M'),
        user_id: @event.user_id,
        description: @event.description,
        event_category_id: @event.event_categories_id,
        event_category_name: category_name,
        hashtags: hashtags,
        user_name: user.first_name + " " + user.last_name,
        image_url: @event.image.present? ? url_for(@event.image) : nil,
        user_profile_image: profileimage,
        follower_count: follower_count.present? ? follower_count : nil,
        event_attendees_count: event_attendees_count.present? ? event_attendees_count : nil,
        is_liked: is_liked,
        is_joined: is_joined,
        is_favourite: is_favourite,
        is_followed: is_followed,
        can_join_event: can_join,
        like_count: like_count
      }
      success(data: event_data)
    end
  end
  
  def user_details
    @user = User.find_by(id: params[:id])
    if @user.nil?
      error_404("User not found")
    else
      @profile = @user.profile
      if @profile.nil?
        error_404("Profile not found")
      else
        follower_count = UserFollower.where(user_id: @user.id).count
        is_followed = UserFollower.find_by(user_id: @user.id, followed_by_id: current_user.id)
        can_follow =  current_user.id !=@user_id
       
        data = {
           "username": @profile.first_name + " " +@profile.last_name,
          "email": @user.email,
          "profile_image": @profile.image.present? ? url_for(@profile.image) : nil,
          "follower_count": follower_count.present? ? follower_count : nil,
          "is_followed": is_followed.present? ? true : false,
          "can_follow": can_follow
      
        }
        success(data: data)
      end
    end
  end
  
  




#report event or user
def report
  type = params[:type]
  case type
  when 1
    report_event(type)
  when 2
    report_user(type)
  else
    error("Invalid report type")
  end
end


  def report_event(type)
    event = Event.find_by(id: params[:id])
    description = params[:description]
    if event.nil?
      error_404("Event not found")
      return
    end
    if event.user_id == current_user.id
      error("You cannot report your own event")
      return
    end
    if Report.exists?(reported_id: event.id, reported_by_id: current_user.id, report_type: type)
      error("You have already reported this event")
      return
    end

    reported_event = Report.create(reported_id: event.id, reported_by_id: current_user.id,report_type: type, description: description)
    if reported_event.save
      success("Event reported successfully")
    else
      error("Failed to report the event")
    end
  end

  
# def report_user(type)
#     user = User.find_by(id: params[:id])
#     description = params[:description]
#     if user.nil?
#       error_404("user not found")
#       return
#     end
#     if user.id == current_user.id
#       error("You cannot report yourself")
#       return
#     end
#     if Report.exists?(reported_id: user.id, reported_by_id: current_user.id, report_type: type)
#       error("You have already reported this event")
#       return
#     end
#     reported_user = Report.create(reported_id: user.id, reported_by_id: current_user.id,report_type: type, description: description)
#     if reported_user.save
#       success("User reported successfully")
#     else
#       error("Failed to report the User")
#     end
#  end
  

def report_user(type)
  user = User.find_by(id: params[:id])
  description = params[:description]

  # Check if the user exists
  if user.nil?
    error_404("User not found")
    return
  end

  # Check if the user is reporting themselves
  if user.id == current_user.id
    error("You cannot report yourself")
    return
  end

  # Check if the report already exists
  if Report.exists?(reported_id: user.id, reported_by_id: current_user.id, report_type: type)
    error("You have already reported this user")
    return
  end

  begin
    Report.transaction do
      report = Report.new(reported_id: user.id, reported_by_id: current_user.id, report_type: type, description: description)
      report.save!
      success("User reported successfully")
    end
  rescue => e
    error("Failed to report the user: #{e.message}")
  end
end

  

 def mark_favourite
  event = Event.find_by(id: params[:id])
  unless event
    return  error_404("Event not found")
  end
  favourite_event = FavouriteEvent.find_by(user_id: current_user.id, event_id: event.id)
  if favourite_event
    favourite_event.destroy
    success("Event is unmarkedfrom from favourite")
  else
  favourite_event = FavouriteEvent.new(user_id: current_user.id, event_id: event.id)
  if favourite_event.save
    success_201("Event marked as favorite")
  else
    error("Failed to mark event as favorite")
  end
end
end

def favorite_events
  @fav_events = FavouriteEvent.where(user_id: current_user.id)
  @events = Event.where(id: @fav_events.pluck(:event_id), is_approved: true) 
  if @events.present?
    event_data = build_event_data(@events)
    success(data: event_data)
  else
    error_404("No event found for the user")
  end
end

def join_event
  event = Event.find_by(id: params[:id])
  unless event
    return error_404("Event not found")
  end
  join_event = EventAttendee.find_by(user_id: current_user.id, event_id: event.id)
  if join_event
    join_event.destroy
    success("You canceled this join")
  else
  attendee = EventAttendee.new(user_id: current_user.id, event_id: event.id)
  if attendee.save
    success_201("You have joined the event")
  else
    error("Failed to join the event")
  end
end
end


  def follow_user
    followed_user = User.find_by(id: params[:id])
    unless followed_user
      return error_404("User not found")
    end

    isfollowed =  UserFollower.find_by(user_id: followed_user.id, followed_by_id: current_user.id)
    if  isfollowed 
      isfollowed.destroy
      success("You have unfollowed this user")
    else
    follower = UserFollower.create(user_id: followed_user.id, followed_by_id: current_user.id)
    if follower.save
      success_201("You are now following ")
    else
      error("Failed to follow the user")
    end
  end
end

  def like_event
    event = Event.find_by(id: params[:id])
    unless event
      return error_404("Event not found")
    end
    like = LikeEvent.find_by(event_id: event.id, user_id: current_user.id)
    if like
      like.destroy
      success("You have unliked the event")
    else
      like = LikeEvent.create(event_id: event.id, user_id: current_user.id)
      if like.save
        success_201("You have liked the event")
      else
        error("Failed to like the event")
      end
    end
  end
  


def events_nearby
  latitude = params[:latitude]
  longitude = params[:longitude]
  radius = params[:radius]

  # Calculate the bounding box coordinates
  bounding_box = Geocoder::Calculations.bounding_box([latitude, longitude], radius)
  events = Event.where(
    'latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?',
    bounding_box[0], bounding_box[2], bounding_box[1], bounding_box[3]
  )
  nearby_events = events.select do |event|
    distance = Geocoder::Calculations.distance_between(
      [latitude, longitude], [event.latitude, event.longitude]
    )
    distance <= radius
  end

  if nearby_events.present?
    event_data = build_event_data(nearby_events)
    success(data: event_data)
  else
    error_404("No events found nearby")
  end
end






private


def build_event_data(events)
  events.map do |event|
    category_name = EventCategory.find(event.event_categories_id).event_category
    user = Profile.find_by(user_id: event.user_id)
    hashtags = event.hashtags.pluck(:name)
    if user.image.present?
      profileimage = url_for(user.image)
    else
      profileimage = nil
    end
    follower_count =  UserFollower.where(user_id: event.user_id).count

    event_attendees_count = EventAttendee.where(event_id: event.id).count

    liked_by_current_user = LikeEvent.find_by(user_id: current_user.id, event_id: event.id)
    is_liked = liked_by_current_user ? true : false

    joined_by_current_user = EventAttendee.find_by(user_id: current_user.id, event_id: event.id)
    is_joined = joined_by_current_user ? true : false

    favourite = FavouriteEvent.find_by(user_id: current_user.id,event_id: event.id)
    is_favourite = favourite ? true : false

    followed = UserFollower.find_by(user_id: event.user_id, followed_by_id: current_user.id)
    is_followed = followed ? true : false 
   
    can_follow = current_user.id!= event.user_id

    like_count = LikeEvent.where(event_id: event.id).count
    {
      id: event.id,
      title: event.title,
      location: event.location,
      latitude: event.latitude,
      longitude: event.longitude,
      is_approved: event.is_approved,
      event_status: event.event_status,
      start_date: event.start_date,
      start_time: event.start_time.strftime('%H:%M'),
      end_date: event.end_date,
      end_time: event.end_time.strftime('%H:%M'),
      user_id: event.user_id,
      description: event.description,
      event_category_id: event.event_categories_id,
      event_category_name: category_name,
      hashtags: hashtags,
      # user_name: user.first_name + " " + user.last_name,
      image_url: event.image.present? ? url_for(event.image) : nil,
      # user_profile_image: profileimage,
      # follower_count: follower_count.present? ? follower_count : nil,
      # event_attendees_count: event_attendees_count.present? ? event_attendees_count : nil,
      is_liked: is_liked,
      # is_joined:  is_joined,
      is_favourite:  is_favourite,
      # is_followed: is_followed,
      like_count: like_count
      # can_follow: can_follow
     
    }
  end
end

       
  def create_or_find_hashtags(hashtag_names)
    hashtags = []
    hashtag_names.each do |name|
      hashtag = Hashtag.find_or_create_by(name: name) # Find or create the hashtag based on the name
      hashtags << hashtag
    end
    hashtags
  end
   
      
  
  def set_params
      params.permit(:title, :location, :latitude, :longitude, :start_date, :start_time, :end_date, :end_time, :description, :event_categories_id)
    end
  end
  