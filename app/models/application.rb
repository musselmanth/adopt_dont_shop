class Application < ApplicationRecord
    has_many :application_pets
    has_many :pets, through: :application_pets

    validates :name, 
              :street_address,
              :city, 
              :state,
              :zip_code,
              presence: true

    def app_pets_and_pets
      application_pets.select('application_pets.*, pets.name').joins(:pet)
    end

    def update_status
      if application_pets.any?{ |app_pet| app_pet.status == 'rejected' }
        update(status: "Rejected")
      elsif application_pets.all?{ |app_pet| app_pet.status == 'approved'}
        update(status: "Approved")
      end
    end

end