require 'zip'

# This is a simple example which uses rubyzip to
# recursively generate a zip file from the contents of
# a specified directory. The directory itself is not
# included in the archive, rather just its contents.
#
# Usage:
#   directoryToZip = "/tmp/input"
#   outputFile = "/tmp/out.zip"
#   zf = ZipFileGenerator.new(directoryToZip, outputFile)
#   zf.write()
class ZipFileGenerator

  # Initialize with the directory to zip and the location of the output archive.
  def initialize()
  end

  # Zip the input directory.
  def zip(inputDir, outputFile)
    entries = Dir.entries(inputDir);
    entries.delete(".");
    entries.delete("..")
    io = Zip::File.open(outputFile, Zip::File::CREATE);
    writeEntries(inputDir, entries, "", io)
    io.close();
  end

  def unzip(file, destination)
    Zip::File.open(file) { |zip_file|
      zip_file.each { |f|
        f_path=File.join(destination, f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) unless File.exist?(f_path)
      }
    }
  end

  # A helper method to make the recursion work.
  private
  def writeEntries(inputDir, entries, path, io)

    entries.each { |e|
      zipFilePath = path == "" ? e : File.join(path, e)
      diskFilePath = File.join(inputDir, zipFilePath)
      puts "Deflating " + diskFilePath
      if  File.directory?(diskFilePath)
        io.mkdir(zipFilePath)
        subdir =Dir.entries(diskFilePath);
        subdir.delete(".");
        subdir.delete("..")
        writeEntries(inputDir, subdir, zipFilePath, io)
      else
        io.get_output_stream(zipFilePath) { |f| f.puts(File.open(diskFilePath, "rb").read())}
      end
    }
  end


end
