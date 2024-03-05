/*
Copyright © 2024 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"devTool/utils"
	"log"

	"github.com/onflow/cadence"
	"github.com/spf13/cobra"
)

// createRegistryCmd represents the createRegistry command
var createRegistryCmd = &cobra.Command{
	Use:   "createRegistry",
	Short: "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	Run: func(cmd *cobra.Command, args []string) {
		name, _ := cmd.Flags().GetString("name")

		network, err := cmd.Flags().GetString("network")
		if err != nil {
			log.Fatal(err)
		}
		if network == "" {
			log.Fatal("Please provide a flow network (mainnet, testnet) or a custom ID to the --network flag")
		}

		cadenceName, err := cadence.NewString(name)
		if err != nil {
			log.Fatal(err)
		}

		utils.RunFlowTx(network, "create_registry", cadenceName)
	},
}

func init() {
	rootCmd.AddCommand(createRegistryCmd)

	// Add a flag to the publish command to accept a file path
	createRegistryCmd.Flags().String("name", "main", "FLIX Registry Name - Default: main")

	// Add a flag to the publish command to accept a flow network name
	createRegistryCmd.Flags().String("network", "", "Flow Nework (mainnet, testnet) or custom ID")
}
