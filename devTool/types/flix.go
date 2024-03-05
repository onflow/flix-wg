package types

type VerCheck struct {
	FVersion string `json:"f_version"`
}

type FlixInterface interface {
	AsCadanceValue(s string) interface{}
}
