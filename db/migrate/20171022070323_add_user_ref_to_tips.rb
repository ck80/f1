class AddUserRefToTips < ActiveRecord::Migration[5.1]
  def change
    add_reference :tips, :user, foreign_key: true
  end
end
