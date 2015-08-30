require 'aws-sdk'
require 'json'
require 'pp'

creds = JSON.load(File.read('secrets.json'))
config = JSON.load(File.read('config.json'))

devicefarm = Aws::DeviceFarm::Client.new(
	region: 'us-west-2',
	credentials: Aws::Credentials.new(creds['AccessKeyId'], creds['SecretAccessKey']),
)

resp = devicefarm.get_project({
  arn: config['ProjectArn'],
})

puts 'get_project:'
puts 'ProjectName ' + resp.project.name
puts 'ProjectArn ' + resp.project.arn
puts '------'

list_uploads_resp = devicefarm.list_uploads({
  arn: config['ProjectArn']
})

puts 'list_uploads:'
pp list_uploads_resp
puts '------'
puts ''

list_runs_resp = devicefarm.list_runs({
  arn: config['ProjectArn']
})

puts 'list_runs:'
pp list_runs_resp
puts '------'
puts ''

list_device_pools_resp = devicefarm.list_device_pools({
  arn: config['ProjectArn']
})

puts 'list_device_pools:'
pp list_device_pools_resp
puts '------'
puts ''

app_arn = []
app_arn_test = []
for upload in list_uploads_resp.uploads do
  if upload.type == 'ANDROID_APP'
    app_arn.push upload.arn
  else upload.type == 'CALABASH_TEST_PACKAGE' 
    app_arn_test.push upload.arn
  end
end

p app_arn
p app_arn_test

schedule_run_resp = devicefarm.schedule_run({
  project_arn: config['ProjectArn'],
  app_arn: app_arn[0],
  device_pool_arn: list_device_pools_resp.device_pools[0].arn,
  test: {
    type: 'CALABASH',
    test_package_arn: app_arn_test[0]
  }
})

puts 'schedule_run:'
pp schedule_run_resp