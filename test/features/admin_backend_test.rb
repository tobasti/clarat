require_relative '../test_helper'
include Warden::Test::Helpers

feature 'Admin Backend' do
  let(:admin) { FactoryGirl.create :researcher }
  let(:superuser) { FactoryGirl.create :super }

  describe 'as researcher' do
    before { login_as admin }

    scenario 'Administrating Offers' do
      visit rails_admin_path

      click_link 'Angebote', match: :first
      click_link 'Neu hinzufügen'

      assert_difference 'Offer.count', 1 do
        fill_in 'offer_name', with: 'testangebot'
        fill_in 'offer_description', with: 'testdescription'
        fill_in 'offer_next_steps', with: 'testnextsteps'
        select 'Fixed', from: 'offer_encounter'
        select 'foobar', from: 'offer_organization_ids'

        click_button 'Speichern'
        page.must_have_content 'testangebot'
      end
    end

    scenario 'Administrating Organizations' do
      visit rails_admin_path

      click_link 'Organisationen', match: :first
      click_link 'Neu hinzufügen'

      assert_difference 'Organization.count', 1 do
        fill_in 'organization_name', with: 'testorganisation'
        fill_in 'organization_description', with: 'testdescription'
        select 'e.V.', from: 'organization_legal_form'

        click_button 'Speichern'
        page.must_have_content 'testorganisation'
        page.must_have_content '✘'
        page.must_have_content admin.email
      end
    end

    scenario 'Try to create offer with a organization/location mismatch' do
      location = FactoryGirl.create(:location, name: 'testname')

      visit rails_admin_path

      click_link 'Angebote', match: :first
      click_link 'Neu hinzufügen'

      fill_in 'offer_name', with: 'testangebot'
      fill_in 'offer_description', with: 'testdescription'
      fill_in 'offer_next_steps', with: 'testnextsteps'
      select 'Fixed', from: 'offer_encounter'
      select location.name, from: 'offer_location_id'
      select 'foobar', from: 'offer_organization_ids'

      click_button 'Speichern und bearbeiten'

      check 'offer_completed'
      click_button 'Speichern' # update to trigger validation

      page.must_have_content 'Angebot wurde nicht aktualisiert'
      page.must_have_content 'Location muss zu der unten angegebenen Organisation gehören.'
      page.must_have_content 'Organizations muss die des angegebenen Standorts beinhalten.'
    end

    scenario 'Mark offer as completed' do
      visit rails_admin_path

      click_link 'Angebote', match: :first
      click_link 'Bearbeiten'

      check 'offer_completed'

      click_button 'Speichern'

      page.must_have_content '✓'
    end

    # calls partial dup that doesn't end up in an immediately valid offer
    scenario 'Duplicate offer' do
      visit rails_admin_path

      click_link 'Angebote', match: :first
      click_link 'Duplizieren'

      click_button 'Speichern'

      page.must_have_content 'Angebot wurde nicht hinzugefügt'
    end

    scenario 'View statistics should not work' do
      visit rails_admin_path

      click_link 'Angebote', match: :first
      page.wont_have_link 'Statistiken'
    end
  end

  describe 'as super' do
    before { login_as superuser }

    scenario 'View statistics' do
      admin # create one for stats
      visit rails_admin_path

      click_link 'Angebote', match: :first
      click_link 'Statistiken'
      click_link 'Weekly by user'
      click_link 'Cumulative by user'

      page.must_have_content 'Created'
      page.must_have_content 'Approved'
    end
  end
end
