require 'RMagick'
include Magick

class CandidatePDFDocument < Prawn::Document

  def initialize (candidate)
    super()
    @candidate = candidate
    do_document
  end

  def do_document

    page_size = 'LETTER'
    page_layout = :landscape

    title_page
    start_new_page

    covenant_agreement
    start_new_page

    candidate_sheet
    start_new_page

    baptismal_certificate
    start_new_page

    sponsor_covenant
    start_new_page

    confirmation_name
    start_new_page

    sponsor_agreement
    start_new_page

    christian_ministry
    start_new_page

    retreat_verification
    start_new_page

    outline.define do
      section(I18n.t('label.sidebar.candidate_covenant_agreement'), destination: 1)
      section(I18n.t('label.sidebar.candidate_information_sheet'), destination: 2)
      section(I18n.t('label.sidebar.baptismal_certificate'), destination: 3)
      section(I18n.t('label.sidebar.sponsor_covenant'), destination: 4)
      section(I18n.t('label.sidebar.confirmation_name'), destination: 5)
      section(I18n.t('label.sidebar.sponsor_agreement'), destination: 6)
      section(I18n.t('label.sidebar.christian_ministry'), destination: 7)
      section(I18n.t('label.sidebar.retreat_verification'), destination: 8)
    end
    page_number_string = 'page <page> of <total>'
    page_number_options = {at: [bounds.right - 150, 0],
                           width: 150,
                           align: :right,
                           start_count_at: 1,
                           page_filter: lambda {|pg| pg > 1},
                           color: '007700'}
    number_pages page_number_string, page_number_options

  end

  def baptismal_certificate
    bc = @candidate.baptismal_certificate
    define_grid_page
    page_header(I18n.t('label.sidebar.baptismal_certificate'))

    if @candidate.baptized_at_stmm
      text 'Baptized at St. Mary Magdalene'
    else
      grid_label_value([1, 0], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.birth_date')}:", bc.birth_date.to_s)
      grid_label_value([1, 2], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.baptismal_date')}:", bc.baptismal_date.to_s)
      #Church
      grid_label_value([2, 1], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.church_name')}:", bc.church_name)
      grid_address([3, 0], 'label.baptismal_certificate.baptismal_certificate.church_address', bc.church_address)
      # father
      grid_label([6, 0], "#{'Father'}:")
      grid_label_value([7, 0], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.father_first')}:", bc.father_first)
      grid_label_value([8, 0], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.father_middle')}:", bc.father_middle)
      grid_label_value([9, 0], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.father_last')}:", bc.father_last)
      # mother
      grid_label([6, 2], "#{'Mother'}:")
      grid_label_value([7, 2], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.mother_first')}:", bc.mother_first)
      grid_label_value([8, 2], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.mother_middle')}:", bc.mother_middle)
      grid_label_value([9, 2], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.mother_maiden')}:", bc.mother_maiden)
      grid_label_value([10, 2], "#{I18n.t('label.baptismal_certificate.baptismal_certificate.mother_last')}:", bc.mother_last)
    end

    common_image(bc.scanned_certificate, I18n.t('field_set.baptismal_certificate.scan'))

  end

  def candidate_sheet
    cs = @candidate.candidate_sheet
    define_grid_page
    page_header(I18n.t('label.sidebar.candidate_information_sheet'))

    #name
    grid_label_value([1, 0], "#{I18n.t('label.candidate_sheet.first_name')}:", cs.first_name)
    grid_label_value([1, 2], "#{I18n.t('label.candidate_sheet.last_name')}:", cs.last_name)

    #grade attending
    grid_label_value([2, 0], "#{I18n.t('label.candidate_sheet.grade')}:", cs.grade.to_s)
    grid_label_value([2, 2], "#{I18n.t('label.candidate_sheet.attending')}:", cs.attending)

    #email
    grid_label_value([3, 0], "#{I18n.t('label.candidate_sheet.candidate_email')}:", cs.candidate_email)
    grid_label_value([3, 2], "#{I18n.t('label.candidate_sheet.parent_email_1')}:", cs.parent_email_1)
    grid_label_value([4, 0], "#{I18n.t('label.candidate_sheet.parent_email_2')}:", cs.parent_email_2)

    #address
    grid_label([5, 0], "#{'Address'}")
    grid_address([6, 0], 'label.candidate_sheet.address', cs.address)

  end

  def christian_ministry

    cm = @candidate.christian_ministry
    define_grid_page(2, 10)
    page_header(I18n.t('label.sidebar.christian_ministry'))

    grid_label_value([1, 0], "#{I18n.t('label.christian_ministry.what_service')}:", cm.what_service)
    grid_label_value([2, 0], "#{I18n.t('label.christian_ministry.where_service')}:", cm.where_service)
    grid_label_value([3, 0], "#{I18n.t('label.christian_ministry.when_service')}:", cm.when_service)
    grid_label_value([4, 0], "#{I18n.t('label.christian_ministry.helped_me')}:", cm.helped_me)
  end

  def confirmation_name

    cn = @candidate.pick_confirmation_name
    define_grid_page(2, 10)
    page_header(I18n.t('label.sidebar.confirmation_name'))

    grid_label_value([1, 0], I18n.t('label.confirmation_name.saint_name'), cn.saint_name)

  end

  def covenant_agreement
    signed = @candidate.signed_agreement
    define_grid_page(2, 10)
    page_header(I18n.t('label.sidebar.candidate_covenant_agreement'))

    grid_label_value([1, 0], 'Agreed to Candidate Covenant', signed)

  end

  def retreat_verification
    rv = @candidate.retreat_verification
    define_grid_page(4, 10)
    page_header(I18n.t('label.sidebar.retreat_verification'))

    grid_label_value([1, 0], "#{I18n.t('label.retreat_verification.retreat_held_at_stmm')}:", rv.retreat_held_at_stmm)

    unless rv.retreat_held_at_stmm

      grid_label_value([2, 0], "#{I18n.t('label.retreat_verification.start_date')}:", rv.start_date)
      grid_label_value([2, 2], "#{I18n.t('label.retreat_verification.end_date')}:", rv.end_date)

      grid_label_value([3, 0], "#{I18n.t('label.retreat_verification.who_held_retreat')}:", rv.who_held_retreat)
      grid_label_value([4, 0], "#{I18n.t('label.retreat_verification.where_held_retreat')}:", rv.where_held_retreat)

      common_image(rv.scanned_retreat, I18n.t('label.retreat_verification.retreat_verification_picture'))
    end

  end

  def sponsor_agreement
    sa = @candidate.sponsor_agreement
    define_grid_page(2, 10)
    page_header(I18n.t('label.sidebar.sponsor_agreement'))

    grid_label_value([1, 0], 'Agreed to having the conversation with sponsor', sa)

  end

  def sponsor_covenant
    sc = @candidate.sponsor_covenant
    define_grid_page(2)
    page_header(I18n.t('label.sidebar.sponsor_covenant'))

    grid_label_value([1, 0], "#{I18n.t('label.sponsor_covenant.sponsor_name')}:", sc.sponsor_name)
    grid_label_value([2, 0], "#{I18n.t('label.sponsor_covenant.sponsor_attends_stmm')}:", sc.sponsor_attends_stmm)

    unless sc.sponsor_attends_stmm
      grid_label_value([3, 0], "#{I18n.t('label.sponsor_covenant.sponsor_church')}:", sc.sponsor_church)
      common_image(sc.scanned_covenant, I18n.t('field_set.sponsor_covenant.sponsor_covenant'))
    end

    common_image(sc.scanned_eligibility, I18n.t('field_set.sponsor_covenant.sponsor_eligibility'))
  end

  def common_image (scanned_image, label)
    start_new_page
    label_x = bounds.left
    label_y = bounds.top
    label_width = bounds.width-20
    label_height = 20

    image_x = bounds.left
    image_y = bounds.top-25
    image_width = bounds.width-20
    image_height = bounds.height-20

    bounding_box([label_x, label_y], width: label_width, height: label_height) do
      text label, align: :center, valign: :center
    end
    if scanned_image.nil?
      bounding_box([image_x, image_y], width: image_width, height: bounds.height-25) do
        text '<No Image Provided>', align: :center, valign: :center
        # stroke_bounds
      end
    else
      Rails.logger.info("scanned_image.filename=#{scanned_image.filename}")
      Rails.logger.info("scanned_image.content_type=#{scanned_image.content_type}")
      # convert pdf to jpg which Prawn handles.
      if scanned_image.content_type === 'application/pdf'
        pdf_file_path = "tmp/#{scanned_image.filename}"
        jpg_file_path = pdf_file_path.gsub('.pdf', '.jpg')
        File.open(pdf_file_path, 'wb') do |f|
          f.write(scanned_image.content)
        end
        begin

          pdf = Magick::ImageList.new(pdf_file_path)

          pdf.each_with_index do |page_img, i|
            page_img.write jpg_file_path

            bounding_box([image_x, image_y], width: image_width, height: image_height) do
              # stroke_bounds
              image jpg_file_path, width: image_width, height: image_height
            end
          end
        ensure
          File.delete(pdf_file_path) if File.exists?(pdf_file_path)
          File.delete(jpg_file_path) if File.exists?(jpg_file_path)
        end
      else
        file_path = "tmp/#{scanned_image.filename}"
        File.open(file_path, 'wb') do |f|
          f.write(scanned_image.content)
        end
        begin
          # bc_bc = Prawn::Images::PNG.new(bc.certificate_file_contents)
          bounding_box([image_x, image_y], width: image_width, height: image_height) do
            # stroke_bounds
            image file_path, width: image_width, height: image_height
          end
        ensure
          File.delete(file_path) if File.exists?(file_path)
        end
      end
    end

  end

  def define_grid_page(columns=4, rows=20)
    define_grid(columns: columns, rows: rows)
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
    val = if (value.is_a? TrueClass) || (value.is_a? FalseClass) || (value.is_a? Date)
            value.to_s
          elsif value.nil? or value.empty?
            '<no value>'
          else
            value
          end
    grid(cell[0], cell[1]).bounding_box do
      # move_down 20
      text val
    end
  end

  def page_header(event_name)
    bounding_box [bounds.left, bounds.top], width: bounds.width do
      font 'Helvetica'
      text event_name, align: :center, size: 25
      stroke_horizontal_rule
    end
  end

  def title_page
    bounding_box [bounds.left, bounds.top], width: bounds.width, height: bounds.height do
      bounding_box [bounds.left, bounds.top], width: bounds.width, height: bounds.height/3 do
        text 'Confirmation booklet', size: 30, style: :bold, align: :center, valign: :bottom
      end
      bounding_box [bounds.left, bounds.top-(bounds.height/3)], width: bounds.width, height: bounds.height/3 do
        text 'for', size: 30, style: :bold, align: :center, valign: :center
      end
      bounding_box [bounds.left, bounds.top-((bounds.height*2)/3)], width: bounds.width, height: bounds.height/3 do
        text "#{@candidate.candidate_sheet.first_name} #{@candidate.candidate_sheet.last_name}", size: 30, style: :bold, align: :center, valign: :top
      end
    end
  end
end