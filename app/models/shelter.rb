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

  def find_city
    Shelter.find_by_sql("SELECT city FROM shelters WHERE id = #{self.id}").first.city
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
end
