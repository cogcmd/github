require "cog/command"
require_relative "helpers"

class CogCmd::Github::Merge < Cog::Command
  include CogCmd::Github::Helpers

  def run_command
    fail("Merge aborted: Repository not found.") if repo_missing?

    src = request.options['src']
    dest = request.options['dest']
    message = request.options['message']

    if branches_exist?([src, dest])
      response.template = "merge"
      response.content = merge(repo, src, dest, message)
    else
      fail("Merge aborted: Source and destination branch must exist.")
    end
  end

  private

  def repo_missing?
    !github.repository?(repo)
  end

  def branches_exist?(branch_list)
    @branches ||= github.branches(repo).map(&:name)
    (branch_list - @branches) == []
  end

  def merge(repo, src, dest, message)
    result = github.merge(repo, dest, src, commit_message: message)

    if result == ""
      { :message => "Nothing to merge" }
    else
      {
        repo: repo, src: src, dest: dest,
        sha: result.sha,
        timestamp: result.commit.author.date
      }
    end
  rescue Octokit::Conflict
    fail("Merge failed: Conflict merging #{src} into #{dest} for repo #{repo}.")
  end

end
