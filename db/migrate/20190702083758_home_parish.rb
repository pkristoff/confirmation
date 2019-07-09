class HomeParish < ActiveRecord::Migration[5.2]
  def change
    change_table :visitors do |t|
      t.string :home_parish
    end

    change_table :baptismal_certificates do |t|
      t.rename :first_comm_at_stmm, :first_comm_at_home_parish
      t.rename :baptized_at_stmm, :baptized_at_home_parish
    end

    change_table :sponsor_covenants do |t|
      t.rename :sponsor_attends_stmm, :sponsor_attends_home_parish
    end

    change_table :retreat_verifications do |t|
      t.rename :retreat_held_at_stmm, :retreat_held_at_home_parish
    end
  end
end
