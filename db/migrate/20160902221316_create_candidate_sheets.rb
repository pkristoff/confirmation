class CreateCandidateSheets < ActiveRecord::Migration
  def change
    create_table :candidate_sheets do |t|
      t.string   "first_name",                              default: "",        null: false
      t.string   "last_name",                               default: "",        null: false
      t.decimal  "grade",                     precision: 2, default: 10,        null: false
      t.string   "candidate_email",                         default: "",        null: false
      t.string   "parent_email_1",                          default: "",        null: false
      t.string   "parent_email_2",                          default: "",        null: false
      t.string   "attending",                               default: "The Way", null: false

      t.timestamps null: false
    end

    add_reference(:candidates, :candidate_sheet, index: true)
    add_foreign_key(:candidates, :candidate_sheets)

    add_reference(:candidate_sheets, :address, references: :addresses, index: true)

    remove_column(:candidates, :first_name, :string)
    remove_column(:candidates, :last_name, :string)
    remove_column(:candidates, :grade, :string)
    remove_column(:candidates, :candidate_email, :string)
    remove_column(:candidates, :parent_email_1, :string)
    remove_column(:candidates, :parent_email_2, :string)
    remove_column(:candidates, :attending, :string)

    remove_index(:candidates, column: :address_id)
    remove_foreign_key(:candidates, :addresses)
    remove_reference(:candidates, :address)
  end
end
