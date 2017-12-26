require 'spec_helper'

describe 'rake email_notification', type: :task do
  let(:aufgabe) { FactoryBot.build(:task) }

  describe 'general' do
    it 'preloads the Rails environment' do
      expect(task.prerequisites).to include 'environment'
    end

    it 'runs gracefully' do
      expect { task.execute }.not_to raise_error
    end
  end

  describe 'email notification' do
    context 'when db holds expired task' do
      it 'sends an email notification' do
        aufgabe.update(assigned_to_date: Date.yesterday)
        task.execute
        expect(ActionMailer::Base.deliveries.last.subject).to eq('Eine von Dir deligierte Aufgabe wurde nicht erledigt')
      end
    end
    context 'when db does not hold an expired task' do
      it 'does not send an email notification' do
        aufgabe.save
        expect { task.execute }.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end
  end
end
