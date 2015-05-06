
class RPackage
  include Mongoid::Document
  field :name, type: String
  field :version, type: String
  field :publication, type: DateTime
  field :title , type: String
  field :web_link , type: String
  field :description, type: String

  field :package, type: String
  field :type, type: String
  field :date, type: String
  field :imports, type: String
  field :author, type: String
  field :authors, type: String
  field :maintainer, type: String
  field :maintainers, type: String
  field :depends, type: String
  field :suggests, type: String
  field :license, type: String
  field :lazyload, type: String
  field :lazydata, type: String
  field :encoding, type: String
  field :collate, type: String
  field :packaged, type: String
  field :needscompilation, type: String
  field :repository, type: String
  field :date_publication, type: DateTime
  field :classification_acm, type: String
  field :classification_jel, type: String
  field :url, type: String
  field :systemrequirements, type: String
  field :linkingto, type: String
  field :repository_r_forge_project, type: String
  field :repository_r_forge_revision, type: String
  field :repository_r_forge_datetimestamp, type: DateTime
  field :keywords, type: String
  field :biocviews, type: String
  field :enhances, type: String

  validates :name, presence: true, uniqueness: true
  validates :version, presence: true
  validates :title, presence: true

  BASE_DOMAIN = "cran.r-project.org"

  def named_version
    "#{name}_#{version}"
  end
  def dowload_path
    "/src/contrib/#{named_version}.tar.gz"
  end


  def download_url
    "http://#{BASE_DOMAIN}#{dowload_path}"
  end

  def file_path
    "packages/#{named_version}.tar.gz"
  end

  def description_file_path
    "packages/#{named_version}_description"
  end

  def download
    unless File.exist?( file_path )
      f = File.open(file_path, "w")
      ap download_url
      Net::HTTP.start(RPackage::BASE_DOMAIN) do |http|
        begin
            http.request_get(dowload_path) do |resp|
                resp.read_body do |segment|
                    f.write(segment)
                end
            end
        ensure
          f.close()
        end
      end
    end
  end


  def extract_description
    Gem::Package::TarReader.new( Zlib::GzipReader.open file_path ) do |tar|
      tar.each do |file|
        if file.full_name.match /DESCRIPTION$/
          update_fields_with_desc( Dcf.parse( file.read).first )
        end
      end
    end
  end

  def update_fields_with_desc( description )
    extract = %w{version title description package date authors maintainer}
    description.select{|key,value| extract.include?(key.to_s.downcase.gsub("/", "_").gsub("-", "_").gsub(/@.*?$/, ""))}.each do |key,value|
      self.send "#{key.downcase.gsub("/", "_").gsub("-", "_").gsub(/@.*?$/, "")}=", value
    end
    self.save!
  end

  def clear_download
    File.delete(file_path)
  end

  def maintainers
    return [] if maintainer.nil?
    maintainer.scan(/,?(?<name>.*?)\s<(?<email>[^>]+)>/).inject([]){|m,(name,email)| m << { name: name, email: email } }
  end


end