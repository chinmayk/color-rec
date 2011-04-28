require 'RMagick'
require 'open-uri'
include Magick

$LOAD_PATH << '.'
require 'get-images'
require 'utils'

#create a directory for crawled images
#query = "@ladygaga"
results = []

open('./tmp/input','r') do |f|
	Dir.chdir('../data') do
		f.readlines.each do |query|
			query = query.strip! 
			unless query.include?('#')
				puts "Processing #{query}..."
				unless File.directory? query
					`mkdir -p #{query}`
					dump_from_google(query, query)
				end
				results << {"query"=>query, "results"=> json_for_query(query)} 
			end
		end
		
		open("hist.js", "w") do |out|
			out.write("color_frequencies = #{results.to_json}")
		end
	end	
end
#Dir.chdir('./data') 


#open('hist.js','w') do |j|
#	j.write(create_js "color_frequency", json_for_query(query))
#end



#km = cluster_colors(hist.keys,4)
#cluster_hist = cluster_histogram hist, km
#canvas = draw_histogram cluster_hist

#imgList << Image.new(1,1) {self.background_color = 'white'}

# imgList << canvas
#imgList << reducedImgLAB
#imgList << reducedImgHSL

#p = imgList.length - 2
#dispImg = imgList.montage {self.geometry = "100x100+10+5"; self.gravity = NorthGravity

#	imgList[p]['Label'] = "LAB Color Palette"
	#imgList[p+1]['Label'] = "HSL Color Palette"
#}

#dispImg.display
#dispImg.write("#{encoded_query}_palette.jpg")

#canvas.write("#{encoded_query}_clustered.gif")
exit
#images.display
