class Appointment < ApplicationRecord
  validates :appointment_time, :duration, presence: true
  belongs_to :doctor
  validate :between_nine_and_five
  validates_numericality_of :duration, :greater_than_or_equal_to => 1, :only_integer => true, :message => "Appointments must last atleast an hour and increase at one hour increments"

  def start_time
    self.appointment_time
  end

  def start_time_formated
    (self.appointment_time).strftime("%-l:%M%p")
  end

  def start_hour
    self.appointment_time.strftime('%k').to_i
  end

  def end_time
    (self.appointment_time.to_time + self.duration.hours).to_datetime
  end

  def end_hour
    (self.appointment_time.to_time + self.duration.hours).to_datetime.strftime('%k').to_i
  end

  def end_time_formated
    (self.appointment_time.to_time + self.duration.hours).to_datetime.strftime("%-l:%M%p")
  end

  def between_nine_and_five
    day_of_week = self.appointment_time.strftime('%A')
    day_of_at_nine = self.appointment_time.change({hour: 9})
    day_of_at_five = self.appointment_time.change({hour: 17})
    day_of_at_four = self.appointment_time.change({hour: 16})
    minute = self.appointment_time.strftime('%M')
    end_time = (self.appointment_time.to_time + self.duration.hours).to_datetime
    end_time_day_of_week = end_time.strftime('%A')

    if day_of_week === "Sunday" || day_of_week === "Saturday"
      self.errors.add(:name, "No appointments on the weekend")
    end

    if self.appointment_time < day_of_at_nine || self.appointment_time > day_of_at_four
      self.errors.add(:name, "Invalid start time")
    end

    if (end_time > day_of_at_five || self.appointment_time.to_date != end_time.to_date)
      self.errors.add(:name, "Invalid end time")
    end

  end

end
