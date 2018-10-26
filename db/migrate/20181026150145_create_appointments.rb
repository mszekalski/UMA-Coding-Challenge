class CreateAppointments < ActiveRecord::Migration[5.2]
  def change
    create_table :appointments do |t|
      t.datetime :appointment_time
      t.integer :duration
      t.timestamps
    end
  end
end
