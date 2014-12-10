require 'octokit'
require 'yaml'

@client = Octokit::Client.new(:access_token => ENV['GH_TOKEN'])

puts("check")
puts(ENV['TRAVIS_PULL_REQUEST'])
puts(ENV['TRAVIS_PULL_REQUEST'] != 'false')
puts(ENV['TRAVIS_PULL_REQUEST'] != "false")
puts(ENV['TRAVIS_PULL_REQUEST'] == false)

#if ENV['TRAVIS_PULL_REQUEST'] != 'false'

`travis-artifacts upload --path assets/result.png:result.png --target-path results/#{ENV['TRAVIS_PULL_REQUEST']}/`
image_url = "https://s3.amazonaws.com/#{ENV['ARTIFACTS_S3_BUCKET']}/results/#{ENV['TRAVIS_PULL_REQUEST']}/result.png"

@client.add_comment(ENV['TRAVIS_REPO_SLUG'], ENV['TRAVIS_PULL_REQUEST'], ":shipit: what up ![](#{image_url})")

puts("added")
result_path = 'result.csv'
scoreboard_path = 'scoreboard.csv'
all_paths = @client.contents(ENV['TRAVIS_REPO_SLUG'])

puts("have paths")
if not all_paths.map(&:path).include? scoreboard_path and File.exist?(result_path)
    # OK, let's create a scoreboard file

    submitter = @client.issue(ENV['TRAVIS_REPO_SLUG'],
      ENV['TRAVIS_PULL_REQUEST']).user.login
    parameters = YAML.load(@client.contents(ENV['TRAVIS_REPO_SLUG'],
        :path => ".travis.yml",
        :accept => "application/vnd.github.VERSION.raw")).model_parameters

    scoreboard_contents = '#' + parameters.join(',') + '\n'
    scoreboard_contents += submitter + ',' + File.load(result_path)
    puts(scoreboard_contents)

    @client.create_contents(ENV['TRAVIS_REPO_SLUG'],
      scoreboard_path,
      "Created the scoreboard [ci skip]",
      scoreboard_contents)

end
#end
