class Doctor < ApplicationRecord
  validates :first_name, :last_name, presence: true
  has_many :appointments

  def create_appointment(requested_start_time, duration)
    self.appointments.create({:appointment_time => requested_start_time, :duration => duration})
  end

  def delete_appointment(appointment_time)
    appointment = self.appointments.find_by(appointment_time: appointment_time)
    Appointment.destroy(appointment.id)
  end

  def available_appointments(date)

    appointments_for_date = self.appointments.where("appointment_time BETWEEN ? AND ?", date.beginning_of_day, date.end_of_day)

    if appointments_for_date.count == 0
      return ["9:00AM to 5:00PM"]
    end

    availability = []

    appointments_for_date.order("appointment_time ASC").each_with_index do |appointment, index|

      if index < appointments_for_date.length - 1
        next_appointment = appointments_for_date[index + 1]
      end

      if appointment.start_time >= appointment.day_of_at_ten && index == 0
        availability << "9:00AM to #{appointment.start_time_formated}"
      end

      if index < appointments_for_date.length - 1 && (appointment.end_time.to_time + 1.hours).to_datetime < next_appointment.start_time
        availability << "#{appointment.end_time_formated} to #{next_appointment.start_time_formated}"
      end

      if index == appointments_for_date.length - 1 && appointment.end_time <= appointment.day_of_at_four
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
