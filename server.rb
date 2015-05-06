require "sinatra"
require_relative "lib/erems.rb"

get "/" do
  content_type :json
  RPackage.limit(50).all.map(&:to_h).to_json
end