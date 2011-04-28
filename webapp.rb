require 'sinatra'

$LOAD_PATH << '.'
require 'utils'
require 'get-images'

get '/search/:query' do
	content_type 'application/json'
	json_for_query(params[:query])
end

