require 'spec_helper'

describe 'displays correct state of editing of entries of index' do
  let!(:formatted_entry) { FactoryBot.build(:formatted_entry) }
  let!(:unprocessed_entry) { FactoryBot.build(:unprocessed_entry) }
  let(:admin) { FactoryBot.create(:admin) }

  before do
    login_as_user(admin)
  end
  describe 'admin visits entries#index' do
    context 'when unprocessed' do
      it 'entries are labeled accordingly' do
        unprocessed_entry.save
        visit entries_path
        expect(page).to have_content('unbearbeitet')
        expect(page).not_to have_content('unformatiert')
        expect(page).not_to have_content('formatiert')
      end
    end
    context 'when formatted' do
      it 'entries are labeled accordingly' do
        formatted_entry.save
        visit entries_path
        expect(page).not_to have_content('unbearbeitet')
      end
    end
  end
end
