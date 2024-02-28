# frozen_string_literal: true

#
# Generate PDF for comparing candidate name with baptismal name
#
class CandidateNamePDFDocument < PDFImage
  attr_accessor :plucked_bap_candidates

  # init
  #
  def initialize
    super()
    plucked_bap_cands = PluckBapCandidate.pluck_bap_candidates
    @plucked_bap_candidates = plucked_bap_cands.reject(&:nil?)
    do_document
  end

  # name of pdf
  #
  def self.document_name
    'Compare Baptismal Name.pdf'
  end

  # Generate PDF document
  #
  def do_document
    title_page
    @plucked_bap_candidates.each do |cand|
      page(cand)
    end
  end

  # Generate page
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> candidate waiting verification
  #
  def page(candidate)
    baptismal_certificate = BaptismalCertificate.find_by(id: candidate.baptismal_certificate_id)
    start_new_page
    define_grid_page
    grid_label_value([1, 0], "#{I18n.t('activerecord.attributes.candidate_sheet.first_name')}:", candidate.first_name)
    grid_label_value([1, 2], "#{I18n.t('activerecord.attributes.candidate_sheet.middle_name')}:", candidate.middle_name)
    grid_label_value([2, 0], "#{I18n.t('activerecord.attributes.candidate_sheet.last_name')}:", candidate.last_name)

    common_image(baptismal_certificate.scanned_certificate)
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
