require 'rubygems'
require 'open-uri'
require 'json'

BASE_URL = 'https://ajax.googleapis.com/ajax/services/search/images?v=1.0'
CONTENT_EXTENSIONS = {'image/gif' => '.gif',
						'image/jpeg' => '.jpg',
						'image/pjpeg' => '.jpg'
					}
def dump_from_google(query, dir)

	query_url = "#{BASE_URL}&q=#{URI.encode(query)}"
	
	json_responses = nil
	image_urls = []
	offsets = []
	open(query_url) do |p|
		json_responses = JSON.parse(p.read)
		#image_urls = json_responses['responseData']['results'].map {|result| result['unescapedUrl']}
		offsets = json_responses['responseData']['cursor']['pages'].map {|page| page['start']}
	end
	
	offsets.each do |start|
		open(query_url+"&start=#{start}") do |p|
			json_responses = JSON.parse(p.read)
			image_urls.concat json_responses['responseData']['results'].map {|result| result['unescapedUrl']}
		end
	end
	
	image_urls.flatten!
	open("#{dir}/log.txt", File::RDWR|File::CREAT) do |log|
		
		current_urls = log.readlines
		startIndex = current_urls.length
		#Clearly log should be append, but then I'll have to count the lines and increment the index. Later.
		image_urls.each_with_index do |url,i|
			index = i+startIndex
			log.write("#{index}\t#{url}\n")
			
			begin
				download = open(url) 
				puts "Writing file: #{dir}/#{index}#{CONTENT_EXTENSIONS[download.content_type]}"
				open("#{dir}/#{index}#{CONTENT_EXTENSIONS[download.content_type]}", 'w') do |out|
					#write file to disk
					out.write(open(url).read)
				end
			rescue => e
				puts "File download failed: #{e.message}"
				log.write("Failed to download from URL: #{url}\t\tReason: #{e.message}")
			end
		end
	end
end
