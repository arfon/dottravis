require 'octokit'

@client = Octokit::Client.new(:access_token => ENV['GH_TOKEN'])

if pull_request_id = ENV['TRAVIS_PULL_REQUEST']
  `travis-artifacts upload --path assets/result.png:result.png --target-path results/#{ENV['TRAVIS_PULL_REQUEST']}/`
  image_url = "https://s3.amazonaws.com/#{ENV['ARTIFACTS_S3_BUCKET']}/results/#{ENV['TRAVIS_PULL_REQUEST']}/result.png"
  puts("adding comment")
  @client.add_comment(ENV['TRAVIS_REPO_SLUG'], ENV['TRAVIS_PULL_REQUEST'], ":shipit: ![](#{image_url})")

  ` Check to see if the file we want exists`
  scoreboard_path = 'scoreboard.csv'
  puts("getting contents")
  all_paths = @client.contents(ENV['TRAVIS_REPO_SLUG'])

  if not all_paths.map(&:path).include? scoreboard_path

    puts("create a scoreboard file..")
    ` OK, let's create a scoreboard file`
    parameters = ENV.grep(/^RESULT_/)
    scoreboard_contents = '# ' + parameters.join(', ') + '\n'
    scoreboard_contents += ENV['TRAVIS_BRANCH']
    scoreboard_contents += parameters.map { |x| ENV[x] }.join(',') + '\n'
    puts(scoreboard_contents)
#    @client.create_contents(ENV['TRAVIS_REPO_SLUG'],
#      scoreboard_path,
#      "Created the scoreboard",
#      scoreboard_contents)
  end
end
