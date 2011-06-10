# Color conversion and distance measure tools.
#Adapted from matlab and sources on the Internet.
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
	
	def self.str_rgb2lab(str)
		r = str[1,2].hex/255.0
		g = str[3,2].hex/255.0
		b = str[5,2].hex/255.0
		
		self.rgb2lab3(r,g,b)
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
		lab[:l] = l; lab[:a] = a; lab[:b] = b;
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
	
	def self.xyz2RGB(pixel, force_hex = false)
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
		unless force_hex
			rgb = "(#{(r*255).round}, #{(g*255).round}, #{(b*255).round}, 1)"
		else
			rgb = "%02X%02X%02X" % [(r*255).round, (g*255).round, (b*255).round]#{(r*255).round}, #{(g*255).round}, #{(b*255).round}, 1)"
		end
		return rgb;
	end
	
	def self.lab2RGB(l,a,b, force_hex = false)
		xyz2RGB((lab2xyz l,a,b),force_hex)
	end
	
	
	def	self.roundLAB(lab, options = {})
		options.merge!(ROUND_OPTIONS)
		
		l = (lab['l']/options[:l_granularity]).send(options[:round_method])
		a = (lab['a']/options[:l_granularity]).send(options[:round_method])
		b = (lab['b']/options[:l_granularity]).send(options[:round_method])
		
		rounded_lab = { 'l' => l, 'a' => a, 'b' => b}
	end
	
	# Returns distance between two points in LAB space
	def self.LABDistance(a,b)
		l1 = a['l'] || a[:l]; l2 = b['l'] || b[:l]
		a1 = a['a'] || a[:a]; a2 = b['a'] || b[:a]
		b1 = b['b'] || a[:b]; b2 = b['b'] || b[:b]
		
		return ((l1 - l2)**2 + (a1 - a2)**2 + (b1-b2)**2) ** 0.5  
	end
end
