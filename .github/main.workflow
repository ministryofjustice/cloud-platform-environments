workflow "New workflow" {
  on = "pull_request"
  resolves = ["Notify #ask-cloud-platforms"]
}

action "Notify #ask-cloud-platforms" {
  uses = "Ilshidur/action-slack@2a8ddb6db23f71a413f9958ae75bbc32bbaa6385"
  secrets = ["SLACK_WEBHOOK"]
  args = "New PR opened: <{{ EVENT_PAYLOAD.pull_request.url }}|\\#{{ EVENT_PAYLOAD.pull_request.number }}>"
}
