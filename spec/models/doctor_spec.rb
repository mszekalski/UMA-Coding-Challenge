require 'rails_helper'

RSpec.describe Doctor, type: :model do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should have_many(:appointments)}

  it 'fails to create an appointment with a duration less than 1' do
    doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
    date1 = DateTime.parse('31st Oct 2018 9:00:00')
    appointment1 = doctor.create_appointment(date1, -1)
    appointment1.valid?
    expect(appointment1.errors.messages[:duration]).to include("Appointments must last atleast an hour and increase at one hour increments")
  end

  it "fails to create an appointment with a duration that isn't an integer" do
    doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
    date1 = DateTime.parse('31st Oct 2018 9:00:00')
    appointment1 = doctor.create_appointment(date1, 2.5)
    appointment1.valid?
    expect(appointment1.errors.messages[:duration]).to include("Appointments must last atleast an hour and increase at one hour increments")
  end

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

  it 'does save appointments that are back to back' do
    doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
    date1 = DateTime.parse('31st Oct 2018 12:00:00')
    date2 = DateTime.parse('31st Oct 2018 13:00:00')
    appointment1 = doctor.create_appointment(date1, 1)
    appointment2 = doctor.create_appointment(date2, 1)
    appointment2.valid?
    appointment1.valid?
    expect(appointment1).to be_valid
    expect(appointment2).to be_valid
  end

  it "won't make an appointment on a Saturday" do
    doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
    date = DateTime.parse('3rd Nov 2018 09:00:00')
    appointment1 = doctor.create_appointment(date, 3)
    appointment1.valid?
    expect(appointment1.errors[:name]).to include("No appointments on the weekend")
  end

  it "won't make an appointment on a Sunday" do
    doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
    date = DateTime.parse('4th Nov 2018 09:00:00')
    appointment1 = doctor.create_appointment(date, 3)
    appointment1.valid?
    expect(appointment1.errors[:name]).to include("No appointments on the weekend")
  end

  it "won't make an appointment that starts before 9AM" do
    doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
    date1 = DateTime.parse('31st Oct 2018 08:59:00')
    date2 = DateTime.parse('31st Oct 2018 09:00:00')
    appointment1 = doctor.create_appointment(date1, 3)
    appointment2 = doctor.create_appointment(date2, 3)
    appointment1.valid?
    expect(appointment1.errors[:name]).to include("Invalid start time")
    appointment2.valid?
    expect(appointment2.errors[:name]).not_to include("Invalid start time")
  end

  it "won't make an appointment that starts after 5PM" do
    doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
    date1 = DateTime.parse('31st Oct 2018 17:01:00')
    date2 = DateTime.parse('31st Oct 2018 17:00:00')
    appointment1 = doctor.create_appointment(date1, 1)
    appointment2 = doctor.create_appointment(date2, 1)
    appointment1.valid?
    expect(appointment1.errors[:name]).to include("Invalid start time")
    appointment2.valid?
    expect(appointment2.errors[:name]).not_to include("Invalid start time")
  end

  it "won't make an appointment that ends after 6PM" do
    doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
    date1 = DateTime.parse('31st Oct 2018 17:01:00')
    date2 = DateTime.parse('31st Oct 2018 17:00:00')
    appointment1 = doctor.create_appointment(date1, 1)
    appointment2 = doctor.create_appointment(date2, 1)
    appointment1.valid?
    expect(appointment1.errors[:name]).to include("Invalid end time")
    appointment2.valid?
    expect(appointment2.errors[:name]).not_to include("Invalid end time")
  end

  it "won't make an appointment that lasts into the next day" do
    doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
    date1 = DateTime.parse('31st Oct 2018 12:00:00')
    appointment1 = doctor.create_appointment(date1, 24)
    appointment1.valid?
    expect(appointment1.errors[:name]).to include("Invalid end time")
  end

  it "deletes appointments" do
    doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
    date1 = DateTime.parse('31st Oct 2018 12:00:00')
    appointment1 = doctor.create_appointment(date1, 1)
    doctor.delete_appointment(appointment1.appointment_time)
    expect { appointment1.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
