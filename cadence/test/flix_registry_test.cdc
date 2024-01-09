import Test
import BlockchainHelpers
import "FLIXRegistry"

access(all) let REGISTRY_OWNER = Test.createAccount()
access(all) let TEMPLATE_ID = "aTestId"
access(all) let ALIAS = "anAlias"
access(all) let NEW_ALIAS = "aNewAlias"

access(all)
fun setup() {
    let err = Test.deployContract(
        name: "FLIXRegistry",
        path: "../contracts/flix_registry.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())
}

access(all)
fun testShouldEmitContractInitializedEvent() {
    let typ = Type<FLIXRegistry.ContractInitialized>()
    Test.assertEqual(1, Test.eventsOfType(typ).length)
}

access(all)
fun testShouldCreateRegistry() {
    let txResult = executeTransaction(
        "../transactions/create_registry.cdc",
        [],
        REGISTRY_OWNER
    )
    Test.expect(txResult, Test.beSucceeded())

    let scriptResult = executeScript(
        "../scripts/get_registry_size.cdc",
        [REGISTRY_OWNER.address]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let registrySize = scriptResult.returnValue! as! Int
    Test.assertEqual(0, registrySize)
}

access(all)
fun testShouldPublishFlix() {
    let jsonBody = "{\"some\":\"json body\"}"
    let cadenceBodyHash = "someHash"

    let txResult = executeTransaction(
        "../transactions/publish_flix.cdc",
        [ALIAS, TEMPLATE_ID, jsonBody, cadenceBodyHash],
        REGISTRY_OWNER
    )
    Test.expect(txResult, Test.beSucceeded())

    let typ = Type<FLIXRegistry.Published>()
    Test.assertEqual(1, Test.eventsOfType(typ).length)

    let scriptResult = executeScript(
        "../scripts/get_registry_size.cdc",
        [REGISTRY_OWNER.address]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let registrySize = scriptResult.returnValue! as! Int
    Test.assertEqual(1, registrySize)

    let lookupScriptResult = executeScript(
        "../scripts/lookup.cdc",
        [REGISTRY_OWNER.address, ALIAS]
    )

    Test.expect(lookupScriptResult, Test.beSucceeded())

    let flix = lookupScriptResult.returnValue! as! FLIXRegistry.FLIX
    Test.assertEqual(TEMPLATE_ID, flix.id)
    Test.assertEqual(jsonBody, flix.jsonBody)
    Test.assertEqual(cadenceBodyHash, flix.cadenceBodyHash)
    Test.assertEqual(FLIXRegistry.FLIXStatus.active, flix.status)

    let resolveScriptResult = executeScript(
        "../scripts/resolve.cdc",
        [REGISTRY_OWNER.address, cadenceBodyHash]
    )

    Test.expect(lookupScriptResult, Test.beSucceeded())

    let resolvedFlix = lookupScriptResult.returnValue! as! FLIXRegistry.FLIX
    Test.assertEqual(TEMPLATE_ID, resolvedFlix.id)
    Test.assertEqual(jsonBody, resolvedFlix.jsonBody)
    Test.assertEqual(cadenceBodyHash, resolvedFlix.cadenceBodyHash)
    Test.assertEqual(FLIXRegistry.FLIXStatus.active, resolvedFlix.status)
}

access(all)
fun testShouldLinkAlias() {
    let txResult = executeTransaction(
        "../transactions/link_alias.cdc",
        [NEW_ALIAS, TEMPLATE_ID],
        REGISTRY_OWNER
    )
    Test.expect(txResult, Test.beSucceeded())

    let typ = Type<FLIXRegistry.AliasLinked>()
    Test.assertEqual(1, Test.eventsOfType(typ).length)

    let scriptResult = executeScript(
        "../scripts/get_all_alias.cdc",
        [REGISTRY_OWNER.address]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let aliases = scriptResult.returnValue! as! {String: String}

    Test.assertEqual(TEMPLATE_ID, aliases[ALIAS]!)
    Test.assertEqual(TEMPLATE_ID, aliases[NEW_ALIAS]!)
}

access(all)
fun testShouldUnlinkAlias() {
    let txResult = executeTransaction(
        "../transactions/unlink_alias.cdc",
        [ALIAS],
        REGISTRY_OWNER
    )
    Test.expect(txResult, Test.beSucceeded())

    let typ = Type<FLIXRegistry.AliasUnlinked>()
    Test.assertEqual(1, Test.eventsOfType(typ).length)

    let scriptResult = executeScript(
        "../scripts/get_all_alias.cdc",
        [REGISTRY_OWNER.address]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let aliases = scriptResult.returnValue! as! {String: String}

    Test.assertEqual(nil, aliases[ALIAS])
    Test.assertEqual(TEMPLATE_ID, aliases[NEW_ALIAS]!)
}

access(all)
fun testShouldDeprecateFlixWithTemplateId() {
    let lookupScriptResultBefore = executeScript(
        "../scripts/lookup.cdc",
        [REGISTRY_OWNER.address, TEMPLATE_ID]
    )
    let flixBefore = lookupScriptResultBefore.returnValue! as! FLIXRegistry.FLIX
    Test.assertEqual(FLIXRegistry.FLIXStatus.active, flixBefore.status)

    let txResult = executeTransaction(
        "../transactions/deprecate_flix.cdc",
        [TEMPLATE_ID],
        REGISTRY_OWNER
    )
    Test.expect(txResult, Test.beSucceeded())

    let typ = Type<FLIXRegistry.Deprecated>()
    Test.assertEqual(1, Test.eventsOfType(typ).length)

    let lookupScriptResultAfter = executeScript(
        "../scripts/lookup.cdc",
        [REGISTRY_OWNER.address, TEMPLATE_ID]
    )

    Test.expect(lookupScriptResultAfter, Test.beSucceeded())

    let flixAfter = lookupScriptResultAfter.returnValue! as! FLIXRegistry.FLIX
    Test.assertEqual(FLIXRegistry.FLIXStatus.deprecated, flixAfter.status)
}

access(all)
fun testShouldRemoveFlix() {
    let removeTxResult = executeTransaction(
        "../transactions/remove_flix.cdc",
        [TEMPLATE_ID],
        REGISTRY_OWNER
    )
    Test.expect(removeTxResult, Test.beSucceeded())

    let typ = Type<FLIXRegistry.Removed>()
    Test.assertEqual(1, Test.eventsOfType(typ).length)

    let scriptResult = executeScript(
        "../scripts/get_registry_size.cdc",
        [REGISTRY_OWNER.address]
    )
    Test.expect(scriptResult, Test.beSucceeded())

    let registrySize = scriptResult.returnValue! as! Int
    Test.assertEqual(0, registrySize)
}
