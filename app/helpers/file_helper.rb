# frozen_string_literal: true

#
# File Helper
#
module FileHelper
  # Delete directory
  #
  # === Parameters:
  #
  # * <tt>:dir</tt> The event being edited in mass_edit_candidates_event.html.erb
  #
  # === Returns:
  #
  # Array of PluckCan
  #
  def delete_dir(dir)
    return unless Dir.exist? dir
    Dir.foreach(dir) do |filename|
      if File.directory?("#{dir}/#{filename}")
        delete_dir("#{dir}/#{filename}") unless %w[. ..].include? filename
      else
        File.delete("#{dir}/#{filename}")
      end
    end
    Dir.rmdir(dir)
  end
end
