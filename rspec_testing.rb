require "rubygems"
require "json"
require "socket"

serverspec_results = `cd /rspec_tests ; sudo ruby -S rspec spec/localhost/ --format json`
parsed = JSON.parse(serverspec_results)

parsed["examples"].each do |serverspec_test|
  test_name = serverspec_test["file_path"].split('/')[-1] + "_" + serverspec_test["line_number"].to_s
  output = serverspec_test["full_description"].gsub!(/\"/, '')
  status = 0
  if serverspec_test["status"] != "passed"
    status = 1
  end
  conn = TCPSocket.new '127.0.0.1', 3030
  conn.puts %({"handlers": ["default"], "name": "#{test_name}", "output": #{output.to_json}, "status": #{status} })
  conn.close
end

puts parsed["summary_line"]
failures = parsed["summary_line"].split[2]
if failures == '0'
  exit 0
else
  exit 2
end
