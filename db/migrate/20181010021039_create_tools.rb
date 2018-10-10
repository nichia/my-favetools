class CreateTools < ActiveRecord::Migration
  def change
    create_table :tools do |t|
      t.string :name
      t.text :description
      t.string :link_url
      t.integer :rating, default: 0
      t.integer :folder_id

      t.timestamps null: false
    end
  end
end
