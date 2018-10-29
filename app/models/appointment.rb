class Appointment < ApplicationRecord
  validates :appointment_time, :duration, presence: true
  belongs_to :doctor
  validate :between_nine_and_five, :is_a_date
  validates_numericality_of :duration, :greater_than_or_equal_to => 1, :only_integer => true, :message => "Appointments must last atleast an hour and increase at one hour increments"

  def is_a_date
    if (self.appointment_time.kind_of?(DateTime) == false)
      self.errors.add(:name, "Pick a valid date")
    end
  end



  def between_nine_and_five
    day_of_week = self.appointment_time.strftime('%A')
    day_of_at_nine = self.appointment_time.change({hour: 9})
    day_of_at_five = self.appointment_time.change({hour: 17})
    day_of_at_six = self.appointment_time.change({hour: 18})

    minute = self.appointment_time.strftime('%M')
    end_time = (self.appointment_time.to_time + self.duration.hours).to_datetime
    end_time_day_of_week = end_time.strftime('%A')


    if day_of_week === "Sunday" || day_of_week === "Saturday"

      self.errors.add(:name, "No appointments on the weekend")
    end

    if self.appointment_time < day_of_at_nine || self.appointment_time > day_of_at_five

      self.errors.add(:name, "Invalid start time")
    end

    if (end_time > day_of_at_six || self.appointment_time.to_date != end_time.to_date)
      self.errors.add(:name, "Invalid end time")
    end




  end









end
