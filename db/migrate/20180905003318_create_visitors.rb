class CreateVisitors < ActiveRecord::Migration[5.2]
  def change
    create_table :visitors do |t|
      t.text :home
      t.text :about
      t.text :contact

      t.timestamps
    end
  end
end
