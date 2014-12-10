require 'octokit'

client = Octokit::Client.new :access_token => ENV['GITHUB_TOKEN']

client.add_comment("arfon/dottravis", ENV["TRAVIS_PULL_REQUEST"], "Done")
