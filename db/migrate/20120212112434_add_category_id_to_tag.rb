class AddCategoryIdToTag < ActiveRecord::Migration
  def change
    add_column :tags, :category_id, :integer
  end
end
