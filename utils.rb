require'rmagick'
require 'json'
require 'k_means'
require 'open-uri'

$LOAD_PATH << '.'
require 'get-images'
require 'color-tools'

include Magick
class ImageAnalyzer
	HIST_HEIGHT = 500
	
	L_ACCURACY = 10.0; A_ACCURACY = 10.0; B_ACCURACY = 10.0;

	def initialize
		@topic_hist = []
	end
	
	def generate_histogram(imgList, numColors = 256, space = LABColorspace)
		histogram = {}
		begin
			quantizedImg = imgList.quantize numColors, space, NoDitherMethod
		
			print "Generating histogram"
			quantizedImg.each do |i|
				print "."
				histogram.merge!(i.color_histogram){|key, old_val, new_val| old_val+new_val}
			end
		rescue => e
			puts "Failed to generate histogram. Reason: #{e.message}"
		end
		print "\n"
		return histogram
	end
	
	def json_for_query(query)
		encoded_query = URI.encode(query)
		Dir.chdir('./data') unless Dir.getwd.include? 'data'
		
		unless File.directory? encoded_query
			`mkdir -p #{encoded_query}`
			dump_from_google(query, encoded_query)
		end
		
		hist = process_directory(encoded_query)
		
		hist_to_json(hist)
	end
	
	def draw_histogram(histogramHash)
		################
		### Histogram code from
		# http://www.imagemagick.org/RMagick/doc/color_histogram.rb.html
	
		# sort pixels by increasing count
	
		numColors = 256
		pixels = histogramHash.keys.sort_by {|pixel| histogramHash[pixel] }
	
		scale = HIST_HEIGHT / (histogramHash.values.max*1.025)   # put 2.5% air at the top
	
		gc = Magick::Draw.new
		gc.stroke_width(1)
		gc.affine(1, 0, 0, -scale, 0, HIST_HEIGHT)
	
		# handle images with fewer than NUM_COLORS colors
		start = 0 # numColors - histogramHash.length
	
		pixels.each { |pixel|
			gc.stroke(pixel.to_color)
			gc.fill(pixel.to_color)
			gc.stroke_width(10)
			gc.rectangle(start, 0, start+10, histogramHash[pixel])
			start = start.succ + 10
		}
	
		hatch = Magick::HatchFill.new("white", "gray95")
		canvas = Magick::Image.new(numColors, HIST_HEIGHT, hatch)
		gc.draw(canvas)
	
		text = Magick::Draw.new
		text.annotate(canvas, 0, 0, 0, 20, "Color Frequency\nhistogram") {
			self.pointsize = 10
			self.gravity = Magick::NorthGravity
			self.stroke = 'transparent'
		}
	
		canvas.border!(1, 1, "white")
		canvas.border!(1, 1, "black")
		canvas.border!(3, 3, "white")
		canvas.write("color_histogram.gif")
	
		return canvas
	###End histogram code
	end
	
	def cluster_colors(colors, num_centroids = 4)
		data = colors.map {|k| [k.red, k.green, k.blue, k.opacity]} #should find centroids in HSLA, but the distance metric is messed up
		kmeans = KMeans.new(data, :centroids =>num_centroids) #:distance_measure => :hsla_similarity)
	
		return kmeans
	end
	
	def cluster_histogram(colors, kmeans)
	
		colors_ary = colors.values
		#Find the total num of pixels that cluster on this centroid
		#Note that this adds all pixels equally, regardless of distance from the centroid.
		freqs = kmeans.view.map{|idx| idx.inject(0){|sum, val| sum+colors_ary[val]}}
	
		hist = {} #Empty for histogram
		#Create the colors for the histogram
		kmeans.centroids.each_with_index do |k,idx|
			positions = k.position
			pixel = Pixel.new
			pixel.red = positions[0]; pixel.green = positions[1]; pixel.blue = positions[2]; pixel.opacity = 1; #positions[3]
			hist[pixel] = freqs[idx]
		end
		hist
	end
	
	def process_directory(dir, force = false)
	
		serialized_hist = "#{dir}/serialized-hist"
	
		#If we don't insist on new data...
		if File.exists?(serialized_hist) && !force
			open(serialized_hist, 'r') do |f|
				return Marshal::load(f.read)
			end
		end
	
		#else...
		files = Dir.entries(dir).select {|f| f != 'log.txt' && f != '.' && f != '..' } #Don't process the log file
		files.collect!{|f| "#{dir}/#{f}"}
		img = ImageList.new
	
		files.each{|f| Image.read(f).each do |i| img << i end }
	
		imgList = img.copy
		quantizedImgLAB = img.quantize 10, LABColorspace, NoDitherMethod
		#quantizedImgHSL = img.quantize 10, HSLColorspace, NoDitherMethod
	
		reducedImgLAB = quantizedImgLAB.unique_colors
		#reducedImgHSL = quantizedImgHSL.unique_colors
	
		#reducedImgLAB.change_geometry!('400x240') { |cols, rows, img|
		#img.sample!(cols, rows)
		#}
		#reducedImgHSL.change_geometry!('400x240') { |cols, rows, img|
		#img.sample!(cols, rows)
		#}
	
		#imgList << quantizedImgLAB.first
		#imgList << quantizedImgHSL.first
	
		quantized256LAB = img.quantize 256, LABColorspace, NoDithbind
		hist = generate_histogram(quantized256LAB)
		#Serialize the hisotgram for future use
		open("#{dir}/serialized-hist", 'w') do |h|
			h.write(Marshal::dump(hist))
		end
		return hist
	end
	
	def hist_to_json(hist)
		#Assume the hist is a hash
		out_hist = []
		query_bins = {}
		hist.each do |key, val|
			out_hist << {"rgba" => "#{(key.red / 66535.0 * 255).round}, #{(key.green / 66535.0 * 255).round}, #{(key.blue / 66535.0 * 255).round}, 1",
				"lab" => ColorTools.rgb2lab(key),
				"frequency" => val}
		end
		
		#In addition to the exact LAB numbers, we also want to bin the LAB numbers
		approximate_colors = []
		max_binned_frequency = 0
		#Find the right bins. Start with L
		l_bins = {};
		average_l = {};
		out_hist.each do |el|
			if l_bins[(el["lab"]['l']/L_ACCURACY).to_i].nil?
				l_bins[(el["lab"]['l']/L_ACCURACY).to_i] = []
			end
			l_bins[(el["lab"]['l']/L_ACCURACY).to_i] << el
		end
		
		#For each l-bin, approximate the a, b bins
		l_bins.each do |key, val|
			this_bin = []
			#Find the centroid of luminance
			average_l = val.inject(0){|acc, v| acc + v['frequency']*v['lab']['l']}
			numPixels = val.inject(0){|acc, v| acc + v['frequency']}
			average_l /= numPixels;
			
			ab_bins = {}
			
			val.each do |v|
				ab_key = [(v['lab']['a']/A_ACCURACY).to_i, (v['lab']['a']/A_ACCURACY).to_i]
				
				unless ab_bins.has_key? ab_key
					ab_bins[ab_key] = {'values' => [], 'frequency' => 0}
				end
				
				ab_bins[ab_key]['values'] << v
			end
			
			ab_bins.each do |ab_key, ab_val_store|
				ab_val = ab_val_store['values']
				
				centroid = centroid_of ab_val
				
				ab_val_store['frequency'] = centroid['frequency']
				
				max_binned_frequency = centroid['frequency'] if centroid['frequency'] > max_binned_frequency
				
				closest_bin = ab_val.min {|a,b| ColorTools.LABDistance(a['lab'],centroid) <=> ColorTools.LABDistance(b['lab'], centroid)}
				
				this_bin <<{'l'=>centroid['l'], 'a'=> centroid['a'], 'b'=> centroid['b'],  
									  'rgb'=> ColorTools.lab2RGB(centroid['l'], centroid['a'], centroid['b']), #this gives the centroid of the bins
									  'closest_pixel' => closest_bin,
									  'frequency' => centroid['frequency']
									 }
				 
				#Store the bins in the topical cache
				query_bins[[key, ab_key[0], ab_key[1]]] = ab_val_store
			end
			
			approximate_colors << this_bin
		end
		
		approximate_colors.sort! do |a, b|
			a[0]['l'] <=> b[0]['l']
		end
		
		out_hist.sort! {|x,y| x["lab"]['l'] <=> y["lab"]['l']}
		out_data = {"values" => out_hist,
					"max" => hist.values.max,
					"approximate_colors" => approximate_colors,
					"max_binned_frequency" => max_binned_frequency
					}
		@topic_hist << query_bins
		out_data
	end
	
	#Find the centroid of a bin in LAB space.
	def centroid_of (bin)
		average_l = bin.inject(0){|acc, v| acc + v['frequency']*v['lab']['l']}
		average_a = bin.inject(0){|acc, v| acc + v['frequency']* v['lab']['a']}
		average_b = bin.inject(0){|acc, v| acc + v['frequency']* v['lab']['b']}
		
		count_pixels = bin.inject(0){|acc, v| acc + v['frequency']}	
		
		average_l /= count_pixels; average_a /= count_pixels; average_b /= count_pixels
		
		centroid = {'l' => average_l, 'a'=>average_a, 'b'=>average_b, 'frequency' => count_pixels}
	end
	
	def topic_info
		#Find out IDF of each bin
		idf = idf_of @topic_hist
	end

	def idf_of(topic_hist)
		numDocuments = topic_hist.length
		numOccurences = {} 
		topic_hist.each do |doc|
			doc.each do |key, val|
				if numOccurences.has_key? key
					 
					numOccurences[key] += 1
				else
					numOccurences[key] = 1
				end
			end
		end
		idfs = {}
		
		numOccurences.each do |key, val|
			idfs[key] = Math.log(numDocuments/val)
		end
		
		idfs
	end
		

	def create_js(var_name, data)
		"var #{var_name} = #{data};"
	end
end



module DistanceMeasures
	def hsla_similarity(other)
		#Is this distance measure transitive?

		#HSLA has the format: hue (0-360), saturation (0-100), luminosity (0-100)
		#Therefore,
		hue_diff = (self[0] - other[0]).abs % 180 #angular difference > 180 doesn't matter
		sat_lum_diff = ([self[1], self[2]]).euclidean_distance([other[1], other[2]]) #It is not exactly euclidean, but...
		alpha_diff = (self[3] - other[3]).abs

		return hue_diff + sat_lum_diff + alpha_diff
	end
end
