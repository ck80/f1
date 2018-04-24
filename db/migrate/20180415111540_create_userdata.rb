class CreateUserdata < ActiveRecord::Migration[5.1]
  def change
    create_table :userdata do |t|
      t.string :user_id
      t.string :season
      t.integer :fee_paid

      t.timestamps
    end
  end
end
