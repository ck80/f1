class AddUserRefToLeaderboards < ActiveRecord::Migration[5.1]
  def change
    add_reference :leaderboards, :user, foreign_key: true
  end
end
