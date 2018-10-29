class Appointment < ApplicationRecord
  validates :appointment_time, :duration, presence: true
  belongs_to :doctor
  validate :between_nine_and_five, :is_a_date

  def is_a_date
    if (self.appointment_time.kind_of?(DateTime) == false)
      self.errors.add(:name, "Pick a valid date")
    end
  end



  def between_nine_and_five
    day_of_week = self.appointment_time.strftime('%A')
    hour = self.appointment_time.strftime('%k').to_i
    minute = self.appointment_time.strftime('%M')
    end_time = (self.appointment_time.to_time + self.duration.hours).to_datetime
    end_time_day_of_week = end_time.strftime('%A')


    if day_of_week === "Sunday" || day_of_week === "Saturday"

      self.errors.add(:name, "No appointments on the weekend")
    end

    if hour < 9 || hour > 17

      self.errors.add(:name, "Invalid start time")
    end

    if ((hour + self.duration) >= 17 || self.appointment_time.to_date != end_time.to_date || duration < 1)
    
      self.errors.add(:name, "Invalid end time")
    end




  end









end
