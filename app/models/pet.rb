class Pet < ApplicationRecord
  validates :name, presence: true
  validates :age, presence: true, numericality: true
  belongs_to :shelter
  has_many :application_pets, dependent: :delete_all
  has_many :applications, through: :application_pets

  def shelter_name
    shelter.name
  end

  def self.adoptable
    where(adoptable: true)
  end

  def pending_apps
    applications.where(status: 'Pending')
  end

  def adopted?
    # application_pets.any?{ |app_pet| app_pet.status == "approved" }
    app_pet_and_app_status.any?{ |app_pet| app_pet.status = "approved" && app_pet.app_status == "Approved"}
  end

  def app_pet_and_app_status
    application_pets.select('application_pets.*, applications.status AS app_status').joins(:application)
  end
  
end
