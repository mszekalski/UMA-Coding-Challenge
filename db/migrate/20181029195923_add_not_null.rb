class AddNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column :appointments, :appointment_time, :datetime, null: false
    change_column :appointments, :duration, :integer, null: false
    change_column :doctors, :first_name, :string, null: false
    change_column :doctors, :last_name, :string, null: false
  end
end
