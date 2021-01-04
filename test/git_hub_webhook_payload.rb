module Mulukhiya
  class GitHubWebhookPayloadTest < TestCase
    def setup
      @payload = GitHubWebhookPayload.new(%({
        "action": "completed",
        "check_suite": {
          "id": 1760412598,
          "node_id": "MDEwOkNoZWNrU3VpdGUxNzYwNDEyNTk4",
          "head_branch": "4_0_24",
          "head_sha": "8d18e3dc3230c4b674c05064d3f41dd9b5cbcb67",
          "status": "completed",
          "conclusion": "success",
          "url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/check-suites/1760412598",
          "before": "0b6a249f4679ec599d86d8280607dc36c1201e9f",
          "after": "8d18e3dc3230c4b674c05064d3f41dd9b5cbcb67",
          "pull_requests": [
            
          ],
          "app": {
            "id": 15368,
            "slug": "github-actions",
            "node_id": "MDM6QXBwMTUzNjg=",
            "owner": {
              "login": "github",
              "id": 9919,
              "node_id": "MDEyOk9yZ2FuaXphdGlvbjk5MTk=",
              "avatar_url": "https://avatars1.githubusercontent.com/u/9919?v=4",
              "gravatar_id": "",
              "url": "https://api.github.com/users/github",
              "html_url": "https://github.com/github",
              "followers_url": "https://api.github.com/users/github/followers",
              "following_url": "https://api.github.com/users/github/following{/other_user}",
              "gists_url": "https://api.github.com/users/github/gists{/gist_id}",
              "starred_url": "https://api.github.com/users/github/starred{/owner}{/repo}",
              "subscriptions_url": "https://api.github.com/users/github/subscriptions",
              "organizations_url": "https://api.github.com/users/github/orgs",
              "repos_url": "https://api.github.com/users/github/repos",
              "events_url": "https://api.github.com/users/github/events{/privacy}",
              "received_events_url": "https://api.github.com/users/github/received_events",
              "type": "Organization",
              "site_admin": false
            },
            "name": "GitHub Actions",
            "description": "Automate your workflow from idea to production",
            "external_url": "https://help.github.com/en/actions",
            "html_url": "https://github.com/apps/github-actions",
            "created_at": "2018-07-30T09:30:17Z",
            "updated_at": "2019-12-10T19:04:12Z",
            "permissions": {
              "actions": "write",
              "checks": "write",
              "contents": "write",
              "deployments": "write",
              "issues": "write",
              "metadata": "read",
              "packages": "write",
              "pages": "write",
              "pull_requests": "write",
              "repository_hooks": "write",
              "repository_projects": "write",
              "security_events": "write",
              "statuses": "write",
              "vulnerability_alerts": "read"
            },
            "events": [
              "check_run",
              "check_suite",
              "create",
              "delete",
              "deployment",
              "deployment_status",
              "fork",
              "gollum",
              "issues",
              "issue_comment",
              "label",
              "milestone",
              "page_build",
              "project",
              "project_card",
              "project_column",
              "public",
              "pull_request",
              "pull_request_review",
              "pull_request_review_comment",
              "push",
              "registry_package",
              "release",
              "repository",
              "repository_dispatch",
              "status",
              "watch",
              "workflow_dispatch",
              "workflow_run"
            ]
          },
          "created_at": "2021-01-04T02:12:13Z",
          "updated_at": "2021-01-04T02:15:22Z",
          "latest_check_runs_count": 1,
          "check_runs_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/check-suites/1760412598/check-runs",
          "head_commit": {
            "id": "8d18e3dc3230c4b674c05064d3f41dd9b5cbcb67",
            "tree_id": "1ba6bd90995e38ff1fd5a64998bb4991ea0027e7",
            "message": "#1787",
            "timestamp": "2021-01-04T02:12:01Z",
            "author": {
              "name": "Tatsuya Koishi",
              "email": "tkoishi@b-shock.co.jp"
            },
            "committer": {
              "name": "Tatsuya Koishi",
              "email": "tkoishi@b-shock.co.jp"
            }
          }
        },
        "repository": {
          "id": 137868056,
          "node_id": "MDEwOlJlcG9zaXRvcnkxMzc4NjgwNTY=",
          "name": "mulukhiya-toot-proxy",
          "full_name": "pooza/mulukhiya-toot-proxy",
          "private": false,
          "owner": {
            "login": "pooza",
            "id": 995262,
            "node_id": "MDQ6VXNlcjk5NTI2Mg==",
            "avatar_url": "https://avatars2.githubusercontent.com/u/995262?v=4",
            "gravatar_id": "",
            "url": "https://api.github.com/users/pooza",
            "html_url": "https://github.com/pooza",
            "followers_url": "https://api.github.com/users/pooza/followers",
            "following_url": "https://api.github.com/users/pooza/following{/other_user}",
            "gists_url": "https://api.github.com/users/pooza/gists{/gist_id}",
            "starred_url": "https://api.github.com/users/pooza/starred{/owner}{/repo}",
            "subscriptions_url": "https://api.github.com/users/pooza/subscriptions",
            "organizations_url": "https://api.github.com/users/pooza/orgs",
            "repos_url": "https://api.github.com/users/pooza/repos",
            "events_url": "https://api.github.com/users/pooza/events{/privacy}",
            "received_events_url": "https://api.github.com/users/pooza/received_events",
            "type": "User",
            "site_admin": false
          },
          "html_url": "https://github.com/pooza/mulukhiya-toot-proxy",
          "description": "Mastodon / Misskey / Pleroma / めいすきーの投稿に対して、内容の更新等を行うプロキシ。通称「モロヘイヤ」。",
          "fork": false,
          "url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy",
          "forks_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/forks",
          "keys_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/keys{/key_id}",
          "collaborators_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/collaborators{/collaborator}",
          "teams_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/teams",
          "hooks_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/hooks",
          "issue_events_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/issues/events{/number}",
          "events_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/events",
          "assignees_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/assignees{/user}",
          "branches_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/branches{/branch}",
          "tags_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/tags",
          "blobs_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/git/blobs{/sha}",
          "git_tags_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/git/tags{/sha}",
          "git_refs_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/git/refs{/sha}",
          "trees_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/git/trees{/sha}",
          "statuses_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/statuses/{sha}",
          "languages_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/languages",
          "stargazers_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/stargazers",
          "contributors_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/contributors",
          "subscribers_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/subscribers",
          "subscription_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/subscription",
          "commits_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/commits{/sha}",
          "git_commits_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/git/commits{/sha}",
          "comments_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/comments{/number}",
          "issue_comment_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/issues/comments{/number}",
          "contents_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/contents/{+path}",
          "compare_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/compare/{base}...{head}",
          "merges_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/merges",
          "archive_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/{archive_format}{/ref}",
          "downloads_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/downloads",
          "issues_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/issues{/number}",
          "pulls_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/pulls{/number}",
          "milestones_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/milestones{/number}",
          "notifications_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/notifications{?since,all,participating}",
          "labels_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/labels{/name}",
          "releases_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/releases{/id}",
          "deployments_url": "https://api.github.com/repos/pooza/mulukhiya-toot-proxy/deployments",
          "created_at": "2018-06-19T09:14:20Z",
          "updated_at": "2020-12-31T09:52:15Z",
          "pushed_at": "2021-01-04T02:12:11Z",
          "git_url": "git://github.com/pooza/mulukhiya-toot-proxy.git",
          "ssh_url": "git@github.com:pooza/mulukhiya-toot-proxy.git",
          "clone_url": "https://github.com/pooza/mulukhiya-toot-proxy.git",
          "svn_url": "https://github.com/pooza/mulukhiya-toot-proxy",
          "homepage": "",
          "size": 5491,
          "stargazers_count": 10,
          "watchers_count": 10,
          "language": "Ruby",
          "has_issues": true,
          "has_projects": false,
          "has_downloads": true,
          "has_wiki": true,
          "has_pages": false,
          "forks_count": 1,
          "mirror_url": null,
          "archived": false,
          "disabled": false,
          "open_issues_count": 19,
          "license": {
            "key": "mit",
            "name": "MIT License",
            "spdx_id": "MIT",
            "url": "https://api.github.com/licenses/mit",
            "node_id": "MDc6TGljZW5zZTEz"
          },
          "forks": 1,
          "open_issues": 19,
          "watchers": 10,
          "default_branch": "master"
        },
        "sender": {
          "login": "pooza",
          "id": 995262,
          "node_id": "MDQ6VXNlcjk5NTI2Mg==",
          "avatar_url": "https://avatars2.githubusercontent.com/u/995262?v=4",
          "gravatar_id": "",
          "url": "https://api.github.com/users/pooza",
          "html_url": "https://github.com/pooza",
          "followers_url": "https://api.github.com/users/pooza/followers",
          "following_url": "https://api.github.com/users/pooza/following{/other_user}",
          "gists_url": "https://api.github.com/users/pooza/gists{/gist_id}",
          "starred_url": "https://api.github.com/users/pooza/starred{/owner}{/repo}",
          "subscriptions_url": "https://api.github.com/users/pooza/subscriptions",
          "organizations_url": "https://api.github.com/users/pooza/orgs",
          "repos_url": "https://api.github.com/users/pooza/repos",
          "events_url": "https://api.github.com/users/pooza/events{/privacy}",
          "received_events_url": "https://api.github.com/users/pooza/received_events",
          "type": "User",
          "site_admin": false
        }
      }))
    end

    def test_action
      assert_equal(@payload.action, 'completed')
    end

    def test_check_suite
      assert_equal(@payload.check_suite, {conclusion: 'success', url: nil})
   end
 end
end
