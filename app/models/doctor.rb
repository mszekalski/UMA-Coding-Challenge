class Doctor < ApplicationRecord
  validates :first_name, :last_name, presence: true
  has_many :appointments

  def create_appointment(appointment_time, duration)
    if appointment_time < (DateTime.now - 5.second)
      self.errors.add(:name, "Can't schedule an appointment in the past")
    end
    self.appointments.each do |appointment|
      end_time_current = (appointment.appointment_time.to_time + appointment.duration.hours).to_datetime
      start_time_current = appointment.appointment_time
      end_time_coming_in = (appointment_time.to_time + duration.hours).to_datetime
      start_time_coming_in = appointment_time
      if (start_time_current <= start_time_coming_in && start_time_coming_in <= end_time_current ||
        start_time_coming_in <= start_time_current && start_time_current <= end_time_coming_in)
        
        self.errors.add(:name, "Appointment not available")
      end
    end


    appointment = self.appointments.create({:appointment_time => appointment_time, :duration => duration})

  end

  def delete_appointment(appointment_time)
    appointment = self.appointments.find_by(appointment_time: appointment_time)
    appointment.destroy
  end

  def available_appointments(date)


    availability = []
    appointments = self.appointments.select { |appointment|  appointment.appointment_time.strftime("%Y-%m-%d") == date.strftime("%Y-%m-%d") }
    sorted = appointments.sort_by(&:appointment_time)
    sorted.each_with_index do |appointment, index|
      start_hour = appointment.appointment_time.strftime('%k').to_i
      start_time_formated = appointment.appointment_time.strftime("%l:%M")
      end_time = (appointment.appointment_time.to_time + appointment.duration.hours).to_datetime
      end_hour = (appointment.appointment_time.to_time + appointment.duration.hours).to_datetime.strftime('%k').to_i
      end_time_formated = (appointment.appointment_time.to_time + appointment.duration.hours).to_datetime.strftime("%l:%M%p")

      if index < appointments.length - 1
        next_start_time = sorted[index + 1].appointment_time
        next_start_time_formated = next_start_time.strftime("%l:%M%p")
      end

      if  start_hour >= 10 && index == 0
        availability << "9AM to #{start_time}"
      end

      if index < appointments.length - 1 && (end_time.to_time + 1.hours).to_datetime < next_start_time
        availability << "#{end_time_formated} to #{next_start_time_formated}"
      end
      debugger
      if index == sorted.length - 1 && end_hour <= 16
        availability << "#{end_time_formated} to 5:00PM"
      end

    end
    return availability
  end





end
