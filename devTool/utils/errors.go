package utils

// CustomError is a custom error type
type CustomError struct {
	message string
}

// Error returns the error message
func (e *CustomError) Error() string {
	return e.message
}

// NewCustomError creates a new instance of CustomError
func NewCustomError(message string) error {
	return &CustomError{message: message}
}
