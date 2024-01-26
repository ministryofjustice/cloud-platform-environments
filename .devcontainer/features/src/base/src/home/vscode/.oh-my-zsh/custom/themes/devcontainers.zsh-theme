# Oh My Zsh! theme - partly inspired by https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/robbyrussell.zsh-theme
# Source: https://github.com/devcontainers/features/blob/main/src/common-utils/scripts/devcontainers.zsh-theme

__zsh_prompt() {
    local prompt_username
    if [ ! -z "${GITHUB_USER}" ]; then 
        prompt_username="@${GITHUB_USER}"
    else
        prompt_username="%n"
    fi
    PROMPT="%{$fg[green]%}${prompt_username} %(?:%{$reset_color%}➜ :%{$fg_bold[red]%}➜ )" # User/exit code arrow
    PROMPT+='%{$fg_bold[blue]%}%(5~|%-1~/…/%3~|%4~)%{$reset_color%} ' # cwd
    PROMPT+='`\
        if [ "$(git config --get devcontainers-theme.hide-status 2>/dev/null)" != 1 ] && [ "$(git config --get codespaces-theme.hide-status 2>/dev/null)" != 1 ]; then \
            export BRANCH=$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git --no-optional-locks rev-parse --short HEAD 2>/dev/null); \
            if [ "${BRANCH}" != "" ]; then \
                echo -n "%{$fg_bold[cyan]%}(%{$fg_bold[red]%}${BRANCH}" \
                && if [ "$(git config --get devcontainers-theme.show-dirty 2>/dev/null)" = 1 ] && \
                    git --no-optional-locks ls-files --error-unmatch -m --directory --no-empty-directory -o --exclude-standard ":/*" > /dev/null 2>&1; then \
                        echo -n " %{$fg_bold[yellow]%}✗"; \
                fi \
                && echo -n "%{$fg_bold[cyan]%})%{$reset_color%} "; \
            fi; \
        fi`'

    # Kubernetes
    if command -v kubectl &> /dev/null; then
      PROMPT+='`\
          kubectlVersion=$(kubectl version --client true --output json | jq -r .clientVersion.gitVersion | sed "s/v//"); \
          kubectlCurrentContext=$(kubectl config current-context 2>/dev/null); \
          kubectlCurrentNamespace=$(kubectl config view --minify --output 'jsonpath={..namespace}'); \
          kubectlClientId=$(kubectl config view --output json | jq -r ".users[0].user[\"auth-provider\"].config[\"client-id\"]"); \
          kubectlServerVersion=$(kubectl version --output json 2>/dev/null | jq -r .serverVersion.gitVersion | sed "s/v//"); \
          echo -n "[ kubectl: %{$fg[blue]%}${kubectlVersion}%{$reset_color%} ] " \
          && if [[ "${kubectlCurrentContext}" == "live" ]] && [[ "${kubectlClientId}" == "REPLACE_WITH_CLIENT_ID" ]]; then \
            echo -n "[ cluster: %{$fg[yellow]%}${kubectlCurrentContext} (requires authentication)%{$reset_color%} ] "; \
          elif [[ "${kubectlCurrentContext}" == "live" ]] && [[ ! -z "${kubectlServerVersion}" ]]; then \
            echo -n "[ cluster: %{$fg[green]%}${kubectlCurrentContext} (authenticated)%{$reset_color%} ] "; \
          else
            echo -n "[ cluster: %{$fg[red]%}${kubectlCurrentContext} (issue with authentication)%{$reset_color%} ] "; \
          fi \
          && if [[ ! -z "${kubectlCurrentNamespace}" ]] && [[ "${kubectlCurrentNamespace}" == *"-prod"* ]]; then \
            echo -n "[ namespace: %{$fg[red]%}${kubectlCurrentNamespace}%{$reset_color%} ] "; \
          elif [[ ! -z "${kubectlCurrentNamespace}" ]]; then \
            echo -n "[ namespace: %{$fg[green]%}${kubectlCurrentNamespace}%{$reset_color%} ] "; \
          fi \
      `'
    fi

    PROMPT+='%{$fg[white]%}$ %{$reset_color%}'
    unset -f __zsh_prompt
}
__zsh_prompt
