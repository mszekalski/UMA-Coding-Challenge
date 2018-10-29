require 'rails_helper'

RSpec.describe Doctor, type: :model do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should have_many(:appointments)}

  it 'fails to save an appointment in the past' do
    doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
    in_the_past = DateTime.now - 5.second
    appointment_in_the_past = doctor.create_appointment(in_the_past, 1)
    appointment_in_the_past.valid?
    expect(doctor.errors[:name]).to include("Can't schedule an appointment in the past")
  end

  it 'fails to make overlapping appointments' do
    doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
    appointment1 = doctor.create_appointment((DateTime.now + 1.hour), 3)
    appointment2 = doctor.create_appointment((appointment1.appointment_time + 2.hour), 1)
    appointment2.valid?
    expect(doctor.errors[:name]).to include("Appointment not available")
  end
end
