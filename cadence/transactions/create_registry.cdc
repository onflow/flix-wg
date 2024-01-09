import "FLIXRegistry"

transaction {

    prepare(signer: AuthAccount) {
        // Check if the account already has a Registry
        if signer.borrow<&FLIXRegistry.Registry>(from: /storage/stableFlixRegistry) == nil {
            // Create a new Registry resource
            let registry <- FLIXRegistry.createRegistry()

            // Save it with restricted access
            signer.save(<-registry, to: /storage/stableFlixRegistry)
            signer.link<&FLIXRegistry.Registry{FLIXRegistry.Queryable, FLIXRegistry.Admin}>(/public/stableFlixRegistryPublic, target: /storage/stableFlixRegistry)
        }
    }
}