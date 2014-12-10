require 'octokit'

@client = Octokit::Client.new(:access_token => ENV['GH_TOKEN'])

puts("check")
puts(ENV['TRAVIS_PULL_REQUEST'])
puts(ENV['TRAVIS_PULL_REQUEST'] != "false")
if ENV['TRAVIS_PULL_REQUEST'] != "false"
  `travis-artifacts upload --path assets/result.png:result.png --target-path results/#{ENV['TRAVIS_PULL_REQUEST']}/`
  image_url = "https://s3.amazonaws.com/#{ENV['ARTIFACTS_S3_BUCKET']}/results/#{ENV['TRAVIS_PULL_REQUEST']}/result.png"
  
  @client.add_comment(ENV['TRAVIS_REPO_SLUG'], ENV['TRAVIS_PULL_REQUEST'], ":shipit: +1 ![](#{image_url})")

  puts("added")
  scoreboard_path = 'scoreboard.csv'
  all_paths = @client.contents(ENV['TRAVIS_REPO_SLUG'])

  puts("have paths")
  if not all_paths.map(&:path).include? scoreboard_path

    # OK, let's create a scoreboard file
    parameters = ENV.keys.grep(/^RESULT_/)
    puts("params")
    puts(parameters)
    puts("..")
    scoreboard_contents = '# ' + parameters.join(', ') + '\n'
    scoreboard_contents += ENV['TRAVIS_BRANCH']
    scoreboard_contents += parameters.map { |x| ENV[x] }.join(',') + '\n'
    puts(scoreboard_contents)
    
  end
end
