this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'services_services_pb'
require 'messages_pb'
require 'bunny'

STDOUT.sync = true

class RepositoryEnrollmentServer < Services::RepositoryEnrollerService::Service
  QUEUE_NAME = 'repository_enrollments_ruby'

  def enroll(repository, _something)
    encoded_repository = Messages::Repository.encode(repository)

    puts "Incoming repository: #{repository.inspect}"
    puts "Encoded repository : #{encoded_repository}"
    puts "Encoded bytes      : #{encoded_repository.bytes}"

    enqueue(encoded_repository)

    Messages::EnrollmentResponse.new(ack: true)
  end
end

def enqueue(encoded_repository)
  conn = Bunny.new
  conn.start

  ch = conn.create_channel
  queue = ch.queue(RepositoryEnrollmentServer::QUEUE_NAME, :auto_delete => false)
  x  = ch.default_exchange

  puts "Attempting to enqueue #{encoded_repository.bytes}"
  x.publish(encoded_repository, :routing_key => queue.name)

  conn.close
end

def main
  s = GRPC::RpcServer.new
  s.add_http2_port('0.0.0.0:5003', :this_port_is_insecure)
  s.handle(RepositoryEnrollmentServer)

  puts 'Listening on port 5003'
  s.run_till_terminated
end

main
