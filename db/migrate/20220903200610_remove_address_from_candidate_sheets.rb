class RemoveAddressFromCandidateSheets < ActiveRecord::Migration[6.1]
  def up
    address_ids = CandidateSheet.all.map { |cs| cs.address_id }
    puts "address_ids: #{address_ids}"

    remove_index :candidate_sheets, :address_id
    remove_column :candidate_sheets, :address_id, type: :integer

    address_ids.each { |id| puts "REMOVING address id #{id}: exists: #{Address.find_by(id: id)}"}
    Address.delete(address_ids)
  end

  def down
    add_reference(:candidate_sheets, :address, references: :addresses, index: true)

    CandidateSheet.all.map do |cs|
      aaa = Address.create
      cs.address_id = aaa.id
      cs.save
    end
    CandidateSheet.all.map { |cs| "NEW address_id: #{cs.address_id}" }
  end
end
