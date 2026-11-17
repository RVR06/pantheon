workspace "Lethe" "The river of forgetting: consent, secrets and right-to-erasure for every realm." {
	!identifiers hierarchical
	!impliedRelationships false
	
	model {
		lethe = softwareSystem "Lethe" "The river of forgetting: consent, secrets and right-to-erasure for every realm." "#lethe" {
			
			river = container "River" "Carries erasure orders to every realm." "NATS JetStream" "#bus, #nats"
			ledgerdb = container "Ledger" "Append-only record of consent and erasure." "PostgreSQL" "#db, #postgresql"
			vault = container "Vault" "Holds encryption keys and secrets." "HashiCorp Vault" "#db, #hashicorp"
			
			api = container "Lethe API" "Records consent and erasure requests." ".NET / ASP.NET Core" "#api, #dotnet" {
				validator = component "Request Validator" "Checks the request and the caller's identity." "FluentValidation" "#guard"
				outbox = component "Outbox" "Guarantees every request is published." "Wolverine" "#ferry" {
					-> river "publishes onto"
				}
				ledger = component "Ledger Repository" "Appends requests to the ledger." "Marten" "#repo" {
					-> ledgerdb "stores in"
				}
				
				consentctl = component "Consent Endpoint" "POST /consent" "ASP.NET Core Minimal API" "#endpoint, #dotnet" {
					-> validator "validates through"
					-> ledger "appends to"
				}
				
				erasurectl = component "Erasure Endpoint" "POST /erasure" "ASP.NET Core Minimal API" "#endpoint, #dotnet" {
					-> validator "validates through"
					-> ledger "appends to"
					-> outbox "publishes through"
				}
				
				-> ledgerdb "appends to" "SQL"
				-> river "publishes erasure orders onto" "NATS"
				-> vault "wraps data keys with" "HTTPS"
			}
			
			consent = container "Consent Console" "Web console where heroes manage consent and erasure." "Blazor WebAssembly" "#web, #blazor" {
				-> api "calls" "HTTPS"
			}
			
			shredder = container "Shredder" "Executes erasure orders against every datastore." "Go Worker" "#worker, #go" {
				-> river "consumes erasure orders from" "NATS"
				-> vault "unwraps keys with" "HTTPS"
			}
			audit = container "Audit CLI" "Exports consent and erasure proofs for auditors." "Rust" "#cli, #rust" {
				-> ledgerdb "reads" "SQL"
			}
		}
		
		hero = person "Hero" "A living mortal who visits the realms and uses the Elysium citizen app." "" {
			-> lethe "manages consent in"
			-> lethe.consent "manages consent in"
			-> lethe.consent "Requests erasure"
			
		}
		aeacus = person "Aeacus" "A judge of the dead who audits consent and erasure requests." "" {
			-> lethe "exports proofs with"
			-> lethe.audit "exports proofs with"
		}
	}
	
	views {
		theme https://raw.githubusercontent.com/rvr06/cornifer-contrib/main/themes/topology/theme.json
		theme https://raw.githubusercontent.com/rvr06/cornifer-contrib/main/themes/heraldry2/theme.json
		
		properties {
			"structurizr.sort" "created"
		}
		
		styles {
			element "#blazor" {
				stroke #5a2d8e
				icon icons/blazor.svg
			}
			element "#cli" {
				shape Terminal
			}
			element "#worker" {
				shape Folder
			}
			element "#lethe" {
				stroke #00ACC1
				icon icons/lethe.svg
			}
		}
		
		systemContext lethe "Lethe_Context" {
			include *
		}
		
		container lethe "Lethe_Containers" {
			include *
		}
		
		component lethe.api "Lethe_Components" {
			include *
		}
	}
}
