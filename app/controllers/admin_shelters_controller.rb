class AdminSheltersController < ApplicationController

  def show
    @shelter = Shelter.find(params[:id])
    @action_needed_pets = @shelter.action_needed_pets
    @city = @shelter.find_city
  end

  def index
    @shelters = Shelter.order_by_reverse_alphabetical
    @pending_shelters = Shelter.pending_apps_shelters
  end
  
end