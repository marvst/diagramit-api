require 'httparty'
require 'zlib'
require 'base64'
require 'gitlab'

# Base URLs
KROKI_BASE_URL = 'https://kroki.io/:diagram_type/svg/'
GOOGLE_DRIVE_BASE_URL = 'https://drive.google.com/uc?export=download&confirm=no_antivirus&id='

# Domains
GOOGLE_DRIVE_DOMAIN = 'drive.google.com'
GITHUB_DOMAIN = 'github.com'
GITLAB_DOMAIN = 'gitlab.com'

class Diagram
  def self.generate_from source, diagram_type
    file_content = get_content_from source

    content_encoded = compress_and_encode file_content

    diagram_url = (KROKI_BASE_URL.sub ':diagram_type', diagram_type) + content_encoded

    {
        :diagram => diagram_url,
        :source => source
    }
  rescue => err
    raise StandardError.new "Fail to generate diagram from source because: #{err.to_s}"
  end

  def self.compress_and_encode file_content
    content_compressed = Zlib::Deflate.deflate(file_content, Zlib::BEST_COMPRESSION)
    content_encoded = Base64.urlsafe_encode64(content_compressed)

    content_encoded
  rescue => err
    raise StandardError.new "Fail to compress and encode file content because: #{err.to_s}"
  end

  def self.get_content_from source
    final_source = identify_strategy_for source
    file_content = HTTParty.get(final_source).body

    file_content
  rescue => err
    raise StandardError.new "Fail to get content from source because: #{err.to_s}"
  end

def self.identify_strategy_for source
    if source.include? GITHUB_DOMAIN or source.include? GITLAB_DOMAIN then return source.sub 'blob', 'raw' end
    if source.include? GOOGLE_DRIVE_DOMAIN then return GOOGLE_DRIVE_BASE_URL + source.split('id=')[1] end
    
    source
  rescue => err
    raise StandardError.new "Fail to identify strategy for dealing with source because: #{err.to_s}"
  end

  def self.is_public? source
    file_content = HTTParty.get(source).body

    if file_content.include? 'Checking your browser before accessing' then return false end

    true
  end
end
