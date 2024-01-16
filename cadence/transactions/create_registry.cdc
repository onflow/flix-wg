import "FLIXRegistry"

transaction(name: String) {

    prepare(signer: AuthAccount) {
        // Check if the account already has a Registry
        if signer.borrow<&FLIXRegistry.Registry>(from: FLIXRegistry.StoragePath(name: name)) == nil {
            // Create a new Registry resource
            let registry <- FLIXRegistry.createRegistry(name: name)

            // Save it with restricted access
            signer.save(<-registry, to: FLIXRegistry.StoragePath(name: name))
            signer.link<&FLIXRegistry.Registry{FLIXRegistry.Queryable, FLIXRegistry.Admin}>(FLIXRegistry.PublicPath(name: name), target: FLIXRegistry.StoragePath(name: name))
        }
    }
}