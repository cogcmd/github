require "cog/command"
require_relative "helpers"

class CogCmd::Github::Stars < Cog::Command
  include CogCmd::Github::Helpers

  def run_command
    response.content = stargazers(repo)
    response
  end

  def stargazers(repo)
    github.stargazers(repo, accept: "application/vnd.github.v3.star+json").map(&:to_h)
  end

  def repo
    request.args.first
  end
end
