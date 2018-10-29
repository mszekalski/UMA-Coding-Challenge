require 'rails_helper'

RSpec.describe Appointment, type: :model do
  # it { should validate_presence_of(:appointment_time) }
  # it { should validate_presence_of(:duration)}
  it { should belong_to(:doctor)}
end
