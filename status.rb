@client = Octokit::Client.new(:access_token => ENV['GH_TOKEN'])

if pull_request_id = ENV['TRAVIS_PULL_REQUEST']
  @client.create_commit_comment(ENV['TRAVIS_REPO_SLUG'], ENV['TRAVIS_COMMIT'], ":shipit:")
end
