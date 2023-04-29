# frozen_string_literal: true

require 'rmagick'

#
# Generate PDF for candidate info
#
# === Parameters:
#
# * <tt>:candidate</tt> Candidate
#
class CandidatePDFDocument < Prawn::Document
  include Magick
  # Name to save the pdf document
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> Candidate
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def self.document_name(candidate)
    "2023-2024 #{candidate.candidate_sheet.last_name} #{candidate.candidate_sheet.first_name}.pdf"
  end

  # Instantiation
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> number of columns
  #
  def initialize(candidate)
    super()
    @candidate = candidate
    @verified = false
    do_document
  end

  # Name to save the pdf document
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def document_name
    CandidatePDFDocument.document_name(@candidate)
  end

  # walk through the events making sure they have all been validated
  #
  def process_events
    event = @candidate.candidate_events.select { |ev| ev.completed_date.nil? || !ev.verified? }
    @verified = event.empty?
  end

  # Generate PDF document
  #
  def do_document
    process_events
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

    sponsor_eligibility
    start_new_page

    confirmation_name
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
      section(I18n.t('label.sidebar.christian_ministry'), destination: 7)
      section(I18n.t('label.sidebar.retreat_verification'), destination: 8)
    end
    page_number_string = 'page <page> of <total>'
    page_number_options = { at: [bounds.right - 150, 0],
                            width: 150,
                            align: :right,
                            start_count_at: 1,
                            page_filter: ->(pg) { pg > 1 },
                            color: '007700' }
    number_pages page_number_string, page_number_options
  end

  # Generate Baptismal Certificate
  #
  def baptismal_certificate
    bc = @candidate.baptismal_certificate
    define_grid_page
    page_header(I18n.t('label.sidebar.baptismal_certificate'), [0, 0], [0, 3])
    common_event(@candidate.get_candidate_event(BaptismalCertificate.event_key), [1, 0], [1, 3])
    if bc.chosen_baptized_at_home_parish?
      grid_label_value2([2, 0], I18n.t('activerecord.attributes.baptismal_certificate.baptized_at_home_parish',
                                       home_parish: Visitor.home_parish),
                        bc.baptized_at_home_parish)
      grid_label_value([4, 0], "#{I18n.t('activerecord.attributes.baptismal_certificate.birth_date')}:", bc.birth_date.to_s)
      grid_label_value([4, 2], "#{I18n.t('activerecord.attributes.baptismal_certificate.baptismal_date')}:",
                       bc.baptismal_date.to_s)
      # father
      grid_label([5, 0], [5, 0], "#{I18n.t('field_set.baptismal_certificate.father')}:")
      grid_label_value([6, 0], "#{I18n.t('activerecord.attributes.baptismal_certificate.father_first')}:", bc.father_first)
      grid_label_value([7, 0], "#{I18n.t('activerecord.attributes.baptismal_certificate.father_middle')}:", bc.father_middle)
      grid_label_value([8, 0], "#{I18n.t('activerecord.attributes.baptismal_certificate.father_last')}:", bc.father_last)
      # mother
      grid_label([5, 2], [5, 2], "#{I18n.t('field_set.baptismal_certificate.mother')}:")
      grid_label_value([6, 2], "#{I18n.t('activerecord.attributes.baptismal_certificate.mother_first')}:", bc.mother_first)
      grid_label_value([7, 2], "#{I18n.t('activerecord.attributes.baptismal_certificate.mother_middle')}:", bc.mother_middle)
      grid_label_value([8, 2], "#{I18n.t('activerecord.attributes.baptismal_certificate.mother_maiden')}:", bc.mother_maiden)
      grid_label_value([9, 2], "#{I18n.t('activerecord.attributes.baptismal_certificate.mother_last')}:", bc.mother_last)

      common_image(bc.scanned_certificate, I18n.t('field_set.baptismal_certificate.scan'))

      if bc.chosen_baptized_catholic?
        start_new_page
        grid_label_value2([2, 0], I18n.t('activerecord.attributes.baptismal_certificate.baptized_catholic'),
                          bc.baptized_catholic)
        # baptised catholic
        if bc.info_show_baptized_catholic
          grid_label_value([5, 1], "#{I18n.t('activerecord.attributes.baptismal_certificate.church_name')}:", bc.church_name)
          grid_address([6, 0], 'activerecord.attributes.baptismal_certificate.church_address/address', bc.church_address, false)
        end
        # profession of faith
        return unless bc.info_show_profession_of_faith

        grid_label([3, 0], [3, 3], 'Profession of Faith')
        grid_label_value([5, 0], "#{I18n.t('activerecord.attributes.baptismal_certificate.prof_date')}:", bc.prof_date)
        grid_label_value([6, 1], "#{I18n.t('activerecord.attributes.baptismal_certificate.prof_church_name')}:",
                         bc.prof_church_name)
        grid_address([7, 0], 'activerecord.attributes.baptismal_certificate.prof_church_address/address',
                     bc.prof_church_address, true)

        common_image(bc.scanned_certificate, I18n.t('field_set.baptismal_certificate.prof_scan'))
      else
        grid_label([2, 0], [2, 2], 'Baptised Catholic not chosen') unless bc.baptized_at_home_parish
      end
    else
      grid_label([2, 0], [2, 2], "Baptised at #{Visitor.home_parish} not chosen")
    end
  end

  # Generate Candidate sheet
  #
  def candidate_sheet
    cs = @candidate.candidate_sheet
    define_grid_page
    page_header(I18n.t('label.sidebar.candidate_information_sheet'), [0, 0], [0, 3])
    common_event(@candidate.get_candidate_event(CandidateSheet.event_key), [1, 0], [1, 3])

    # name
    grid_label_value([2, 0], "#{I18n.t('activerecord.attributes.candidate_sheet.first_name')}:", cs.first_name)
    grid_label_value([2, 2], "#{I18n.t('activerecord.attributes.candidate_sheet.middle_name')}:", cs.middle_name)
    grid_label_value([3, 0], "#{I18n.t('activerecord.attributes.candidate_sheet.last_name')}:", cs.last_name)

    # grade attending
    grid_label_value([4, 0], "#{I18n.t('activerecord.attributes.candidate_sheet.grade')}:", cs.grade.to_s)
    grid_label_value([4, 2], "#{I18n.t('activerecord.attributes.candidate_sheet.program_year')}:", cs.program_year.to_s)
    grid_label_value([5, 0], "#{I18n.t('activerecord.attributes.candidate_sheet.attending')}:", cs.attending)

    # email
    grid_label_value([6, 0], "#{I18n.t('activerecord.attributes.candidate_sheet.candidate_email')}:", cs.candidate_email)
    grid_label_value([6, 2], "#{I18n.t('activerecord.attributes.candidate_sheet.parent_email_1')}:", cs.parent_email_1)
    grid_label_value([7, 0], "#{I18n.t('activerecord.attributes.candidate_sheet.parent_email_2')}:", cs.parent_email_2)
  end

  # Generate Christian Ministry
  #
  def christian_ministry
    cm = @candidate.christian_ministry
    define_grid_page
    page_header(I18n.t('label.sidebar.christian_ministry'), [0, 0], [0, 3])
    common_event(@candidate.get_candidate_event(ChristianMinistry.event_key), [1, 0], [1, 3])

    grid_label_value2([2, 0], "#{I18n.t('activerecord.attributes.christian_ministry.what_service')}:", cm.what_service)
    grid_label_value2([3, 0], "#{I18n.t('activerecord.attributes.christian_ministry.where_service')}:", cm.where_service)
    grid_label_value2([4, 0], "#{I18n.t('activerecord.attributes.christian_ministry.when_service')}:", cm.when_service)
    grid_label_value2([5, 0], "#{I18n.t('activerecord.attributes.christian_ministry.helped_me')}:", cm.helped_me)
  end

  # Generate confirmation name
  #
  def confirmation_name
    cn = @candidate.pick_confirmation_name
    define_grid_page
    page_header(I18n.t('label.sidebar.confirmation_name'), [0, 0], [0, 3])
    common_event(@candidate.get_candidate_event(PickConfirmationName.event_key), [1, 0], [1, 3])

    grid_label_value2([2, 0], I18n.t('activerecord.attributes.pick_confirmation_name.saint_name'), cn.saint_name)
  end

  # Generate Covenant agreement
  #
  def covenant_agreement
    signed = @candidate.signed_agreement
    define_grid_page
    page_header(I18n.t('label.sidebar.candidate_covenant_agreement'), [0, 0], [0, 3])
    common_event(@candidate.get_candidate_event(Candidate.covenant_agreement_event_key), [1, 0], [1, 3])

    grid_label_value2([2, 0], 'Agreed to Candidate Covenant', signed)
  end

  # Generate retreat verification
  #
  def retreat_verification
    rv = @candidate.retreat_verification
    define_grid_page
    page_header(I18n.t('label.sidebar.retreat_verification'), [0, 0], [0, 3])
    common_event(@candidate.get_candidate_event(RetreatVerification.event_key), [1, 0], [1, 3])

    label_message = I18n.t('activerecord.attributes.retreat_verification.retreat_held_at_home_parish',
                           home_parish: Visitor.home_parish)
    grid_label_value2([2, 0], "#{label_message}:", rv.retreat_held_at_home_parish)

    return if rv.retreat_held_at_home_parish

    grid_label_value2([3, 0], "#{I18n.t('activerecord.attributes.retreat_verification.start_date')}:", rv.start_date)
    grid_label_value2([4, 0], "#{I18n.t('activerecord.attributes.retreat_verification.end_date')}:", rv.end_date)

    grid_label_value2([5, 0], "#{I18n.t('activerecord.attributes.retreat_verification.who_held_retreat')}:", rv.who_held_retreat)
    grid_label_value2([6, 0], "#{I18n.t('activerecord.attributes.retreat_verification.where_held_retreat')}:",
                      rv.where_held_retreat)

    common_image(rv.scanned_retreat, I18n.t('activerecord.attributes.retreat_verification.retreat_verification_picture'))
  end

  # Generate Sponsor covenant
  #
  def sponsor_covenant
    sc = @candidate.sponsor_covenant
    define_grid_page
    page_header(I18n.t('label.sidebar.sponsor_covenant'), [0, 0], [0, 3])
    common_event(@candidate.get_candidate_event(SponsorCovenant.event_key), [1, 0], [1, 3])

    grid_label_value2([2, 0], "#{I18n.t('activerecord.attributes.sponsor_covenant.sponsor_name')}:", sc.sponsor_name)

    common_image(sc.scanned_covenant, I18n.t('field_set.sponsor_covenant'))
  end

  # Generate Sponsor covenant
  #
  def sponsor_eligibility
    se = @candidate.sponsor_eligibility
    define_grid_page
    page_header(I18n.t('label.sidebar.sponsor_eligibility'), [0, 0], [0, 3])
    common_event(@candidate.get_candidate_event(SponsorEligibility.event_key), [1, 0], [1, 3])

    label_message = I18n.t('activerecord.attributes.sponsor_eligibility.sponsor_attends_home_parish',
                           home_parish: Visitor.home_parish)
    grid_label_value2([3, 0], "#{label_message}:", se.sponsor_attends_home_parish)

    return if se.sponsor_attends_home_parish

    grid_label_value([4, 0], "#{I18n.t('activerecord.attributes.sponsor_eligibility.sponsor_church')}:", se.sponsor_church)
    common_image(se.scanned_image, I18n.t('activerecord.attributes.sponsor_eligibility.sponsor_eligibility_picture'))
  end

  # Generate image
  #
  # === Parameters:
  #
  # * <tt>:scanned_image</tt> scanned image
  # * <tt>:label</tt> label
  #
  def common_image(scanned_image, label)
    start_new_page
    label_x = bounds.left
    label_y = bounds.top
    label_width = bounds.width - 20
    label_height = 20

    image_x = bounds.left
    image_y = bounds.top - 25
    image_width = bounds.width - 20
    image_height = bounds.height - 20

    bounding_box([label_x, label_y], width: label_width, height: label_height) do
      text label, align: :center, valign: :center
    end
    if scanned_image.nil?
      bounding_box([image_x, image_y], width: image_width, height: bounds.height - 25) do
        text '<No Image Provided>', align: :center, valign: :center
        # stroke_bounds
      end
      # convert pdf to jpg which Prawn handles.
    elsif scanned_image.content_type == 'application/pdf'
      FileUtils.mkdir_p('tmp')
      pdf_file_path = "tmp/#{scanned_image.filename}".downcase
      jpg_file_path = pdf_file_path.gsub('.pdf', '.jpg')
      File.binwrite(pdf_file_path, scanned_image.content)
      begin
        pdf = Magick::ImageList.new(pdf_file_path)
        y_inc = image_height / pdf.size

        pdf.each_with_index do |page_img, index|
          page_img.write jpg_file_path
          image_height = y_inc
          image_y += y_inc * index
          bounding_box([image_x, image_y], width: image_width, height: image_height) do
            # stroke_bounds
            image jpg_file_path, width: image_width, height: image_height
          end
        end
      ensure
        File.delete(pdf_file_path)
        File.delete(jpg_file_path)
      end
    else
      FileUtils.mkdir_p('tmp')
      file_path = "tmp/#{scanned_image.filename}"
      File.binwrite(file_path, scanned_image.content)
      begin
        # bc_bc = Prawn::Images::PNG.new(bc.certificate_file_contents)
        bounding_box([image_x, image_y], width: image_width, height: image_height) do
          # stroke_bounds
          image file_path, width: image_width, height: image_height
        end
      ensure
        File.delete(file_path)
      end
    end
  end

  # define page column and rows
  #
  # === Parameters:
  #
  # * <tt>:columns</tt> number of columns
  # * <tt>:rows</tt> number of rows
  #
  def define_grid_page(columns = 4, rows = 20)
    define_grid(columns: columns, rows: rows)
  end

  # Generate address for page
  #
  # === Parameters:
  #
  # * <tt>:cell</tt> beginning cell
  # * <tt>:label_base</tt> for looking up I18n info
  # * <tt>:address_association</tt> address information
  # * <tt>:is_prof</tt> whether address of profession of faith
  #
  def grid_address(cell, label_base, address_association, is_prof)
    if is_prof
      grid_label_value([cell[0], 0], "#{I18n.t("#{label_base}.prof_street_1")}:", address_association.street_1)
      grid_label_value([cell[0], 2], "#{I18n.t("#{label_base}.prof_street_2")}:", address_association.street_2)
      grid_label_value([cell[0] + 1, 0], "#{I18n.t("#{label_base}.prof_city")}:", address_association.city)
      grid_label_value([cell[0] + 1, 2], "#{I18n.t("#{label_base}.prof_state")}:", address_association.state)
      grid_label_value([cell[0] + 2, 0], "#{I18n.t("#{label_base}.prof_zip_code")}:", address_association.zip_code)
    else
      grid_label_value([cell[0], 0], "#{I18n.t("#{label_base}.street_1")}:", address_association.street_1)
      grid_label_value([cell[0], 2], "#{I18n.t("#{label_base}.street_2")}:", address_association.street_2)
      grid_label_value([cell[0] + 1, 0], "#{I18n.t("#{label_base}.city")}:", address_association.city)
      grid_label_value([cell[0] + 1, 2], "#{I18n.t("#{label_base}.state")}:", address_association.state)
      grid_label_value([cell[0] + 2, 0], "#{I18n.t("#{label_base}.zip_code")}:", address_association.zip_code)
    end
  end

  # Generate label-value for a cell
  #
  # === Parameters:
  #
  # * <tt>:cell</tt> cell
  # * <tt>:label</tt> label
  # * <tt>:value</tt> value
  #
  def grid_label_value(cell, label, value)
    grid_label(cell, cell, label)
    grid_value([cell[0], cell[1] + 1], [cell[0], cell[1] + 1], value)
  end

  # Generate label-value for a cell for cell width 2
  #
  # === Parameters:
  #
  # * <tt>:cell</tt> cell
  # * <tt>:label</tt> label
  # * <tt>:value</tt> value
  #
  def grid_label_value2(cell, label, value)
    grid_label(cell, [cell[0], cell[1] + 1], label)
    grid_value([cell[0], cell[1] + 2], [cell[0], cell[1] + 3], value)
  end

  # Generate label for a cell
  #
  # === Parameters:
  #
  # * <tt>:cell</tt> start point
  # * <tt>:cell2</tt> end point
  # * <tt>:label</tt> label
  #
  def grid_label(cell, cell2, label)
    grid(cell, cell2).bounding_box do
      # move_down 20
      font('Courier') { text "<b>#{label}</b>", inline_format: true }
    end
  end

  # Generate value for a cell
  #
  # === Parameters:
  #
  # * <tt>:cell</tt> start point
  # * <tt>:cell2</tt> end point
  # * <tt>:value</tt> value
  #
  def grid_value(cell, cell2, value)
    val = if (value.is_a? TrueClass) || (value.is_a? FalseClass) || (value.is_a? Date)
            value.to_s
          else
            value.presence || '<no value>'
          end
    grid(cell, cell2).bounding_box do
      # move_down 20
      text val
    end
  end

  # Generate page header
  #
  # === Parameters:
  #
  # * <tt>:header_text</tt> text for header
  # * <tt>:cell1</tt> start point
  # * <tt>:cell2</tt> end point
  #
  def page_header(header_text, cell1, cell2)
    grid(cell1, cell2).bounding_box do
      font 'Helvetica'
      text header_text, align: :center, size: 25
      stroke_horizontal_rule
    end
  end

  # Output the event information
  #
  # === Parameters:
  #
  # * <tt>:event</tt> CandidateEvent
  # * <tt>:cell1</tt> start point
  # * <tt>:cell2</tt> end point
  #
  def common_event(event, cell1, cell2)
    completed_color = event.completed_date.nil? ? 'ff0000' : '000000'
    verified_color = event.verified ? '000000' : 'ff0000'

    grid(cell1, cell2).bounding_box do
      font 'Courier'
      valign = :top
      align = :left
      w = bounds.width / 4
      bounding_box [bounds.left, bounds.top], width: w do
        text '<b>Completed Date:</b>', inline_format: true, align: align, valign: valign, color: completed_color
      end
      bounding_box [bounds.left + w, bounds.top], width: w do
        text event.completed_date.to_s, inline_format: true, align: align, valign: valign, color: completed_color
      end
      bounding_box [bounds.left + (2 * w), bounds.top], width: w do
        text '<b>Admin Verified:</b>', inline_format: true, align: align, valign: valign, color: verified_color
      end
      bounding_box [bounds.left + (3 * w), bounds.top], width: w do
        text event.verified.to_s, inline_format: true, align: align, valign: valign, color: verified_color
      end
      stroke_horizontal_rule
    end
  end

  # Generate title page
  #
  def title_page
    bounding_box [bounds.left, bounds.top], width: bounds.width, height: bounds.height do
      bounding_box [bounds.left, bounds.top], width: bounds.width, height: bounds.height / 3 do
        text '2023-2024 Confirmation booklet', size: 30, style: :bold, align: :center, valign: :bottom
      end
      bounding_box [bounds.left, bounds.top - (bounds.height / 3)], width: bounds.width, height: bounds.height / 3 do
        text 'for', size: 30, style: :bold, align: :center, valign: :center
      end
      bounding_box [bounds.left, bounds.top - ((bounds.height * 2) / 3)], width: bounds.width, height: bounds.height / 3 do
        text "#{@candidate.candidate_sheet.first_name} #{@candidate.candidate_sheet.last_name}",
             size: 30, style: :bold, align: :center, valign: :top
      end
    end
    bounding_box [bounds.left, bounds.bottom + 25], width: bounds.width do
      font 'Helvetica'
      stroke_horizontal_rule
      move_down(5)
      text 'Complete', size: 16 if @verified
      text 'Not Complete', size: 16, color: 'ff0000' unless @verified
    end
  end
end
