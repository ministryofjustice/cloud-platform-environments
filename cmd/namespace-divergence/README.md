Namespace Divergence

Namespace Divergence is a tool that cross-references the namespaces in your Kubernetes cluster with the namespaces directory in the GitHub repository `ministryofjustice/cloud-platform-environments`. If a divergence is found, it can send a slack message or just print to screen. This way, you can be sure that accedental namespaces don't exist and ensure your data is always up-to-date, without spending hours doing manual checks.

You can run the namespace divergence command if you have go by running:

```bash
go run divergence.go -p <personal_access_token> -kubeconfig <path_to_kubeconfig> -slackApi <OAUTH_token> -channelId <slack_channel_id_integer>
```

> The only flag you have to provide is personal access token. The others can be implied or ignored.

You can test the command with:

```bash
go test -v ./...
```
