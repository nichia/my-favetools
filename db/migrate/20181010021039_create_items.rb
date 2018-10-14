class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.text :description
      t.string :url_link
      t.integer :rating, default: 0
      t.integer :folder_id

      t.timestamps null: false
    end
  end
end
