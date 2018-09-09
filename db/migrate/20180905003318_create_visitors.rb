class CreateVisitors < ActiveRecord::Migration[5.2]
  def self.up
    create_table :visitors do |t|
      t.text :home, default: '', null: false
      t.text :about, default: '', null: false
      t.text :contact, default: '', null: false

      t.timestamps
    end
    Visitor.create
  end

  def self.down
    drop_table :visitors
  end
end
