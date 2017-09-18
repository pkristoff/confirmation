class CandidatePDFDocument < Prawn::Document

  def initialize (candidate)
    super()
    @candidate = candidate
    do_document
  end

  def do_document

    page_size = 'LETTER'
    page_layout = :landscape
    candidate_sheet
    start_new_page
    baptismal_certificate
    start_new_page
    sponsor_covenant
    start_new_page
    outline.define do
      section(I18n.t('label.sidebar.candidate_information_sheet'), destination: 1)
      section(I18n.t('label.sidebar.baptismal_certificate'), destination: 2)
      section(I18n.t('label.sidebar.sponsor_covenant'), destination: 3)
    end

    page_number_string = 'page <page> of <total>'
    page_number_options = {:at => [bounds.right - 150, 0],
                           :width => 150,
                           :align => :right,
                           :page_filter => (1..7),
                           :start_count_at => 1,
                           :color => '007700'}
    number_pages page_number_string, page_number_options

  end

  def sponsor_covenant
    sc = @candidate.sponsor_covenant
    define_grid_page(2)

    grid_label_value([0, 0], "#{I18n.t('label.sponsor_covenant.sponsor_name')}:", sc.sponsor_name)
    grid_label_value([1, 0], "#{I18n.t('label.sponsor_covenant.sponsor_attends_stmm')}:", sc.sponsor_attends_stmm.to_s)

    unless sc.sponsor_attends_stmm
      grid_label_value([2, 0], "#{I18n.t('label.sponsor_covenant.sponsor_church')}:", sc.sponsor_church)
      common_image(sc.sponsor_covenant_filename, sc.sponsor_covenant_content_type, sc.sponsor_covenant_file_contents, I18n.t('field_set.sponsor_covenant.sponsor_covenant'), 200)
    end

    common_image(sc.sponsor_elegibility_filename, sc.sponsor_elegibility_content_type, sc.sponsor_elegibility_file_contents, I18n.t('field_set.sponsor_covenant.sponsor_eligibility'))
  end

  def candidate_sheet
    cs = @candidate.candidate_sheet
    define_grid_page

    #name
    grid_label_value([0, 0], "#{I18n.t('label.candidate_sheet.first_name')}:", cs.first_name)
    grid_label_value([0, 2], "#{I18n.t('label.candidate_sheet.last_name')}:", cs.last_name)

    #grade attending
    grid_label_value([1, 0], "#{I18n.t('label.candidate_sheet.grade')}:", cs.grade.to_s)
    grid_label_value([1, 2], "#{I18n.t('label.candidate_sheet.attending')}:", cs.attending)

    #email
    grid_label_value([2, 0], "#{I18n.t('label.candidate_sheet.candidate_email')}:", cs.candidate_email)
    grid_label_value([2, 2], "#{I18n.t('label.candidate_sheet.parent_email_1')}:", cs.parent_email_1)
    grid_label_value([3, 0], "#{I18n.t('label.candidate_sheet.parent_email_2')}:", cs.parent_email_2)

    #address
    grid_label([4, 0], "#{'Address'}")
    grid_address([5, 0], 'label.candidate_sheet.address', cs.address)

  end

  def baptismal_certificate
    bc = @candidate.baptismal_certificate
    if @candidate.baptized_at_stmm
      text 'Baptized at St. Mary Magdalene'
    else
      define_grid_page
      grid_label_value([0, 0], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.birth_date')}:", bc.birth_date.to_s)
      grid_label_value([0, 2], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.baptismal_date')}:", bc.baptismal_date.to_s)
      #Church
      grid_label_value([1, 1], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.church_name')}:", bc.church_name)
      grid_address([2, 0], 'label.baptismal_certificate.baptismal_certificate.church_address', bc.church_address)
      # father
      grid_label([5, 0], "#{'Father'}:")
      grid_label_value([6, 0], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.father_first')}:", bc.father_first)
      grid_label_value([7, 0], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.father_middle')}:", bc.father_middle)
      grid_label_value([8, 0], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.father_last')}:", bc.father_last)
      # mother
      grid_label([5, 2], "#{'Mother'}:")
      grid_label_value([6, 2], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.mother_first')}:", bc.mother_first)
      grid_label_value([7, 2], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.mother_middle')}:", bc.mother_middle)
      grid_label_value([8, 2], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.mother_maiden')}:", bc.mother_maiden)
      grid_label_value([9, 2], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.mother_last')}:", bc.mother_last)
      # grid.show_all
      # grid([0,0],[0,1]).show
      # grid([0,2],[0,3]).show
    end

    common_image(bc.certificate_filename, bc.certificate_content_type, bc.certificate_file_contents, I18n.t('field_set.baptismal_certificate.scan'))

  end

  def common_image (file_name, file_type, file_contents, label, offset=0)
    x=75+offset
    y=300
    bounding_box([x,y+20], :width => 150, :height => 20) do
      text label
    end
    if file_name.nil? or file_name.empty?
      bounding_box([x, y], :width => 150, :height => 250) do
        text '<No Image Provided>'
        stroke_bounds
      end
    else
      file_path = "tmp/#{file_name}"
      File.open(file_path, 'wb') do |f|
        f.write(file_contents)
      end
      begin
        # bc_bc = Prawn::Images::PNG.new(bc.certificate_file_contents)
        bounding_box([x, y], :width => 150, :height => 250) do
          stroke_bounds
          image file_path, width: 150, height: 250
        end
      rescue Prawn::Errors::UnsupportedImageType
        bounding_box([x, y], :width => 150, :height => 250) do
          stroke_bounds
          text "<Unrecognized file type: #{file_type} for file: #{file_name}>"
        end
      ensure
        File.delete(file_path) if File.exists?(file_path)
      end
    end

  end

  def grid_address(cell, label_base, address_association)
    grid_label_value([cell[0], 0], "#{I18n.t(label_base + '.street_1')}:", address_association.street_1)
    grid_label_value([cell[0], 2], "#{I18n.t(label_base + '.street_2')}:", address_association.street_2)
    grid_label_value([cell[0]+1, 0], "#{I18n.t(label_base + '.city')}:", address_association.city)
    grid_label_value([cell[0]+1, 2], "#{I18n.t(label_base + '.state')}:", address_association.state)
    grid_label_value([cell[0]+2, 0], "#{I18n.t(label_base + '.zip_code')}:", address_association.zip_code)
  end

  def grid_label_value(cell, label, value)
    grid_label(cell, label)
    grid_value([cell[0], cell[1]+1], value)

  end

  def grid_label (cell, label)
    grid(cell[0], cell[1]).bounding_box do
      # move_down 20
      font('Courier') {text "<b>#{label}</b>", inline_format: true}
    end
  end

  def grid_value (cell, value)
    val = (value.nil? or value.empty?) ? '<no value>' : value
    grid(cell[0], cell[1]).bounding_box do
      # move_down 20
      text val
    end
  end

  def define_grid_page(columns=4)
    define_grid(columns: columns, rows: 20)
  end

end