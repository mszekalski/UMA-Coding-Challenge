class Appointment < ApplicationRecord
  validates :appointment_time, :duration, presence: true
  belongs_to :doctor
  validate :between_nine_and_five, :in_the_future?, :not_overlapped?, :not_on_weekend?
  validates_numericality_of :duration, :greater_than_or_equal_to => 1, :only_integer => true, :message => "Appointments must last atleast an hour and increase at one hour increments"

  def start_time
    self.appointment_time
  end

  def start_time_formated
    (self.appointment_time).strftime("%-l:%M%p")
  end

  def end_time
    (self.appointment_time.to_time + self.duration.hours).to_datetime
  end

  def end_time_formated
    (self.appointment_time.to_time + self.duration.hours).to_datetime.strftime("%-l:%M%p")
  end

  def day_of_at_nine
    self.appointment_time.change({hour: 9})
  end

  def day_of_at_five
    self.appointment_time.change({hour: 17})
  end

  def day_of_at_four
    self.appointment_time.change({hour: 16})
  end

  def day_of_at_ten
    self.appointment_time.change({hour: 10})
  end

private

  def not_overlapped?
    existing_appointments = self.doctor.appointments.where("appointment_time BETWEEN ? AND ?", self.appointment_time.beginning_of_day, self.appointment_time.end_of_day).order("appointment_time ASC")

    existing_appointments.each do |appointment|
      if (appointment.start_time <= self.start_time && self.start_time < appointment.end_time ||
        self.start_time <= appointment.start_time && appointment.start_time < self.end_time)
        self.errors.add(:appointment_time, "Appointment not available")
      end
    end
  end

  def in_the_future?
    if self.appointment_time < (DateTime.now - 5.second)
      self.errors.add(:appointment_time, "Can't schedule an appointment in the past")
    end
  end

  def not_on_weekend?
    if day_of_week == "Sunday" || day_of_week == "Saturday"
      self.errors.add(:appointment_time, "No appointments on the weekend")
    end
  end

  def between_nine_and_five

    if self.appointment_time < self.day_of_at_nine || self.appointment_time > self.day_of_at_four
      self.errors.add(:appointment_time, "Invalid start time")
    end

    if (self.end_time > self.day_of_at_five || self.appointment_time.to_date != self.end_time.to_date)
      self.errors.add(:appointment_time, "Invalid end time")
    end

  end

  def day_of_week
    self.appointment_time.strftime('%A')
  end

end
