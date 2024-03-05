package v1_1

type InteractionTemplate struct {
	FType    string `json:"f_type"`
	FVersion string `json:"f_version"`
	ID       string `json:"id"`
	Data     Data   `json:"data"`
}

func (t InteractionTemplate) AsCadanceValue(s string) interface{} {
	//TODO: Fix cadence body hash
	return FLIX{
		ID:              t.ID,
		Data:            t.Data,
		CadenceBodyHash: t.Data.Cadence.Body,
		Status:          s,
	}
}

type FLIX struct {
	ID              string `json:"id"`
	Data            Data   `json:"data"`
	CadenceBodyHash string `json:"cadence_body_hash"`
	Status          string `json:"status"`
}

type Data struct {
	Type         string       `json:"type"`
	Interface    string       `json:"interface"`
	Messages     []Message    `json:"messages"`
	Cadence      Cadence      `json:"cadence"`
	Dependencies []Dependency `json:"dependencies"`
	Parameters   []Parameter  `json:"parameters"`
}

type Message struct {
	Key  string `json:"key"`
	I18n []I18n `json:"i18n"`
}

type I18n struct {
	Tag         string `json:"tag"`
	Translation string `json:"translation"`
}

type Cadence struct {
	Body        string       `json:"body"`
	NetworkPins []NetworkPin `json:"network_pins"`
}

type NetworkPin struct {
	Network string `json:"network"`
	PinSelf string `json:"pin_self"`
}

type Dependency struct {
	Contracts []Contract `json:"contracts"`
}

type Contract struct {
	Contract string    `json:"contract"`
	Networks []Network `json:"networks"`
}

type Network struct {
	Network                  string        `json:"network"`
	Address                  string        `json:"address"`
	DependencyPinBlockHeight uint64        `json:"dependency_pin_block_height"`
	DependencyPin            DependencyPin `json:"dependency_pin"`
}

// Updated from PinDetail
type DependencyPin struct {
	Pin                string   `json:"pin"`
	PinSelf            string   `json:"pin_self"`
	PinContractName    string   `json:"pin_contract_name"`
	PinContractAddress string   `json:"pin_contract_address"`
	Imports            []Import `json:"imports"`
}

type Import struct {
	Pin                string   `json:"pin"`
	PinSelf            string   `json:"pin_self"`
	PinContractName    string   `json:"pin_contract_name"`
	PinContractAddress string   `json:"pin_contract_address"`
	Imports            []Import `json:"imports"` // Recursive imports, if any
}

type Parameter struct {
	Label    string    `json:"label"`
	Index    int       `json:"index"`
	Type     string    `json:"type"`
	Messages []Message `json:"messages"`
}
