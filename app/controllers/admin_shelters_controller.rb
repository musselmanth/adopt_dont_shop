class AdminSheltersController < ApplicationController

  def show
    @shelter = Shelter.find(params[:id])
    @action_needed_pets = @shelter.action_needed_pets
    @address = @shelter.find_address
  end

  def index
    @shelters = Shelter.order_by_reverse_alphabetical
    @pending_shelters = Shelter.pending_apps_shelters
  end
  
end