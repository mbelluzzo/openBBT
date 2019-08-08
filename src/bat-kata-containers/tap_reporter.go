/*

TAP reporter for ginkgo

*/

package reporters

import (
	"fmt"
	"os"
	"strings"

	"github.com/onsi/ginkgo/config"
	"github.com/onsi/ginkgo/types"
)

type TapReporter struct {
	filename string
	suite    TapTestSuite
	//writer   io.Writer
}

type TapTestSuite struct {
	TestCases []TapTestCase
	Tests     int
}

type TapTestCase struct {
	Name    string
	Message string
	Details string
}

// use of an empty string for filename sends all logging to stdout
func NewTapReporter(filename string) *TapReporter {
	return &TapReporter{
		filename: filename,
	}
}

func (reporter *TapReporter) SpecSuiteWillBegin(config config.GinkgoConfigType, summary *types.SuiteSummary) {
	reporter.suite = TapTestSuite{
		Tests: summary.NumberOfSpecsThatWillBeRun,
	}
	msg := fmt.Sprintf("TAP version 13\n1..%d\n", summary.NumberOfSpecsThatWillBeRun)
	LogOutput(msg, reporter.filename)
}

func (reporter *TapReporter) BeforeSuiteDidRun(suiteSummary *types.SetupSummary) {
}

func (reporter *TapReporter) SpecWillRun(specSummary *types.SpecSummary) {
}

func (reporter *TapReporter) SpecDidComplete(specSummary *types.SpecSummary) {
    testName := escape(strings.Join(specSummary.ComponentTexts[1:], " "))
    state := specSummary.State

    testLine := ""
    yaml := ""

    switch state {
    case types.SpecStatePassed:
        testLine = fmt.Sprintf("ok %s\n", testName)
        yaml = GetDurationYaml(specSummary)
    case types.SpecStateSkipped:
        testLine = fmt.Sprintf("ok # skip %s\n", testName)
        yaml = GetDurationYaml(specSummary)
    case types.SpecStateFailed, types.SpecStateTimedOut, types.SpecStatePanicked:
        testLine = fmt.Sprintf("not ok %s\n", testName)
        yaml = GetDurationYaml(specSummary)
    }

    msg := fmt.Sprintf("%s%s", testLine, yaml)

    LogOutput(msg, reporter.filename)
}

func GetDurationYaml(specSummary *types.SpecSummary) string {
    durationInMilliseconds := int(specSummary.RunTime.Seconds() * 1000)
    yaml := fmt.Sprintf("  ---\n  duration_ms: %d\n  ...\n", durationInMilliseconds)
    return yaml
}

func (reporter *TapReporter) AfterSuiteDidRun(setupSummary *types.SetupSummary) {
}

func (reporter *TapReporter) SpecSuiteDidEnd(summary *types.SuiteSummary) {
}

func LogOutput(msg string, filename string) {
	if len(filename) <= 0 {
		fmt.Printf(msg)
	} else {
		LogToFile(filename, msg)
	}
}

func LogToFile(filename string, appendable string) {
	file, err := os.OpenFile(
		filename, os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0644)
	if err != nil {
		fmt.Printf("Failed opening log file: %s", err)
	}
	defer file.Close()
	if _, err := file.Write([]byte(appendable)); err != nil {
		fmt.Printf("Failed writting to log file: %s", err)
	}
}
