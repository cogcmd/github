require "cog/command"
require_relative "helpers"

class CogCmd::Github::Pr < Cog::Command
  include CogCmd::Github::Helpers

  def run_command
    case subcommand
    when "list", nil
      list
    end
  end

  def list
    if all?
      prs = pr(repo, :all)
    elsif closed?
      prs = pr(repo, :closed)
    elsif open?
      prs = pr(repo, :open)
    else
      prs = pr(repo)
    end

    write_json(prs)
  end

  def pr(repo, state = nil)
    options = {}

    if state
      options[:state] = state 
    end

    github.pull_requests(repo, options).map(&:to_h)
  end

  private

  def closed?
    request.options["closed"]
  end

  def all?
    request.options["all"]
  end

  def open?
    request.options["open"]
  end
end
