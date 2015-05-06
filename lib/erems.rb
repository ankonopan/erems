require 'workers'
require 'awesome_print'
require 'mongoid'
require 'open-uri'
require 'nokogiri'
require 'rubygems/package'
require 'zlib'
require "dcf"


require_relative "r_package.rb"

# init mongoid
Mongoid.load!("config/mongoid.yml", :development)

class Erems

  def scrap_for_packages_text
    doc = open("http://cran.r-project.org/src/contrib/PACKAGES").read
    regexp = %r{
      Package:\s(?<name>.*?)\n
      Version:\s(?<version>.*?)\n
      (Depends:\s(?<depends>.*?)\n)?
      (Enhances:\s(?<enhances>.*?)\n)?
      (Imports:\s(?<imports>.*?)\n)?
      (LinkingTo:\s(?<linking_to>.*?)\n)?
      (Suggests:\s(?<suggests>.*?)\n)?
      (License:\s(?<license>.*?)\n)?
      (License_restricts_use:\s(?<l_r_use>.*?)\n)?
      NeedsCompilation:\s(?<compilation>.*?)\n
    }xm
    packages = doc.scan regexp
    packages.each do |pac|
      ap "Upserting <#{pac.first}> package"
      package = RPackage.new(
                name: pac.first,
                version: pac[1]
              )
      package.upsert
    end
  end

  def scrap_for_packages
    base_url = "http://cran.r-project.org"
    doc = Nokogiri::HTML(open("#{base_url}/web/packages/available_packages_by_name.html"))
    doc.css("table tr").inject({}) do |acc,pac|
      unless pac.css("a").empty?
        lnk = pac.css("a").first
        ap "Upserting <#{lnk.text}> package"
        package = RPackage.new(
                  description: pac.text,
                  name: lnk.text,
                  title: lnk.text,
                  web_link: lnk.attr("href").gsub("../..", base_url)
                )
        package.upsert
      end
    end
  end

  def dowload_packages
    group = Workers::TaskGroup.new( pool: Workers.pool.new( size: 60) )
    RPackage.all.to_a.each do |pac|
      group.add do
        ap "Extracting #{pac.name}"
        pac.download
        pac.extract_description
        pac.clear_download
      end
    end
    group.run
  end

end
