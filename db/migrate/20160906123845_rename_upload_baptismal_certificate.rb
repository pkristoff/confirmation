class RenameUploadBaptismalCertificate < ActiveRecord::Migration
  def up
    ConfirmationEvent.all.each {|x| puts x.name}
    event = ConfirmationEvent.find_by_name('Upload Baptismal Certificate')
    event.name='Baptismal Certificate'
    event.save
  end
  def down
    event = ConfirmationEvent.find_by_name('Baptismal Certificate')
    event.name='Upload Baptismal Certificate'
    event.save
  end
  def change
  end
end
