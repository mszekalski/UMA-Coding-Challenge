class Doctor < ApplicationRecord
  validates :first_name, :last_name, presence: true
  has_many :appointments

  def create_appointment(appointment_time, duration)

    if appointment_time < (DateTime.now - 5.second)
      self.errors.add(:name, "Can't schedule an appointment in the past")
    end

    self.appointments.each do |appointment|
      requested_end_time = (appointment_time.to_time + duration.hours).to_datetime
      requested_start_time = appointment_time
      if (appointment.start_time <= requested_start_time && requested_start_time <= appointment.end_time ||
        requested_start_time <= appointment.start_time && appointment.start_time <= requested_end_time)
        self.errors.add(:name, "Appointment not available")
      end
    end

    appointment = self.appointments.create({:appointment_time => appointment_time, :duration => duration})

  end

  def delete_appointment(appointment_time)
    appointment = self.appointments.find_by(appointment_time: appointment_time)
    Appointment.destroy(appointment.id)
  end

  def available_appointments(date)

    availability = []
    appointments = self.appointments.select { |appointment|  appointment.appointment_time.strftime("%Y-%m-%d") == date.strftime("%Y-%m-%d") }
    sorted = appointments.sort_by(&:appointment_time)

    sorted.each_with_index do |appointment, index|

      if index < appointments.length - 1
        next_appointment = sorted[index + 1]
      end

      if appointment.start_hour >= 10 && index == 0
        availability << "9:00AM to #{appointment.start_time_formated}"
      end

      if index < appointments.length - 1 && (appointment.end_time.to_time + 1.hours).to_datetime < next_appointment.start_time
        availability << "#{appointment.end_time_formated} to #{next_appointment.start_time_formated}"
      end

      if index == sorted.length - 1 && appointment.end_hour <= 16 && appointment.start_hour != 17
        availability << "#{appointment.end_time_formated} to 5:00PM"
      end

    end

    if availability.length > 0
      return availability
    else
      return "No availbility for that date"
    end

  end

end
