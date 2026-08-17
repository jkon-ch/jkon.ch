require 'active_support/all'
require 'yaml'
require 'erb'
require 'wahwah'
require 'time'

YEAR = 2026
GUIDE_DIR = "audioguide/#{YEAR}".freeze
AUDIO_DIR = "#{GUIDE_DIR}/audio".freeze
DATA = YAML.load_file('data.yaml')
NAMESPACE_UUID = DATA['namespace_uuid']
PUBLISH_START_TIME = Time.parse(DATA['publish_start_time'])

class Episode # rubocop:disable Style/Documentation
  def initialize(path)
    @path = path
  end

  def url
    "https://jkon.ch/#{AUDIO_DIR}/#{file_name}"
  end

  def link
    "https://jkon.ch/#{GUIDE_DIR}/#{file_name}"
  end

  def size
    file.size
  end

  def file_name
    File.basename(path)
  end

  def uuid
    Digest::UUID.uuid_v5(NAMESPACE_UUID, file_name)
  end

  def title
    tag.title
  end

  def description
    title
  end

  def duration
    tag.duration.to_i
  end

  def <=>(other)
    number <=> other.number
  end

  def number
    file_name.split('-').first.to_i
  end

  def publish_time
    PUBLISH_START_TIME + number.minutes
  end

  # TODO: fix this next year
  def season
    YEAR
  end

  attr_reader :path

  private

  def file
    File.new(path)
  end

  def tag
    WahWah.open(file)
  end
end

erb = ERB.new(File.read('feed.xml.erb'))

episodes = Dir.glob("../../#{AUDIO_DIR}/*.mp3").map do |path|
  Episode.new(path)
end.sort

File.write('feed.xml', erb.result_with_hash({ episodes: }))
