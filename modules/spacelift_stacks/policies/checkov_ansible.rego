package spacelift

warn [sprintf(message, [p])] {
	message := "This is the number of passed checks: %d"
	results := input.third_party_metadata.custom.checkov.results.passed_checks
    p := count(results)
}
sample = true


warn [sprintf(message, [p])] {
	message := "This is the number of failed checks: %d"
	results := input.third_party_metadata.custom.checkov.results.failed_checks
    p := count(results)
}
sample = true