class SponsorCovenantValidator < ActiveModel::Validator
  def initialize(sponsor_covenant)
    @sponsor_covenant = sponsor_covenant
  end

  def validate
    @sponsor_covenant.validates_presence_of [:sponsor_name]
    unless @sponsor_covenant.sponsor_attends_stmm
      @sponsor_covenant.validates_presence_of [:sponsor_church, :sponsor_elegibility_filename, :sponsor_elegibility_content_type, :sponsor_elegibility_file_contents]
    end
  end
end

class SponsorCovenant < ActiveRecord::Base

  attr_accessor :sponsor_elegibility_picture

  def validate_self
    SponsorCovenantValidator.new(self).validate
  end

end