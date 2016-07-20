require "octokit"

module CogCmd::Github::Helpers
  def github
    Octokit.auto_paginate = true
    Octokit::Client.new(access_token: access_token)
  end

  private

  def access_token
    ENV["GITHUB_ACCESS_TOKEN"]
  end
end
