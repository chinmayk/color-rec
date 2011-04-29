require'rmagick'
require 'json'
require 'k_means'
require 'open-uri'

$LOAD_PATH << '.'
require 'get-images'

include Magick
HIST_HEIGHT = 500

L_ACCURACY = 10.0; A_ACCURACY = 10.0; B_ACCURACY = 10.0;


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

	quantized256LAB = img.quantize 256, LABColorspace, NoDitherMethod
	hist = generate_histogram(quantized256LAB)
	#Serialize the hisotgram for future use
	open("#{dir}/serialized-hist", 'w') do |h|
		h.write(Marshal::dump(hist))
	end
	return hist
end

def hist_to_json hist
	#Assume the hist is a hash
	out_hist = []
	hist.each do |key, val|
		out_hist << {"rgba" => "#{(key.red / 66535.0 * 255).round}, #{(key.green / 66535.0 * 255).round}, #{(key.blue / 66535.0 * 255).round}, 1",
			"lab" => ColorTools.rgb2lab(key),
			"frequency" => val}
	end
	
	#In addition to the exact LAB numbers, we also want to bin the LAB numbers
	approximate_colors = []
	
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
				ab_bins[ab_key] = []
			end
			
			ab_bins[ab_key] << v
		end
		
		ab_bins.each do |ab_key, ab_val|
			average_a = ab_val.inject(0){|acc, v| acc + v['frequency']* v['lab']['a']}
			average_b = ab_val.inject(0){|acc, v| acc + v['frequency']* v['lab']['b']}
			
			count_pixels = ab_val.inject(0){|acc, v| acc + v['frequency']}
			
			average_a /= count_pixels; average_b /= count_pixels
			
			this_bin <<{'l'=>average_l, 
								  'a'=> average_a, 
								  'b'=> average_b, 
								  'rgb'=> ColorTools.lab2RGB(average_l, average_a, average_b),
								  'frequency' => count_pixels
								 }
		end
		approximate_colors << this_bin
	end
	
	approximate_colors.sort! do |a, b|
		a[0]['l'] <=> b[0]['l']
	end
	
	out_hist.sort! {|x,y| x["lab"]['l'] <=> y["lab"]['l']}
	out_data = {"values" => out_hist,
				"max" => hist.values.max,
				"approximate_colors" => approximate_colors
				}
	out_data
end

def create_js(var_name, data)
	"var #{var_name} = #{data};"
end

class ColorTools
	##Conversion functions from
	# http://cookbooks.adobe.com/post_Useful_color_equations__RGB_to_LAB_converter-14227.html
	 
	#This is what RMagick uses
	MAX_PIXEL_VAL = 66535.0
	#Set a threshold
	T = 0.008856
	#Standard values
	 REF_X = 95.047; # Observer= 2°, Illuminant= D65
	 REF_Y = 100.000; 
	 REF_Z = 108.883; 
	 
	 ROUND_OPTIONS = {
	 	:l_granularity =>10.0,
	 	:round_method => :round,
	 	
	 	:a_granularity =>10.0,
	 	:b_granularity => 10.0
	 }
			
	def self.rgb2xyz(pixel)
		r = pixel.red/MAX_PIXEL_VAL
		g = pixel.green/MAX_PIXEL_VAL
		b = pixel.blue/MAX_PIXEL_VAL
		
		rgb2xyz r,g,b
	end
	
	def self.rgb2lab3(r,g,b)	
		x = r * 0.4124 + g * 0.3576 + b * 0.1805
		y = r * 0.2126 + g * 0.7152 + b * 0.0722
		z = r * 0.0193 + g * 0.1192 + b * 0.9505
		
		#Normalize for D65 white point
		x /= 0.950456
		z /= 1.088754
		
		xt = x > T ? 1 : 0;
		yt = y > T ? 1 : 0;
		zt = z > T ? 1 : 0;
		
		y_root = y ** (1/3.0); 

		fX = xt * x ** (1/3.0) + (1-xt) * (7.787 * x + 16/116.0);
		fY = yt * y_root + (1-yt) * (7.787 * y + 16/116.0);
		fZ = zt * z ** (1/3.0) + (1-zt) * (7.787 * z + 16/116.0);
		
		l = yt * (116 * y_root - 16.0) + (1-yt) * (903.3 * y);
		a = 500 * (fX - fY)
		b = 200 * (fY - fZ)
		
		lab = {}
		lab['l'] = l; lab['a'] = a; lab['b'] = b;
		
		lab
	end
	
	def self.rgb2xyz(r,g,b)
		
		if (r > 0.04045)
			r = (r + 0.055) / 1.055 ** 2.4
		else
			r = r / 12.92
		end

		if ( g > 0.04045)
			g = ((g + 0.055) / 1.055) ** 2.4
		else
			g = g / 12.92
		end
		
		if (b > 0.04045)
			b = ((b + 0.055) / 1.055) ** 2.4
		else
			b = b / 12.92
		end
		r = r * 100
		g = g * 100
		b = b * 100

		#Observer. = 2, Illuminant = D65
		xyz = {}
		xyz['x'] = r * 0.4124 + g * 0.3576 + b * 0.1805
		xyz['y'] = r * 0.2126 + g * 0.7152 + b * 0.0722
		xyz['z'] = r * 0.0193 + g * 0.1192 + b * 0.9505

		return xyz;
	end
	
	def self.xyz2LAB(xyz)
			
			x = xyz['x']/ REF_X;   
			y = xyz['y'] / REF_Y;  
			z = xyz['z'] / REF_Z;  
 
			if ( x > 0.008856 ) 
				x =  x ** (1/3.0) 
			else 
				x = ( 7.787 * x ) + ( 16/116.0 )
			end
			if ( y > 0.008856 ) 
				y = y ** (1/3.0)  
			else 
				y = ( 7.787 * y ) + ( 16/116.0 )
			end
			if ( z > 0.008856 ) 
				 z =  z ** (1/3.0) 
			else 
				z = ( 7.787 * z ) + ( 16/116.0 )
			 end
			lab = {}
			lab['l'] = ( 116 * y ) - 16;
			lab['a'] = 500 * ( x - y );
			lab['b'] = 200 * ( y - z );
			lab
	end
	
	def self.rgb2lab(pixel)
		r = pixel.red/MAX_PIXEL_VAL
		g = pixel.green/MAX_PIXEL_VAL
		b = pixel.blue/MAX_PIXEL_VAL
		return self.rgb2lab3 r,g,b
	end
	
	def self.lab2xyz(l, a, b)
			
		y = (l + 16) / 116.0;
		x= a / 500.0 + y;
		z = y - b / 200.0;
 
		if (y ** 3 ) > 0.008856 
			y = y ** 3 
		else 
			y = ( y - 16 / 116.0 ) / 7.787
		end
		 
		if  x ** 3  > 0.008856 
			x =  x ** 3 
		else 
			x = ( x - 16 / 116.0 ) / 7.787
		end
		
		if z ** 3  > 0.008856 
			z =  z ** 3 
		else 
			z = ( z - 16 / 116.0 ) / 7.787
		end
		
		xyz = {:x => REF_X*x, :y => REF_Y*y, :z=>REF_Z*z}
	end
	
	def self.xyz2RGB(pixel)
		x = pixel[:x] / 100;        
		y = pixel[:y] / 100;        
		z = pixel[:z] / 100;        
 
		r = (x * 3.2406) + (y * -1.5372) + (z * -0.4986);
		g = x * -0.9689 + y * 1.8758 + z * 0.0415;
		b = x * 0.0557 + y * -0.2040 + z * 1.0570;
 
 		#print "r = #{r}, g = #{g}, b =#{b}"
 		
		#if  r > 0.0031308
		#	r = 1.055 *  r ** 1/2.4 - 0.055
		#else
		#	r = 12.92 * r
		#end
		#if g > 0.0031308
		#	g = 1.055 *  g ** 1/2.4 - 0.055
		#else 
		#	g = 12.92 * g
		#end
		#if b > 0.0031308
		#	b = 1.055 *  b ** 1/2.4 - 0.055
		#else
		#	b = 12.92 * b
		#end
		
		#max to 1
		r = 1 if r > 1; g = 1 if g > 1; b = 1 if b > 1;
		
		#min to 0
		r = 0 if r < 0; g = 0 if g < 0; b = 0 if b < 0;
		
		rgb = "(#{(r*255).round}, #{(g*255).round}, #{(b*255).round}, 1)"
		return rgb;
	end
	
	def self.lab2RGB(l,a,b)
		xyz2RGB lab2xyz l,a,b
	end
	
	
	def	self.roundLAB(lab, options = {})
		options.merge!(ROUND_OPTIONS)
		
		l = (lab['l']/options[:l_granularity]).send(options[:round_method])
		a = (lab['a']/options[:l_granularity]).send(options[:round_method])
		b = (lab['b']/options[:l_granularity]).send(options[:round_method])
		
		rounded_lab = { 'l' => l, 'a' => a, 'b' => b}
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
