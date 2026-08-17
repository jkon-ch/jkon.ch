require 'active_support/all'
require 'yaml'
require 'erb'
require 'wahwah'

AUDIO_DIR = 'audioguide/2026/audio'.freeze
DATA = YAML.load_file('data.yaml')

class Episode # rubocop:disable Style/Documentation
  def initialize(path)
    @path = path
  end

  def url
    "https://jkon.ch/#{AUDIO_DIR}/#{file_name}"
  end

  def size
    file.size
  end

  def file_name
    File.basename(path)
  end

  def uuid
    Digest::UUID.uuid_v5(DATA['namespace_uuid'], file_name)
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
