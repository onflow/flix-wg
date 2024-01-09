import "FLIXRegistry"

transaction(id: String) {

    prepare(signer: AuthAccount) {
        // Borrow a reference to the Registry with removal capability
        let registry = signer.borrow<&FLIXRegistry.Registry{FLIXRegistry.Removable}>(from: /storage/stableFlixRegistry)
                            ?? panic("Could not borrow a reference to the Registry")

        // Remove the FLIX item using the provided id
        registry.remove(id: id)
    }
}
