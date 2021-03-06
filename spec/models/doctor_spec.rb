require 'rails_helper'

RSpec.describe Doctor, type: :model do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should have_many(:appointments)}

  describe "#create_appointment" do
    it 'fails to create an appointment with a duration less than 1' do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date1 = DateTime.parse('31st Oct 2019 9:00:00')
      appointment1 = doctor.create_appointment(date1, -1)
      expect(appointment1.persisted?).to eq(false)
      expect(appointment1.errors.messages[:duration]).to include("Appointments must last atleast an hour and increase at one hour increments")
    end

    it "fails to create an appointment with a duration that isn't an integer" do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date1 = DateTime.parse('31st Oct 2019 9:00:00')
      appointment1 = doctor.create_appointment(date1, 2.5)
      expect(appointment1.persisted?).to eq(false)
      expect(appointment1.errors.messages[:duration]).to include("Appointments must last atleast an hour and increase at one hour increments")
    end

    it 'fails to save an appointment in the past' do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      in_the_past = DateTime.now - 5.second
      appointment_in_the_past = doctor.create_appointment(in_the_past, 1)
      expect(appointment_in_the_past.persisted?).to eq(false)
      expect(appointment_in_the_past.errors[:appointment_time]).to include("Can't schedule an appointment in the past")
    end

    it 'fails to make overlapping appointments' do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date1 = DateTime.parse('31st Oct 2019 12:00:00')
      date2 = DateTime.parse('31st Oct 2019 13:00:00')
      appointment1 = doctor.create_appointment(date1, 3)
      appointment2 = doctor.create_appointment(date2, 1)
      expect(appointment1.persisted?).to eq(true)
      expect(appointment2.persisted?).to eq(false)
      expect(appointment2.errors[:appointment_time]).to include("Appointment not available")
    end

    it 'does save appointments that are back to back' do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date1 = DateTime.parse('31st Oct 2019 12:00:00')
      date2 = DateTime.parse('31st Oct 2019 13:00:00')
      appointment1 = doctor.create_appointment(date1, 1)
      appointment2 = doctor.create_appointment(date2, 1)
      expect(appointment1.persisted?).to eq(true)
      expect(appointment2.persisted?).to eq(true)
    end

    it "won't make an appointment on a Saturday" do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date = DateTime.parse('2nd Nov 2019 09:00:00')
      appointment1 = doctor.create_appointment(date, 3)
      expect(appointment1.persisted?).to eq(false)
      expect(appointment1.errors[:appointment_time]).to include("No appointments on the weekend")
    end

    it "won't make an appointment on a Sunday" do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date = DateTime.parse('3rd Nov 2019 09:00:00')
      appointment1 = doctor.create_appointment(date, 3)
      expect(appointment1.persisted?).to eq(false)
      expect(appointment1.errors[:appointment_time]).to include("No appointments on the weekend")
    end

    it "won't make an appointment that starts before 9AM" do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date1 = DateTime.parse('31st Oct 2019 08:59:00')
      date2 = DateTime.parse('31st Oct 2019 09:00:00')
      appointment1 = doctor.create_appointment(date1, 3)
      appointment2 = doctor.create_appointment(date2, 3)
      expect(appointment2.persisted?).to eq(true)
      expect(appointment1.persisted?).to eq(false)
      expect(appointment1.errors[:appointment_time]).to include("Invalid start time")
    end

    it "won't make an appointment that starts after 4PM" do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date1 = DateTime.parse('31st Oct 2019 16:01:00')
      date2 = DateTime.parse('31st Oct 2019 16:00:00')
      appointment1 = doctor.create_appointment(date1, 1)
      appointment2 = doctor.create_appointment(date2, 1)
      expect(appointment1.persisted?).to eq(false)
      expect(appointment2.persisted?).to eq(true)
      expect(appointment1.errors[:appointment_time]).to include("Invalid start time")
    end

    it "won't make an appointment that ends after 5PM" do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date1 = DateTime.parse('31st Oct 2019 16:01:00')
      date2 = DateTime.parse('31st Oct 2019 16:00:00')
      appointment1 = doctor.create_appointment(date1, 1)
      appointment2 = doctor.create_appointment(date2, 1)
      expect(appointment1.persisted?).to eq(false)
      expect(appointment1.errors[:appointment_time]).to include("Invalid end time")
      expect(appointment2.persisted?).to eq(true)
      expect(appointment2.errors[:appointment_time]).not_to include("Invalid end time")
    end

    it "won't make an appointment that lasts into the next day" do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date1 = DateTime.parse('31st Oct 2019 12:00:00')
      appointment1 = doctor.create_appointment(date1, 24)
      expect(appointment1.persisted?).to eq(false)
      expect(appointment1.errors[:appointment_time]).to include("Invalid end time")
    end
  end

  describe "#delete_appointment" do
    it "deletes appointments" do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date1 = DateTime.parse('31st Oct 2019 12:00:00')
      appointment1 = doctor.create_appointment(date1, 1)
      expect(appointment1.persisted?).to eq(true)
      doctor.delete_appointment(appointment1.appointment_time)
      expect { appointment1.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "#available_appointments" do
    it "returns availbility when the doctor has a 9AM appointment" do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date1 = DateTime.parse('31st Oct 2019 9:00:00')
      appointment1 = doctor.create_appointment(date1, 1)
      expect(appointment1.persisted?).to eq(true)
      expect(doctor.available_appointments(date1)).to eq(["10:00AM to 5:00PM"])
    end

    it "returns availbility when the doctor has an appointment that lasts until 5PM" do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date1 = DateTime.parse('31st Oct 2019 14:00:00')
      appointment1 = doctor.create_appointment(date1, 3)
      expect(appointment1.persisted?).to eq(true)
      expect(doctor.available_appointments(date1)).to eq(["9:00AM to 2:00PM"])
    end

    it "returns availbility when the doctor has multiple appointments during the day" do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date1 = DateTime.parse('31st Oct 2019 9:00:00')
      date2 = DateTime.parse('31st Oct 2019 12:00:00')
      date3 = DateTime.parse('31st Oct 2019 14:00:00')
      appointment1 = doctor.create_appointment(date1, 1)
      appointment2 = doctor.create_appointment(date2, 1)
      appointment3 = doctor.create_appointment(date3, 1)
      expect(appointment1.persisted?).to eq(true)
      expect(appointment2.persisted?).to eq(true)
      expect(appointment3.persisted?).to eq(true)
      expect(doctor.available_appointments(date1)).to eq(["10:00AM to 12:00PM", "3:00PM to 5:00PM"])
    end

    it "returns availbility when the doctor has back to back appointments" do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date1 = DateTime.parse('31st Oct 2019 9:00:00')
      date2 = DateTime.parse('31st Oct 2019 10:00:00')
      appointment1 = doctor.create_appointment(date1, 1)
      appointment2 = doctor.create_appointment(date2, 1)
      expect(appointment1.persisted?).to eq(true)
      expect(appointment2.persisted?).to eq(true)
      expect(doctor.available_appointments(date1)).to eq(["11:00AM to 5:00PM"])
    end

    it "returns no availbility when doctor is fully booked" do
      doctor = Doctor.create(first_name: "Matthew", last_name: "Szekalski")
      date1 = DateTime.parse('31st Oct 2019 9:00:00')
      appointment1 = doctor.create_appointment(date1, 3)
      date2 = DateTime.parse('31st Oct 2019 12:00:00')
      appointment2 = doctor.create_appointment(date2, 5)
      expect(appointment1.persisted?).to eq(true)
      expect(appointment2.persisted?).to eq(true)
      expect(doctor.available_appointments(date1)).to eq("No availbility for that date")
    end
  end
end
