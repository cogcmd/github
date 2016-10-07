require "cog/command"
require_relative "helpers"

class CogCmd::Github::Repo < Cog::Command
  include CogCmd::Github::Helpers

  def run_command
    case subcommand
    when "list", nil
      list
    when "info"
      info
    end
  end

  def list
    fail("Must provide a user or org") unless user || org

    if user
      repos = user_repos(user)
    elsif org
      repos = org_repos(org)
    end


    write_json(repos)
  end

  def info
    fail("Must provide a repo as the first argument") unless repo

    write_json(repo_info(repo))
  end

  def pr(repo, state = nil)
    options = {}

    if state
      options[:state] = state
    end

    github.pull_requests(repo, options).map(&:to_h)
  end

  def user_repos(user)
    github.repositories(user).map(&:to_h)
  end

  def org_repos(org)
    github.organization_repositories(org).map(&:to_h)
  end

  def repo_info(repo)
    github.repository(repo).to_h
  end

  private

  def user
    request.options["user"]
  end

  def org
    request.options["org"]
  end

  def repo
    request.args[1]
  end
end
