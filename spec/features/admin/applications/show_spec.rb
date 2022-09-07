require 'rails_helper'

RSpec.describe 'Admin Applications Show Page', type: :feature do
  before(:each) do
    @shelter1 = Shelter.create!(foster_program: "true", name:"Furry Friends", city: "Denver", rank:"3")
    @cookie = @shelter1.pets.create!(adoptable: "true", name: "Cookie", breed:"chihuahua", age:"5")
    @spot = @shelter1.pets.create!(adoptable: "true", name: "Spot", breed:"dalmation", age:"2")
    @dash = @shelter1.pets.create!(adoptable: "false", name: "dash", breed:"golden retriever", age:"13")

    @john_doe_app = Application.create!(
      name: 'John Doe', 
      street_address: '656 Main St.', 
      city: 'Birmingham', 
      state: 'AL', 
      zip_code: 85267, 
      description: "I've been a dog trainer for 40 years and I spend most of my days at home.", 
      status: 'Pending'
    )

    @roberta_benson_app = Application.create!(
      name: 'Roberta Benson', 
      street_address: '700 W 18th Ave Apt 101', 
      city: 'Bend', 
      state: 'OR', 
      zip_code: 84585, 
      description: 'I am very responsible and need animal friends because I have no human friends.', 
      status: 'Pending'
    )

    @john_doe_app.pets << @cookie
    @john_doe_app.pets << @spot

    @roberta_benson_app.pets << @cookie
  end

  it 'has a button to approve each pet on the application' do
    visit("/admin/applications/#{@john_doe_app.id}")

    expect(page).to have_content("Cookie")
    expect(page).to have_button("Approve")
    expect(page).to have_content("Spot")

    within("div#cookie") do
      click_button("Approve")
    end

    expect(current_path).to eq("/admin/applications/#{@john_doe_app.id}")
    expect(page).to have_content("The application for Cookie has been approved.")
    expect(page).to_not have_content("The application for Spot has been approved.")

    within("div#spot") do
      click_button("Approve")
    end

    expect(current_path).to eq("/admin/applications/#{@john_doe_app.id}")
    expect(page).to have_content("The application for Cookie has been approved.")
    expect(page).to have_content("The application for Spot has been approved.")
  end

  it 'has a button to reject each pet on the application' do
    visit("/admin/applications/#{@john_doe_app.id}")

    expect(page).to have_button("Reject")
    
    within("div#cookie") do
      click_button("Reject")
    end
    expect(current_path).to eq("/admin/applications/#{@john_doe_app.id}")
    expect(page).to have_content("The application for Cookie has been rejected.")
    expect(page).to_not have_content("The application for Spot has been rejected.")

    within("div#spot") do
      click_button("Reject")
    end
    expect(current_path).to eq("/admin/applications/#{@john_doe_app.id}")
    expect(page).to have_content("The application for Cookie has been rejected.")
    expect(page).to have_content("The application for Spot has been rejected.")
  end

  it 'doesnt allow a pet to be rejected after its been approved' do
    visit("/admin/applications/#{@john_doe_app.id}")
    within("div#cookie") do
      click_button("Approve")
    end

    within("div#spot") do
      click_button("Approve")
    end

    expect(page).to_not have_button("Reject")
  end

  it 'doesnt allow a pet to be approved after its been rejected' do
    visit("/admin/applications/#{@john_doe_app.id}")
    within("div#cookie") do
      click_button("Reject")
    end

    within("div#spot") do
      click_button("Reject")
    end

    expect(page).to_not have_button("Approve")
  end

  describe 'only approve one app for a pet' do
    it 'doesnt allow a pet to be approved if it has been approved on another application' do
      visit("/admin/applications/#{@john_doe_app.id}")
      within("div#cookie") do
        click_button("Approve")
      end
      within("div#spot") do
        click_button("Approve")
      end
  
      visit("/admin/applications/#{@roberta_benson_app.id}")
      within("div#cookie") do
        expect(page).to_not have_button("Approve")
        expect(page).to have_content("This pet has been approved for adoption on another application.")
      end
    end
  
    it 'works in multiple cases' do
      visit("/admin/applications/#{@roberta_benson_app.id}")
      within("div#cookie") do
        click_button("Approve")
      end
  
      visit("/admin/applications/#{@john_doe_app.id}")
      within("div#cookie") do
        expect(page).to_not have_button("Approve")
        expect(page).to have_content("This pet has been approved for adoption on another application.")
      end
    end

    it 'updates the status of the application when the status of a pet is changed' do
      visit("/admin/applications/#{@john_doe_app.id}")
      within("div#cookie") do
        click_button("Approve")
      end

      expect(page).to have_content("Application Status: Pending")

      within("div#spot") do
        click_button("Approve")
      end

      expect(page).to have_content("Application Status: Approved")
    end

    it 'update the status to rejected if any of the pets are rejected' do
      visit("/admin/applications/#{@john_doe_app.id}")
      within("div#cookie") do
        click_button("Reject")
      end

      expect(page).to have_content("Application Status: Pending")

      within("div#spot") do
        click_button("Approve")
      end

      expect(page).to have_content("Application Status: Rejected")
    end

    it 'update the status to rejected if all pets are rejected' do
      visit("/admin/applications/#{@john_doe_app.id}")
      within("div#cookie") do
        click_button("Reject")
      end
      within("div#spot") do
        click_button("Reject")
      end

      expect(page).to have_content("Application Status: Rejected")
    end
  end

  describe 'application approval makes pet not adoptable' do
    it 'changes adoptable to false once an application has been approved' do
      visit("/admin/applications/#{@john_doe_app.id}")
      within("div#cookie") do
        click_button("Approve")
      end
      within("div#spot") do
        click_button("Approve")
      end
      expect(@cookie.reload.adoptable).to be false
      expect(@spot.reload.adoptable).to be false
    end
  end


end