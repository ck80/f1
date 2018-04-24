class AddImgToRaces < ActiveRecord::Migration[5.1]
  def change
    add_column :races, :img, :string
  end
end
