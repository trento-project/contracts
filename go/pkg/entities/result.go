package entities

import (
	"errors"
	"fmt"
)

type Validatable interface {
	Valid() error
}

type ResultError struct {
	Type    string
	Message string
}

func (e ResultError) Error() string {
	return fmt.Sprintf("error, type: %s, message: %s \n", e.Type, e.Message)
}

type FactResult struct {
	Value any          `json:"result"`
	Error *ResultError `json:"error"`
}

func (r *FactResult) HasError() bool {
	return r.Error != nil
}

func (r *FactResult) GetValueAsString() (string, error) {
	result, ok := r.Value.(string)
	if !ok {
		return "", errors.New("the value is not a string")
	}

	return result, nil
}

func (r *FactResult) GetValueAsBool() (bool, error) {
	result, ok := r.Value.(bool)
	if !ok {
		return false, errors.New("the value is not a boolean")
	}

	return result, nil
}
func (r *FactResult) GetValueAsFloat() (float64, error) {
	result, ok := r.Value.(float64)
	if !ok {
		return 0, errors.New("the value is not a float")
	}

	return result, nil
}
