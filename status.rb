require 'octokit'

@client = Octokit::Client.new(:access_token => ENV['GH_TOKEN'])

if pull_request_id = ENV['TRAVIS_PULL_REQUEST']
  `travis-artifacts upload --path assets/result.png --target-path results/#{ENV['TRAVIS_PULL_REQUEST']}/result.png`
  image_url = "https://s3.amazonaws.com/#{ENV['ARTIFACTS_S3_BUCKET']}/results/#{ENV['TRAVIS_PULL_REQUEST']}/result.png"
  @client.add_comment(ENV['TRAVIS_REPO_SLUG'], ENV['TRAVIS_PULL_REQUEST'], ":shipit: ![](#{image_url})")
end
