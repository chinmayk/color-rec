require 'open-uri'
$LOAD_PATH << '.'
require 'get-images'
require 'utils'

#create a directory for crawled images
#query = "@ladygaga"
results = []

analyzer = ImageHister.new


open('./tmp/input','r') do |f|
	Dir.chdir('../data') do
		f.readlines.each do |query|
			query = query.strip! 
			unless query.include?('#')
				puts "Processing #{query}..."
				unless File.directory? URI.encode(query)
					`mkdir -p #{URI.encode(query)}`
					dump_from_google(query, URI.encode(query))
				end
				analyzer.process_query(query)
				
				#results << {"query"=>query, "results"=> analyzer.json_for_query(query)} 
			end
		end
		
		results << {"query"=> "Total", "results" => analyzer.topic_info}
		
		#(analyzer.renormalize_histogram).each do |query, result|
		#	results << {"query"=>query, "results"=> analyzer.create_json_for_normalized_hist(result)} 
		#end
		
		results = analyzer.get_clusters
		puts "#{results.to_json}"	
		
		#Example SQL
		#INSERT INTO `color-376`.`colors` (`color_id`, `hex_value`, `color_category`, `color_item`, `source`, `frequency`) 
		#VALUES (NULL, '050215', 'fruits', 'apple', 'test'), (NULL, '5F462A', 'fruits', 'apple', 'test')
		
		category_name = "college football teams"
		source_name = "weighted_distance"
		result_strs = []
		sql_string = 'INSERT INTO `color-376`.`colors` (`color_id`, `hex_value`, `color_category`, `color_item`, `source`, `frequency`, `max_frequency`, `histogram_order`) VALUES '
		
		results.each do |result|
			result[:centroids].each_with_index do |cluster, i|
				result_strs << "(NULL, '#{cluster[:rgba]}', '#{category_name}', '#{result[:query]}', '#{source_name}', '#{cluster[:frequency]}', '#{result[:max]}', '#{i}')"
			end
			
		end
		
		result_str = result_strs.join(', ')
		
		puts sql_string + result_str
		
		#open("hist.js", "w") do |out|
		#	out.write("color_frequencies = #{results.to_json};")
		#end
		
		puts "=====================Palette======================\n\n"
		
		#puts analyzer.get_palette.to_json
		
		palette_sql_str = "INSERT INTO `color-376`.`palettes` (`palette_id`, `hex1`, `color_item1`, `hex2`, `color_item2`, `hex3`, `color_item3`, `hex4`, `color_item4`, `color_category`, `algorithm`, `quality1`, `quality2`, `quality3`, `quality4`, `lab1`, `lab2`, `lab3`, `lab4`) VALUES "
		
		result_palette_str = [] 
		
		generated_pallete = analyzer.get_palette(true)
		
		puts generated_pallete.to_json
		
		generated_pallete.each do |palette|
			result_palette_str << "(NULL, '#{palette[:palette][0][:rgba]}', '#{palette[:palette][0][:query]}', '#{palette[:palette][1][:rgba]}', '#{palette[:palette][1][:query]}','#{palette[:palette][2][:rgba]}', '#{palette[:palette][2][:query]}','#{palette[:palette][3][:rgba]}', '#{palette[:palette][3][:query]}', '#{category_name}', '#{palette[:algorithm]}', '#{palette[:palette][0][:quality]}', '#{palette[:palette][1][:quality]}', '#{palette[:palette][2][:quality]}', '#{palette[:palette][3][:quality]}', '#{palette[:palette][0][:l]}, #{palette[:palette][0][:a]}, #{palette[:palette][0][:b]}', '#{palette[:palette][1][:l]}, #{palette[:palette][1][:a]}, #{palette[:palette][1][:b]}','#{palette[:palette][2][:l]}, #{palette[:palette][2][:a]}, #{palette[:palette][2][:b]}', '#{palette[:palette][3][:l]}, #{palette[:palette][3][:a]}, #{palette[:palette][3][:b]}' )"
		end
		
		puts palette_sql_str + result_palette_str.join(', ')
		
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
