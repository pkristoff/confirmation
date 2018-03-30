# frozen_string_literal: true

#
# File Helper
#
module FileHelper
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
