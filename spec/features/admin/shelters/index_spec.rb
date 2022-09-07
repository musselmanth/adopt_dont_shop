require 'rails_helper'

RSpec.describe 'Admin Shelters Index Page', type: :feature do

  before(:each) do
    @shelter_1 = Shelter.create(name: 'Aurora shelter', city: 'Aurora, CO', foster_program: false, rank: 9)
    @shelter_2 = Shelter.create(name: 'RGV animal shelter', city: 'Harlingen, TX', foster_program: false, rank: 5)
    @shelter_3 = Shelter.create(name: 'Fancy pets of Colorado', city: 'Denver, CO', foster_program: true, rank: 10)

    @pet_1 = @shelter_1.pets.create(name: 'Mr. Pirate', breed: 'tuxedo shorthair', age: 5, adoptable: false)
    @pet_2 = @shelter_1.pets.create(name: 'Clawdia', breed: 'shorthair', age: 3, adoptable: true)
    @pet_3 = @shelter_3.pets.create(name: 'Lucille Bald', breed: 'sphynx', age: 8, adoptable: true)
    @pet_4 = @shelter_1.pets.create(name: 'Ann', breed: 'ragdoll', age: 5, adoptable: true)

    @john_doe_app = Application.create!(name: 'John Doe', street_address: '656 Main St.', city: 'Birmingham', state: 'AL', zip_code: 85267, description: "I've been a dog trainer for 40 years and I spend most of my days at home.", status: 'Pending')
    @jane_johnson_app = Application.create!(name: 'Jane Johnson', street_address: '2548 Bungalow Ave', city: 'Spokane', state: 'WA', zip_code: 27338, description: 'I like cats. Give me some.', status: 'Pending')
    
    @john_doe_app.pets << @pet_1
    @jane_johnson_app.pets << [@pet_2, @pet_3]
  end

  it 'has a title' do
    visit("/admin/shelters")

    expect(page).to have_content("Shelter Admin")
    expect(page).to have_content("Shelters:")
  end
  
  it 'lists all shelters in reverse alphabetical order' do
    visit("/admin/shelters")

    expect(@shelter_2.name).to appear_before(@shelter_3.name)
    expect(@shelter_3.name).to appear_before(@shelter_1.name)
  end

  it 'lists all shelters with pending Applications' do
    visit("/admin/shelters")
    expect(page).to have_content("Shelters with Pending Applications:\nAurora shelter\nFancy pets of Colorado")
  end

  it 'links to every shelter show page' do
    visit("/admin/shelters")
    click_on @shelter_1.name, match: :first

    expect(current_path).to eq("/admin/shelters/#{@shelter_1.id}")
  end
end