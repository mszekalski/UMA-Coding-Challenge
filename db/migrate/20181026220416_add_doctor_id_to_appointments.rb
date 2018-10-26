class AddDoctorIdToAppointments < ActiveRecord::Migration[5.2]
  def change
    add_column :appointments, :doctor_id, :integer
  end
end
