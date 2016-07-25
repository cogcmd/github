require "active_support"
require "active_support/core_ext" # what'cha gonna do about it
require "cog/command"
require_relative "helpers"

class CogCmd::Github::Commit < Cog::Command
  include CogCmd::Github::Helpers

  def run_command
    case subcommand
    when "list", nil
      list
    end
  end

  # TODO: Fail if dates cannot be parsed
  def list
    if today?
      commits = commits_today(repo, branch)
    elsif yesterday?
      commits = commits_yesterday(repo, branch)
    elsif this_week?
      commits = commits_this_week(repo, branch)
    elsif last_week?
      commits = commits_last_week(repo, branch)
    elsif this_month?
      commits = commits_this_month(repo, branch)
    elsif after && before
      commits = commits_between(repo, branch, after, before)
    elsif after
      commits = commits_after(repo, branch, after)
    elsif before
      commits = commits_before(repo, branch, before)
    else
      commits = all_commits(repo, branch)
    end

    write_json(commits.map(&:to_h))
  end

  def commits_today(repo, branch)
    today = Date.today
    commits_after(repo, branch, serialize_date(today))
  end

  def commits_yesterday(repo, branch)
    today = Date.today
    yesterday = Date.yesterday
    commits_between(repo, branch, serialize_date(yesterday), serialize_date(today))
  end

  def commits_this_week(repo, branch)
    today = Date.today
    beginning_of_week = Date.today.beginning_of_week
    commits_between(repo, branch, serialize_date(beginning_of_week), serialize_date(today))
  end

  def commits_last_week(repo, branch)
    end_of_week = Date.today.beginning_of_week
    beginning_of_week = (end_of_week - 1.day).beginning_of_week
    commits_between(repo, branch, serialize_date(beginning_of_week), serialize_date(end_of_week))
  end

  def commits_this_month(repo, branch)
    today = Date.today
    beginning_of_month = Date.today.beginning_of_month
    commits_between(repo, branch, serialize_date(beginning_of_month), serialize_date(today))
  end

  def commits_between(repo, branch, after, before)
    if branch
      github.commits_between(repo, after, before, branch)
    else
      github.commits_between(repo, after, before)
    end
  end

  def commits_after(repo, branch, after)
    if branch
      github.commits_since(repo, after, branch)
    else
      github.commits_since(repo, after)
    end
  end

  def commits_before(repo, branch, before)
    if branch
      github.commits_before(repo, before, branch)
    else
      github.commits_before(repo, before)
    end
  end

  def all_commits(repo, branch)
    if branch
      github.commits(repo, branch).map(&:to_h)
    else
      github.commits(repo).map(&:to_h)
    end
  end

  private

  # TODO: What if the branch is named "list"?
  def branch
    if request.args.first == "list"
      request.args[1]
    else
      request.args.first
    end
  end

  def repo
    request.options["repo"]
  end

  def before
    request.options["before"]
  end

  def after
    request.options["after"]
  end

  def today?
    request.options["today"]
  end

  def yesterday?
    request.options["yesterday"]
  end

  def this_week?
    request.options["this-week"]
  end

  def last_week?
    request.options["last-week"]
  end

  def this_month?
    request.options["this-month"]
  end

  def serialize_date(date)
    date.strftime("%Y-%m-%d")
  end
end
