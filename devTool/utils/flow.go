package utils

import (
	"context"
	"devTool/config"
	"devTool/types"
	v1 "devTool/types/v1"
	"devTool/types/v1_1"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path"

	"github.com/bjartek/underflow"
	"github.com/onflow/cadence"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/access/grpc"
	"github.com/onflow/flow-go-sdk/crypto"
)

func RunFlowTx(network string, name string, args ...cadence.Value) (string, error) {
	networkCfg, err := config.Cfg.FlowConfig.Networks.ByName(network)
	if err != nil {
		return "", err
	}

	client, err := grpc.NewClient(networkCfg.Host)
	if err != nil {
		log.Fatalf("Unable To Init Flow Client: %s", err)
	}

	ctx := context.Background()

	accountCfg, err := config.Cfg.FlowConfig.Accounts.ByName(network + "-account")
	if err != nil {
		return "", err
	}

	account, err := client.GetAccount(ctx, accountCfg.Address)
	if err != nil {
		return "", err
	}

	key := account.Keys[0]

	signer, err := crypto.NewInMemorySigner(accountCfg.Key.PrivateKey, key.HashAlgo)
	if err != nil {
		return "", err
	}

	refBlock, err := client.GetLatestBlock(ctx, true)
	if err != nil {
		return "", err
	}

	script, err := getCadence(name, "transaction")
	if err != nil {
		return "", err
	}

	tx := flow.NewTransaction().
		SetScript(script).
		SetComputeLimit(999).
		SetProposalKey(account.Address, key.Index, key.SequenceNumber).
		SetReferenceBlockID(refBlock.ID).
		SetPayer(account.Address).
		AddAuthorizer(account.Address)

	for _, arg := range args {
		err = tx.AddArgument(arg)
		if err != nil {
			return "", err
		}
	}

	err = tx.SignEnvelope(account.Address, key.Index, signer)
	if err != nil {
		return "", err
	}

	err = client.SendTransaction(ctx, *tx)
	if err != nil {
		return "", err
	}

	return tx.ID().String(), nil
}

func GetTemplateAndPublish(ctx context.Context, filePath string, network string, alias cadence.Value, registry cadence.Value) (string, error) {
	template, err := os.ReadFile(filePath)
	if err != nil {
		return "", err
	}

	var ver types.VerCheck
	err = json.Unmarshal(template, &ver)
	if err != nil {
		return "", err
	}

	switch ver.FVersion {
	case "1.0.0":
		var v1Template v1.FlowInteractionTemplate

		err := json.Unmarshal(template, &v1Template)
		if err != nil {
			return "", err
		}

		flix, err := flixToCadanceValue(v1Template, network)
		if err != nil {
			return "", err
		}

		return RunFlowTx(network, "", alias, flix, registry)
	case "1.1.0":
		var v1_1Template v1_1.InteractionTemplate

		err := json.Unmarshal(template, &v1_1Template)
		if err != nil {
			return "", err
		}

		flix, err := flixToCadanceValue(v1_1Template, network)
		if err != nil {
			return "", err
		}

		fmt.Printf("%+v\n", flix)

		return RunFlowTx(network, "publish_flix_v1_1_0", alias, flix, registry)
	}

	return "", NewCustomError("Invalid FLIX Schema Version")

}

func flixToCadanceValue(flix types.FlixInterface, network string) (cadence.Value, error) {
	resolver := func(s string) (string, error) {
		return config.Cfg.RegistryIDs[network] + "." + s, nil
	}

	return underflow.InputToCadence(flix.AsCadanceValue("active"), resolver)
}

func getCadence(name, cType string) ([]byte, error) {
	name = name + ".cdc"

	var codePath string
	switch cType {
	case "transaction":
		codePath = path.Join(config.Cfg.TxPath, name)
	case "script":
		codePath = path.Join(config.Cfg.ScriptPath, name)
	case "contract":
		codePath = path.Join(config.Cfg.ContractPath, name)
	}

	codeBytes, err := os.ReadFile(codePath)
	if err != nil {
		return nil, err
	}

	return codeBytes, nil
}
