package config

import (
	"fmt"
	"log"
	"os"
	"reflect"
	"strings"

	flowCfg "github.com/onflow/flowkit/config"
	flowJsonCfg "github.com/onflow/flowkit/config/json"
	"github.com/spf13/viper"
)

const (
	PrefixOrgManager   = "devtool"
	FlowConfigFileName = "flow.json"
	ToolConfigFileName = "tool.json"
)

var Cfg ToolConfig

type ToolConfig struct {
	FlowConfig   *flowCfg.Config
	ContractPath string            `json:"contractPath"`
	TxPath       string            `json:"txPath"`
	ScriptPath   string            `json:"scriptPath"`
	RegistryIDs  map[string]string `json:"registryIDs"`
}

func NewConfig() {
	viper.SetConfigFile(ToolConfigFileName)

	if err := viper.MergeInConfig(); err != nil {
		log.Fatalf("Error while reading tool.json. \n%+v\n Shutting down.", err)
	}

	var config ToolConfig
	// If available, use env vars for config
	for _, fieldName := range getFlattenedStructFields(reflect.TypeOf(config)) {
		envKey := strings.ToUpper(fmt.Sprintf("%s_%s", PrefixOrgManager, strings.ReplaceAll(fieldName, ".", "_")))
		envVar := os.Getenv(envKey)
		if envVar != "" {
			viper.Set(fieldName, envVar)
		}
	}

	if err := viper.Unmarshal(&config); err != nil {
		log.Fatalf("Error while creating config. \n%+v\n Shutting down.", err)
	}

	flowJSON, err := os.ReadFile(FlowConfigFileName)
	if err != nil {
		log.Fatalf("Error while reading flow.json. \n%+v\n Shutting down.", err)
	}

	config.FlowConfig, err = flowJsonCfg.NewParser().Deserialize(flowJSON)
	if err != nil {
		log.Fatalf("Error while reading flow.json. \n%+v\n Shutting down.", err)
	}

	Cfg = config
}

func getFlattenedStructFields(t reflect.Type) []string {
	return getFlattenedStructFieldsHelper(t, []string{})
}

func getFlattenedStructFieldsHelper(t reflect.Type, prefixes []string) []string {
	unwrappedT := t
	if t.Kind() == reflect.Pointer {
		unwrappedT = t.Elem()
	}

	flattenedFields := make([]string, 0)
	for i := 0; i < unwrappedT.NumField(); i++ {
		field := unwrappedT.Field(i)
		fieldName := field.Tag.Get("mapstructure")
		switch field.Type.Kind() {
		case reflect.Struct, reflect.Pointer:
			flattenedFields = append(flattenedFields, getFlattenedStructFieldsHelper(field.Type, append(prefixes, fieldName))...)
		default:
			flattenedField := fieldName
			if len(prefixes) > 0 {
				flattenedField = fmt.Sprintf("%s.%s", strings.Join(prefixes, "."), fieldName)
			}
			flattenedFields = append(flattenedFields, flattenedField)
		}
	}

	return flattenedFields
}
