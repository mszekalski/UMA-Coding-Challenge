class Appointment < ApplicationRecord
  validates :appointment_time, :duration, presence: true
  belongs_to :doctor
  validate :between_nine_and_five



  def between_nine_and_five
    day_of_week = self.appointment_time.strftime('%A')
    hour = self.appointment_time.strftime('%k').to_i
    minute = self.appointment_time.strftime('%M')
    end_time = (self.appointment_time.to_time + self.duration.hours).to_datetime
    end_time_day_of_week = end_time.strftime('%A')
    # start_time_with_year = self.appointment_time.strftime("%Y-%m-%d")
    # end_time_with_year = end_time.strftime("%Y-%m-%d")
    debugger
    if day_of_week === "Sunday" || day_of_week === "Saturday"
      puts "No appointments on the weekend"
      # self.errors.add(:appointment_time, “ cannot be on the weekend.”)
    end

    if hour < 9 || hour > 17
      puts "Invalid start time"
      # self.errors.add(:appointment_time, “ has an invalid start time.”)
    end

    if ((hour + self.duration) >= 17 || self.appointment_time.to_date != end_time.to_date || duration < 1)
      puts "Invalid end time"
      # self.errors.add(:appointment_time, “ has an invalid end time.”)
    end




  end









end
