class RoomsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :find_room, only: [:show, :edit, :update]

  def index
    @rooms = current_user.rooms
  end

  def show
    @photos = @room.photos
    @booked = Reservation.where('room_id = ? AND user_id = ?', @room.id, current_user.id).present? if current_user
    @reviews = @room.reviews
    @has_review = @reviews.find_by(user_id: current_user.id) if current_user
  end

  def new
    @room = current_user.rooms.build
  end

  def create
    @room = current_user.rooms.build(room_params)

    if @room.save
      if params[:images]
        params[:images].each do |image|
          @room.photos.create(image: image)
        end
      end

      @photos = @room.photos
      redirect_to edit_room_path(@room), notice: 'Saved!'
    else
      flash[:alert] = "Please fill out all required fields!"
      render :new
    end
  end

  def edit
    if current_user.id == @room.user.id
      @photos = @room.photos
    else
      redirect_to root_path, notice: 'You don\'t have permission to do that. Sorry!'
    end
  end

  def update
    if @room.update(room_params)

      if params[:images]
        params[:images].each do |image|
          @room.photos.create(image: image)
        end
      end

      redirect_to edit_room_path(@room), notice: 'Updated!'
    else
      render :edit
    end
  end

  private

  def find_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:home_type, :room_type, :accommodate, 
                                 :bed_room, :bath_room, :listing_name, 
                                 :summary, :address, :is_tv, :is_kitchen,
                                 :is_air, :is_heating, :is_internet,
                                 :price, :active)
  end
end
