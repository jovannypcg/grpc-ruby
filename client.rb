this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'services_services_pb'
require 'messages_pb'
require 'pry'
require 'bunny'

STDOUT.sync = true

QUEUE_NAME = 'repository_enrollments_ruby'

def enroll_internal()
  stub = Services::RepositoryEnrollerService::Stub.new('localhost:5003', :this_channel_is_insecure)

  repository = Messages::Repository.new(
        "name" => 'protocol-ruby',
        "description" => "gRPC ruby example",
        "starts" => 234521,
        "code_frequency" => 5.45,
        "language_contributions" => {"go" => 54, "rust" => 23})

  response = stub.enroll(repository)

  puts "Response: #{response.inspect}"
end

def read_from_queue
  conn = Bunny.new
  conn.start

  ch = conn.create_channel
  queue  = ch.queue(QUEUE_NAME, :auto_delete => false)
  x  = ch.default_exchange

  queue.subscribe do |delivery_info, metadata, payload|
    puts " ===> Received bytes: #{payload.bytes}"
    puts " ===> Decoding payload..."

    decoded_repository = Messages::Repository.decode(payload)

    puts " ===> Decoded repository: #{decoded_repository.inspect}"
    puts
  end

  conn.close
end

def main
  if ARGV.empty?
    enroll_internal
    return
  end

  case ARGV[0]
  when 'r'
    read_from_queue
  end
end

main
