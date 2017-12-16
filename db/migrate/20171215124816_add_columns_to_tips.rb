class AddColumnsToTips < ActiveRecord::Migration[5.1]
  def change
    add_column :tips, :qual_first_points, :integer
    add_column :tips, :qual_second_points, :integer
    add_column :tips, :qual_third_points, :integer
    add_column :tips, :race_first_points, :integer
    add_column :tips, :race_second_points, :integer
    add_column :tips, :race_third_points, :integer
    add_column :tips, :race_tenth_points, :integer
    add_column :tips, :race_total_points, :integer
  end
end
