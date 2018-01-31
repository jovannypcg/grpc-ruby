this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'services_services_pb'
require 'messages_pb'

class RepositoryEnrollmentServer < Services::RepositoryEnrollerService::Service
  def enroll(repository, _something)
    puts repository.inspect

    Messages::EnrollmentResponse.new(ack: true)
  end
end

def main
  s = GRPC::RpcServer.new
  s.add_http2_port('0.0.0.0:5003', :this_port_is_insecure)
  s.handle(RepositoryEnrollmentServer)

  puts 'Listening on port 5003'
  s.run_till_terminated
end

main
