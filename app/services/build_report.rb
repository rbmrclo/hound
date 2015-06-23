require "attr_extras"

class BuildReport
  MAX_COMMENTS = ENV.fetch("MAX_COMMENTS").to_i

  def self.run(pull_request, build)
    new(pull_request, build).run
  end

  pattr_initialize :pull_request, :build

  def run
    commenter.comment_on_violations(priority_violations)
    track_subscribed_build_completed
  end

  private

  def commenter
    Commenter.new(pull_request)
  end

  def token
    ENV.fetch("HOUND_GITHUB_TOKEN")
  end

  def violations
    build.violations
  end

  def priority_violations
    violations.take(MAX_COMMENTS)
  end

  def github
    @github ||= GithubApi.new(token)
  end

  def track_subscribed_build_completed
    if build.repo.subscription
      user = build.repo.subscription.user
      analytics = Analytics.new(user)
      analytics.track_build_completed(build.repo)
    end
  end
end
