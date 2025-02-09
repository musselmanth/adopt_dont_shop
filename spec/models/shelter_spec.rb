require 'rails_helper'

RSpec.describe Shelter, type: :model do
  describe 'relationships' do
    it { should have_many(:pets) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:rank) }
    it { should validate_numericality_of(:rank) }
  end

  before(:each) do
    @shelter_1 = Shelter.create!(name: 'Aurora shelter', city: 'Aurora', foster_program: false, state: "CO", street_address: "1234 Street Ave", zip_code: 32145, rank: 9)
    @shelter_2 = Shelter.create(name: 'RGV animal shelter', city: 'Harlingen', foster_program: false, state: "TX", street_address: "1234 Street Blvd", zip_code: 32145, rank: 5)
    @shelter_3 = Shelter.create(name: 'Fancy pets of Colorado', city: 'Denver', foster_program: true, state: "CO", street_address: "1234 Street Alley", zip_code: 32145, rank: 10)

    @pet_1 = @shelter_1.pets.create(name: 'Mr. Pirate', breed: 'tuxedo shorthair', age: 5, adoptable: false)
    @pet_2 = @shelter_1.pets.create(name: 'Clawdia', breed: 'shorthair', age: 3, adoptable: true)
    @pet_3 = @shelter_3.pets.create(name: 'Lucille Bald', breed: 'sphynx', age: 8, adoptable: true)
    @pet_4 = @shelter_1.pets.create(name: 'Ann', breed: 'ragdoll', age: 5, adoptable: true)

    @john_doe_app = Application.create!(name: 'John Doe', street_address: '656 Main St.', city: 'Birmingham', state: 'AL', zip_code: 85267, description: "I've been a dog trainer for 40 years and I spend most of my days at home.", status: 'Pending')
    @jane_johnson_app = Application.create!(name: 'Jane Johnson', street_address: '2548 Bungalow Ave', city: 'Spokane', state: 'WA', zip_code: 27338, description: 'I like cats. Give me some.', status: 'Pending')
    
    @john_doe_app.pets << @pet_1
    @jane_johnson_app.pets << [@pet_2, @pet_3]
  end

  describe 'class methods' do
    describe '#search' do
      it 'returns partial matches' do
        expect(Shelter.search("Fancy")).to eq([@shelter_3])
      end
    end

    describe '#order_by_recently_created' do
      it 'returns shelters with the most recently created first' do
        expect(Shelter.order_by_recently_created).to eq([@shelter_3, @shelter_2, @shelter_1])
      end
    end

    describe '#order_by_number_of_pets' do
      it 'orders the shelters by number of pets they have, descending' do
        expect(Shelter.order_by_number_of_pets).to eq([@shelter_1, @shelter_3, @shelter_2])
      end
    end

    describe '#order_by_reverse_alphabetical' do
      it 'orders the shelters in reverse alphabetical order' do
        expect(Shelter.order_by_reverse_alphabetical).to eq([@shelter_2, @shelter_3, @shelter_1])
      end
    end

    describe '#city(id)' do
      it 'returns city of given record' do
        expect(@shelter_1.find_address).to eq("1234 Street Ave, Aurora CO, 32145")
      end
    end

    describe '#pending_app_shelters' do
      it 'returns list of shelters with pending applications alphabetically by name' do
        expect(Shelter.pending_apps_shelters).to eq([@shelter_1, @shelter_3])
      end
    end
  end

  describe 'instance methods' do
    describe '.adoptable_pets' do
      it 'only returns pets that are adoptable' do
        expect(@shelter_1.adoptable_pets).to eq([@pet_2, @pet_4])
      end
    end

    describe '.alphabetical_pets' do
      it 'returns pets associated with the given shelter in alphabetical name order' do
        expect(@shelter_1.alphabetical_pets).to eq([@pet_4, @pet_2])
      end
    end

    describe '.shelter_pets_filtered_by_age' do
      it 'filters the shelter pets based on given params' do
        expect(@shelter_1.shelter_pets_filtered_by_age(5)).to eq([@pet_4])
      end
    end

    describe '.pet_count' do
      it 'returns the number of pets at the given shelter' do
        expect(@shelter_1.pet_count).to eq(3)
      end
    end

    describe '.action_needed_pets' do
      it 'returns a list of pets that have a pending application' do
        expect(@shelter_1.action_needed_pets).to eq([@pet_1, @pet_2])
        expect(@shelter_3.action_needed_pets).to eq([@pet_3])
      end
    end

    describe '.has_pending_apps' do
      it 'returns true if shelter has pending apps' do
        expect(@shelter_1.has_pending_apps).to eq true
        expect(@shelter_2.has_pending_apps).to eq false
      end
    end

    describe '.adopted_pets_count' do
      it 'returns the count of pets that have been adopted' do
        expect(@shelter_1.adopted_pets_count).to eq 0

        @john_doe_app.application_pets.first.update(status: 'approved')
        @john_doe_app.update_status

        expect(@shelter_1.adopted_pets_count).to eq 1

        @jane_johnson_app.application_pets.each do |app_pet|
          app_pet.update(status: 'approved')
        end
        @jane_johnson_app.update_status

        expect(@shelter_1.adopted_pets_count).to eq 2
      end
    end

    describe '.adoptable_pets_count' do
      it 'returns the number of adoptable pets at the shelter' do
        expect(@shelter_1.adoptable_pets_count).to eq 2
        expect(@shelter_3.adoptable_pets_count).to eq 1
      end
    end

    describe '.average_pet_age' do
      it 'returns the value of average pet age for the shelter' do
        expect(@shelter_1.average_pet_age).to eq(4.33)
        expect(@shelter_3.average_pet_age).to eq(8.00)
      end
    end
  end
end
