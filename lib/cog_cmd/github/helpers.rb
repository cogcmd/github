require "octokit"

module CogCmd::Github::Helpers
  def github
    Octokit.auto_paginate = true
    Octokit::Client.new(access_token: access_token)
  end

  def subcommand
    request.args.first
  end

  def repo
    request.options["repo"]
  end

  def write_json(json, template = nil)
    response.content = json

    if template
      response.template = template
    end

    response
  end

  def write_string(string)
    response["body"] = string
    response
  end

  private

  def access_token
    ENV["GITHUB_ACCESS_TOKEN"]
  end
end
