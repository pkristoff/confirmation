# frozen_string_literal: true

#
# Generate PDF for comparing candidate name with baptismal name
#
class CandidateNamePDFDocument < Prawn::Document
  include Magick

  # init
  #
  def initialize
    super()
    @candidates = Candidate.reject do |cand|
      ev = cand.get_candidate_event(I18n.t('events.baptismal_certificate'))
      ev.completed_date.nil?
    end
    do_document
  end

  # name of pdf
  #
  def document_name
    'Compare Baptismal Name.pdf'
  end

  # Generate PDF document
  #
  def do_document
    title_page
    @candidates.each do |cand|
      page(cand)
    end
  end

  # Generate title page
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> candidate waiting verification
  #
  def page(candidate)
    start_new_page
    define_grid_page
    grid_label_value([1, 0], "#{I18n.t('label.candidate_sheet.first_name')}:", candidate.candidate_sheet.first_name)
    grid_label_value([1, 2], "#{I18n.t('label.candidate_sheet.middle_name')}:", candidate.candidate_sheet.middle_name)
    grid_label_value([2, 0], "#{I18n.t('label.candidate_sheet.last_name')}:", candidate.candidate_sheet.last_name)

    common_image(candidate.baptismal_certificate.scanned_certificate)
  end

  # Generate title page
  #
  def title_page
    bounding_box [bounds.left, bounds.top], width: bounds.width, height: bounds.height do
      bounding_box [bounds.left, bounds.top], width: bounds.width, height: bounds.height / 3 do
        text 'Comparing Candidate name to baptismal certificate', size: 30, style: :bold, align: :center, valign: :bottom
      end
    end
  end

  # Generate image
  #
  # === Parameters:
  #
  # * <tt>:scanned_image</tt> scanned image
  #
  def common_image(scanned_image)
    namea_offset = 60

    image_x = bounds.left
    image_y = bounds.top - namea_offset - 25
    image_width = bounds.width - 20
    image_height = bounds.height - 20

    if scanned_image.nil?
      bounding_box([image_x, image_y], width: image_width, height: bounds.height - 25) do
        text '<No Image Provided>', align: :center, valign: :center
        # stroke_bounds
      end
      # convert pdf to jpg which Prawn handles.
    elsif scanned_image.content_type == 'application/pdf'
      Dir.mkdir('tmp') unless Dir.exist?('tmp')
      pdf_file_path = "tmp/#{scanned_image.filename}".downcase
      jpg_file_path = pdf_file_path.gsub('.pdf', '.jpg')
      File.open(pdf_file_path, 'wb') do |f|
        f.write(scanned_image.content)
      end
      begin
        pdf = Magick::ImageList.new(pdf_file_path)

        pdf.each do |page_img|
          page_img.write jpg_file_path

          bounding_box([image_x, image_y], width: image_width, height: image_height) do
            # stroke_bounds
            image jpg_file_path, width: image_width, height: image_height
          end
        end
      ensure
        File.delete(pdf_file_path) if File.exist?(pdf_file_path)
        File.delete(jpg_file_path) if File.exist?(jpg_file_path)
      end
    else
      Dir.mkdir('tmp') unless Dir.exist?('tmp')
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
        File.delete(file_path) if File.exist?(file_path)
      end
    end
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
end
