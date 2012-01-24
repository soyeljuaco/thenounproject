require 'rubygems'
require 'fileutils'
require 'zip/zip'

class Downloader
    attr_reader :base_url, :video_number, :total_videos
    attr_accessor :full_url
    
    def initialize(total_videos)
        @base_url = "http://www.thenounproject.com/site_media/zipped/"
        @video_number = 1
        @total_videos = total_videos
        @download_dir = make_download_dir
    end
    
    def download_all_videos
        until total_videos+1 == video_number
            @full_url = base_url + "svg_#{video_number}.zip"
            system("cd #{@download_dir} && wget #{full_url}")
            
            # Some files aren't being downloaded, not sure if files are missing in server 
            # or server timing out
            sleep 0.25
            @video_number += 1
        end
    end
    
    def extract_dirs
        array = Dir.entries("noun-project")
        array.delete("."); array.delete("..");
        array.each { |zipped_file| unzip_file("noun-project/#{zipped_file}", "extracted_contents") }
    end
    
    # Taken from http://stackoverflow.com/questions/966054/how-to-overwrite-existing-files-using-rubyzip-lib
    def unzip_file(file, destination)
        Zip::ZipFile.open(file) { |zip_file|
            zip_file.each { |f|
                f_path=File.join(destination, f.name)
                if File.exist?(f_path) then
                    FileUtils.rm_rf f_path
                end
                FileUtils.mkdir_p(File.dirname(f_path))
                zip_file.extract(f, f_path)
            }
        }
    end
    
    private
    
    def make_download_dir
        Dir.exists?("noun-project") || Dir.mkdir("noun-project")
        "noun-project"
    end
end

puts "How many videos are there in total? (Default = 629)"
number = gets.to_i
number = number == 0 ? 629 : number

dl = Downloader.new(number)
dl.download_all_videos
dl.extract_dirs

require 'rspec'

describe Downloader do
    before(:each) do
        @dl = Downloader.new(1)
    end
    
    it 'should create download dir if it does not exist' do
        Dir.exists?("noun-project").should == true
    end
    
    it 'should return default total videos url' do
        @dl.total_videos.should == 1
    end
    
    it 'should download 1 file' do
        Dir.entries("noun-project").size.should == 3
    end
end