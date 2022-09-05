require 'rails_helper'

RSpec.describe Application, type: :model do
    describe "relationships" do
        
        it { should have_many :application_pets }
        it { should have_many(:pets).through(:application_pets) }

        it { should validate_presence_of(:name) }
        it { should validate_presence_of(:city) }
        it { should validate_presence_of(:street_address) }
        it { should validate_presence_of(:state) }
        it { should validate_presence_of(:zip_code) }

        before(:each) do
            @shelter1 = Shelter.create!(foster_program: "true", name:"Furry Friends", city: "Denver", rank:"3")
            @cookie = @shelter1.pets.create!(adoptable: "true", name: "Cookie", breed:"chihuahua", age:"5")
            @spot = @shelter1.pets.create!(adoptable: "true", name: "Spot", breed:"dalmation", age:"2")
            @dash = @shelter1.pets.create!(adoptable: "false", name: "Dash", breed:"golden retriever", age:"13")

            @john_doe_app = Application.create!(name: 'John Doe', street_address: '656 Main St.', city: 'Birmingham', state: 'AL', zip_code: 85267, description: "I've been a dog trainer for 40 years and I spend most of my days at home.", status: 'Pending')
            @john_doe_app.pets << [@cookie, @spot]
        end

        describe 'instance methods' do
            describe '.app_pets_and_pets' do
                it 'can return the app pet object with the pets information included' do
                    expect(@john_doe_app.app_pets_and_pets[0].name).to eq("Cookie")
                    expect(@john_doe_app.app_pets_and_pets[0]).to respond_to(:status)
                    expect(@john_doe_app.app_pets_and_pets[1].name).to eq("Spot")
                    expect(@john_doe_app.app_pets_and_pets[1]).to respond_to(:status)
                end
            end
            describe '.update status' do
                it 'will not update the status if only one of the pets is approved' do
                    @john_doe_app.application_pets.first.update(status: 'approved')
                    @john_doe_app.update_status
                    expect(@john_doe_app.status).to eq('Pending')
                end
                it 'will update the status to approved if all the pets are approved' do
                    @john_doe_app.application_pets.each do |app_pet|
                        app_pet.update(status: 'approved')
                    end
                    @john_doe_app.update_status

                    expect(@john_doe_app.status).to eq('Approved')
                end
                it 'will update the status to rejected if any of the pets are rejected' do
                    @john_doe_app.application_pets.first.update(status: 'rejected')
                    @john_doe_app.update_status

                    expect(@john_doe_app.status).to eq('Rejected')
                end
            end
        end
    end
end