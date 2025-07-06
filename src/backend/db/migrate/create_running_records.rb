class CreateRunningRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :running_records do |t|
      t.decimal :distance, precision: 5, scale: 2 # (in Km) 
      t.time    :start_time                       # ...
      t.time    :end_time                         # ...
      t.integer :duration                         # seconds in [start_time..end_time]
      t.integer :pace                             # (duration / distance)
      t.date    :date                             # ...
      t.string  :location                         # ...

      t.timestamps
    end
  end
end