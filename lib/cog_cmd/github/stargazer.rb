require "cog/command"
require_relative "helpers"

class CogCmd::Github::Stargazer < Cog::Command
  include CogCmd::Github::Helpers

  def run_command
    case subcommand
    when "list", nil
      list
    end
  end

  def list
    write_json(stargazers(repo))
  end

  def stargazers(repo)
    github.stargazers(repo, accept: "application/vnd.github.v3.star+json").map(&:to_h)
  end
end
