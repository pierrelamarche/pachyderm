package errutil

import (
	"fmt"
	"strings"
)

var (
	// ErrBreak is an error used to break out of call back based iteration,
	// should be swallowed by iteration functions and treated as successful
	// iteration.
	ErrBreak = fmt.Errorf("BREAK")
)

// IsAlreadyExistError returns true if err is due to trying to create a
// resource that already exists. It uses simple string matching, it's not
// terribly smart.
func IsAlreadyExistError(err error) bool {
	if err == nil {
		return false
	}
	return strings.Contains(err.Error(), "already exists")
}

// IsNotFoundError returns true if err is due to a resource not being found. It
// uses simple string matching, it's not terribly smart.
func IsNotFoundError(err error) bool {
	if err == nil {
		return false
	}
	return strings.Contains(err.Error(), "not found")
}

// IsInvalidNameError returns true if err is due to an invalid name
func IsInvalidNameError(err error) bool {
	if err == nil {
		return false
	}
	return strings.Contains(err.Error(), "only alphanumeric characters, underscores, and dashes are allowed")
}

// IsHasNoHeadError returns true if the err is due to an operation that cannot
// be performed on a headless branch
func IsHasNoHeadError(err error) bool {
	if err == nil {
		return false
	}
	return strings.Contains(err.Error(), "has no head")
}
