class AddUpdatedByToTips < ActiveRecord::Migration[5.1]
  def change
    add_column :tips, :updated_by, :string
  end
end
