import "FLIXRegistry"

transaction(alias: String, templateId: String, jsonBody: String, cadenceBodyHash: String) {

    prepare(signer: AuthAccount) {
        let registry = signer.borrow<&FLIXRegistry.Registry>(from: /storage/stableFlixRegistry)
                            ?? panic("Could not borrow a reference to the Registry")

        let newFlix = FLIXRegistry.FLIX(templateId: templateId, jsonBody: jsonBody, cadenceBodyHash: cadenceBodyHash)
        registry.publish(alias: alias, flix: newFlix)
    }
}