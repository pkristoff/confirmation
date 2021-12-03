class AddAddressToVisitors < ActiveRecord::Migration[5.2]
  def change
    add_reference(:visitors, :home_parish_address, references: :addresses, index: true)
    visitors = Visitor.all
    if visitors.size == 1
      visitor = visitors.first
      puts "adding address to visitor.home_parish#{visitor.home_parish}"
      visitor.build_home_parish_address
      visitor.save!
    end
  end
end
