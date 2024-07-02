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

func Parse(client *github.Client, org, diff string) (*Annotations, error) {
	isNs := isNamespace(diff)
	if !isNs {
		return nil, nil
	}

	teamNameVal, teamNameErr := extractAnnoSubstr(diff, `cloud\-platform\.justice\.gov\.uk\/team\-name:\s*"?([^"\n]+)"?`, "team-name")
	if teamNameErr != nil {
		// fmt.Printf("error extracting team name: %v\n", teamNameErr)
		return nil, teamNameErr
	}

	// sourceCodeVal, sourceCodeErr := extractAnnoSubstr(diff, `cloud-platform\.justice\.gov\.uk\/source-code:\s*"?(https:://github\.com/ministryofjustice/[^"\n]+)"?`, "source-code")
	// if sourceCodeErr != nil {
	// 	return nil, sourceCodeErr
	// }
	sourceCodeVal, sourceCodeErr := extractAnnoSubstr(diff, `cloud\-platform\.justice\.gov\.uk\/source-code:\s*"?([^"\n]+)"?`, "source-code")
	if sourceCodeErr != nil {
		// fmt.Printf("error extracting source code: %v\n", sourceCodeErr)
		return nil, sourceCodeErr
	}
	// fmt.Printf("extracted source code: %s\n", sourceCodeVal)

	valid, validationMsg := Validate(client, org, &Annotations{})
	if !valid {
		return nil, errors.New(validationMsg)
	}

	return &Annotations{
		SourceCode: sourceCodeVal,
		TeamName:   teamNameVal,
	}, nil
}

func GetDiff(url string) (string, error) {
	resp, err := http.Get(url)
	if err != nil {
		return "", err
	}

	data, _ := io.ReadAll(resp.Body)

	defer resp.Body.Close()

	return string(data), nil
}

func isNamespace(diff string) bool {
	return strings.Contains(diff, "kind: Namespace")
}

func extractAnnoSubstr(diff, regex, annotationName string) (string, error) {
	re := regexp.MustCompile(regex)

	matches := re.FindStringSubmatch(diff)

	if len(matches) == 0 {
		return "", errors.New("no matches found for annotation " + annotationName)
	}

	return matches[1], nil
}
