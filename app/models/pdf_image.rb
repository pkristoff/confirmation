# frozen_string_literal: true

require 'rmagick'
# common PDF image handling
#
class PDFImage < Prawn::Document
  include Magick
  # include GMagick

  # Generate image
  #
  # === Parameters:
  #
  # * <tt>:scanned_image</tt> scanned image
  # * <tt>:label</tt> label
  #
  def common_image(scanned_image, label = '')
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
      rescue Prawn::Errors::UnsupportedImageType => e
        text "#{e.message}: #{scanned_image.content_type}", width: image_width, height: image_height
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
      rescue Prawn::Errors::UnsupportedImageType => e
        text "#{e.message}: #{scanned_image.content_type}", width: image_width, height: image_height
      ensure
        File.delete(file_path)
      end
    end
  end
end
