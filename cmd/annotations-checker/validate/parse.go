package validate

import (
	"errors"
	"io"
	"net/http"
	"regexp"
	"strings"

	"github.com/google/go-github/v39/github"
)

type Annotations struct {
	SourceCode string
	TeamName   string
}

func Parse(client *github.Client, org, diffUrl string) (*Annotations, error) {
	// TODO: check that the diff is a add or a update not deletion
	diff, getDiffErr := getDiff(diffUrl)
	if getDiffErr != nil {
		return nil, getDiffErr
	}

	isNs := isNamespace(diff)

	if !isNs {
		return nil, nil
	}

	teamNameVal, teamNameErr := extractAnnoSubstr(diff, `cloud\-platform\.justice\.gov\.uk\/team\-name:(.*)`, "team-name")
	if teamNameErr != nil {
		return nil, teamNameErr
	}

	sourceCodeVal, sourceCodeErr := extractAnnoSubstr(diff, `cloud\-platform\.justice\.gov\.uk\/source\-code:(.*)`, "source-code")
	if sourceCodeErr != nil {
		return nil, sourceCodeErr
	}

	return &Annotations{
		sourceCodeVal,
		teamNameVal,
	}, nil
}

func getDiff(url string) (string, error) {
	resp, err := http.Get(url)
	if err != nil {
		return "", err
	}

	data, _ := io.ReadAll(resp.Body)

	defer resp.Body.Close()

	return string(data), nil
}

func isNamespace(url string) bool {
	if strings.Contains(string(url), "kind: Namespace") {
		return true
	}
	return false
}

func extractAnnoSubstr(diff, regex, annotationName string) (string, error) {
	re := regexp.MustCompile(regex)

	matches := re.FindStringSubmatch(diff)

	if len(matches) == 0 {
		return "", errors.New("no matches found for annotation " + annotationName)
	}

	return matches[1], nil
}
