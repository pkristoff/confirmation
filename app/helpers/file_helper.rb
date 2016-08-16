module FileHelper

  def delete_dir(dir)
    if Dir.exist? dir
      Dir.foreach(dir) do |filename|
        if File.directory?("#{dir}/#{filename}")
          delete_dir("#{dir}/#{filename}") unless filename === '.' || filename === '..'
        else
          File.delete("#{dir}/#{filename}")
        end
      end
      Dir.rmdir(dir)
    end
  end

end