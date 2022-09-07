class Shelter < ApplicationRecord
  validates :name, presence: true
  validates :rank, presence: true, numericality: true
  validates :city, presence: true

  has_many :pets, dependent: :destroy

  def self.order_by_recently_created
    order(created_at: :desc)
  end

  def self.order_by_number_of_pets
    select("shelters.*, count(pets.id) AS pets_count")
      .joins("LEFT OUTER JOIN pets ON pets.shelter_id = shelters.id")
      .group("shelters.id")
      .order("pets_count DESC")
  end

  def self.order_by_reverse_alphabetical
    find_by_sql("SELECT * FROM shelters ORDER BY name DESC")
  end

  def find_address
    shelter = Shelter.find_by_sql("SELECT * FROM shelters WHERE id = #{self.id}").first
    "#{shelter.street_address}, #{shelter.city} #{shelter.state}, #{shelter.zip_code}"
  end

  def self.pending_apps_shelters
    Shelter.all.find_all {|shelter| shelter.has_pending_apps}
  end

  def has_pending_apps
    self.pets.any? {|pet| !pet.pending_apps.empty?}
  end

  def pet_count
    pets.count
  end

  def adoptable_pets
    pets.where(adoptable: true)
  end

  def alphabetical_pets
    adoptable_pets.order(name: :asc)
  end

  def shelter_pets_filtered_by_age(age_filter)
    adoptable_pets.where('age >= ?', age_filter)
  end

  def action_needed_pets
    pets.find_all{ |pet| !pet.pending_apps.empty? }
  end

  def adoptable_pets_count
    adoptable_pets.count
  end

  def adopted_pets_count
    pets.count{ |pet| pet.adopted? }
  end

  def average_pet_age
    pets.average(:age).round(2)
  end
end
