/*
Copyright © 2024 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"context"
	"devTool/utils"
	"fmt"
	"log"

	"github.com/onflow/cadence"
	"github.com/spf13/cobra"
)

// publishCmd represents the publish command
var publishCmd = &cobra.Command{
	Use:   "publish",
	Short: "Publishes a template",
	Long:  `Publishes a template by converting it to cadence value.`,
	Run: func(cmd *cobra.Command, args []string) {
		filePath, err := cmd.Flags().GetString("file")
		if err != nil {
			log.Fatal(err)
		}
		if filePath == "" {
			log.Fatal("Please provide a file path using --file flag")
		}

		network, err := cmd.Flags().GetString("network")
		if err != nil {
			log.Fatal(err)
		}
		if network == "" {
			log.Fatal("Please provide a flow network (mainnet, testnet) or a custom ID to the --network flag")
		}

		registryName, err := cmd.Flags().GetString("registry")
		cadanceRegistry, err := cadence.NewString(registryName)
		if err != nil {
			log.Fatalf("Error getting registry name as cadance value: %v", err)
		}

		alias, err := cmd.Flags().GetString("alias")
		cadanceAlias, err := cadence.NewString(alias)
		if err != nil {
			log.Fatalf("Error getting alias as cadance value: %v", err)
		}

		// Call GetTemplateAsCadanceValue with the provided file path
		txId, err := utils.GetTemplateAndPublish(context.Background(), filePath, network, cadanceAlias, cadanceRegistry)
		if err != nil {
			log.Fatalf("Error getting flix template as cadance value: %v", err)
		}

		fmt.Printf("Submitted TX: %v\n", txId)
	},
}

func init() {
	rootCmd.AddCommand(publishCmd)

	// Add a flag to the publish command to accept a file path
	publishCmd.Flags().String("file", "", "Path to the template file")

	// Add a flag to the publish command to accept a flow network name
	publishCmd.Flags().String("network", "", "Flow Nework (mainnet, testnet) or custom ID")

	publishCmd.Flags().String("registry", "main", "FLIX Registry Name - Default: main")

	publishCmd.Flags().String("alias", "", "FLIX Alias - Optional")

	// Mark the file flag as required
	err := publishCmd.MarkFlagRequired("file")
	if err != nil {
		log.Fatal(err)
	}

	// Mark the network flag as required
	err = publishCmd.MarkFlagRequired("network")
	if err != nil {
		log.Fatal(err)
	}
}
