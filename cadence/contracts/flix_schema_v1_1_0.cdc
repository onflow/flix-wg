import "FLIXRegistryInterface"
import "FLIXRegistry"

access(all) 
contract FLIXSchema_v1_1_0 {

    access(all) 
    struct FLIX: FLIXRegistryInterface.InteractionTemplate {
        access(all)
        let id: String

        access(all)
        let data: Data

        access(all)
        let cadence_body_hash: String

        access(all)
        fun getId(): String {
            return self.id
        }

        access(all)
        fun getData(): Data {
            return self.data
        }

        access(all)
        fun getVersion(): String {
            return "1.1.0"
        }

        access(all)
        fun getCadenceBodyHash(): String {
            return self.cadence_body_hash
        }

        access(all)
        fun getStatus(): String {
            return self.status
        }

        pub(set)
        var status: String

        init(id: String, data: Data, cadence_body_hash: String) {
            self.id = id
            self.data = data
            self.cadence_body_hash = cadence_body_hash
            self.status = "active"
        }
    }

    access(all) struct Data {
        access(all) var type: String
        access(all) var interface: String
        access(all) var messages: [Message]
        access(all) var cadence: Cadence
        access(all) var dependencies: [Dependency]
        access(all) var parameters: [Parameter]

        init(type: String, interface: String, messages: [Message], cadence: Cadence, dependencies: [Dependency], parameters: [Parameter]) {
            self.type = type
            self.interface = interface
            self.messages = messages
            self.cadence = cadence
            self.dependencies = dependencies
            self.parameters = parameters
        }
    }

    access(all) struct Message {
        access(all) var key: String
        access(all) var i18n: [I18n]

        init(key: String, i18n: [I18n]) {
            self.key = key
            self.i18n = i18n
        }
    }

    access(all) struct I18n {
        access(all) var tag: String
        access(all) var translation: String

        init(tag: String, translation: String) {
            self.tag = tag
            self.translation = translation
        }
    }

    access(all) struct Cadence {
        access(all) var body: String
        access(all) var network_pins: [NetworkPin]

        init(body: String, network_pins: [NetworkPin]) {
            self.body = body
            self.network_pins = network_pins
        }
    }

     access(all) struct NetworkPin {
        access(all) var network: String
        access(all) var pin_self: String

        init(network: String, pin_self: String) {
            self.network = network
            self.pin_self = pin_self
        }
    }

    access(all) struct Dependency {
        access(all) var contracts: [Contract]

        init(contracts: [Contract]) {
            self.contracts = contracts
        }
    }

    access(all) struct Contract {
        access(all) var contract: String
        access(all) var networks: [Network]

        init(contract: String, networks: [Network]) {
            self.contract = contract
            self.networks = networks
        }
    }

    access(all) struct Network {
        access(all) var network: String
        access(all) var address: String
        access(all) var dependency_pin_block_height: UInt64
        access(all) var dependency_pin: DependencyPin

        init(network: String, address: String, dependency_pin_block_height: UInt64, dependency_pin: DependencyPin) {
            self.network = network
            self.address = address
            self.dependency_pin_block_height = dependency_pin_block_height
            self.dependency_pin = dependency_pin
        }
    }

    access(all) struct DependencyPin {
        access(all) var pin: String
        access(all) var pin_self: String
        access(all) var pin_contract_name: String
        access(all) var pin_contract_address: String
        access(all) var imports: [Import]

        init(pin: String, pin_self: String, pin_contract_name: String, pin_contract_address: String, imports: [Import]) {
            self.pin = pin
            self.pin_self = pin_self
            self.pin_contract_name = pin_contract_name
            self.pin_contract_address = pin_contract_address
            self.imports = imports
        }
    }

    access(all) struct Import {
        access(all) var pin: String
        access(all) var pin_self: String
        access(all) var pin_contract_name: String
        access(all) var pin_contract_address: String
        access(all) var imports: [Import]

        init(pin: String, pin_self: String, pin_contract_name: String, pin_contract_address: String, imports: [Import]) {
            self.pin = pin
            self.pin_self = pin_self
            self.pin_contract_name = pin_contract_name
            self.pin_contract_address = pin_contract_address
            self.imports = imports
        }
    }

    // Had to remove balance since this is not being supported in the Go code
    access(all) struct Parameter {
        access(all) var label: String
        access(all) var index: Int
        access(all) var type: String
        access(all) var messages: [Message]

        init(label: String, index: Int, type: String, messages: [Message]) {
            self.label = label
            self.index = index
            self.type = type
            self.messages = messages
        }
    }
}