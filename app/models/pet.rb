class Pet < ApplicationRecord
  validates :name, presence: true
  validates :age, presence: true, numericality: true
  belongs_to :shelter
  has_many :application_pets
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

  def any_approved_applications?
    application_pets.any?{ |app_pet| app_pet.status == "approved" }
  end
  
end
