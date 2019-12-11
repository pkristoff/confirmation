class RenameUploadBaptismalCertificate < ActiveRecord::Migration
  def up
    ConfirmationEvent.all.each {|x| puts x.name}
    event = ConfirmationEvent.find_by(name: 'Upload Baptismal Certificate')
    event.name=BaptismalCertificate.event_name
    event.save
  end
  def down
    event = ConfirmationEvent.find_by(name: BaptismalCertificate.event_name)
    event.name='Upload Baptismal Certificate'
    event.save
  end
  def change
  end
end
