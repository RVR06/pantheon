workspace "Tartarus" "The Underworld spike: auth, messaging, persistence and three deployment flavours." {
	!identifiers hierarchical
	!impliedRelationships false
	
	model {
		keycloakdocs = softwareSystem "Keycloak Docs" "External reference for the identity provider." "External" {
			url "https://www.keycloak.org/documentation"
		}
		obol = softwareSystem "Obol Payments" "External payment gateway used to pay Charon's fare." "External" {
			url "https://stripe.com/docs"
		}
		
		tartarus = softwareSystem "Tartarus" "The Underworld spike." "#tartarus" {
			mnemosyne = container "Mnemosyne" "Remembers the Underworld's structure — the circles of hell." "PostgreSQL" "#db, #postgresql"
			styx = container "Styx" "Carries soul arrival messages between Charon and Minos." "RabbitMQ" "#bus, #rabbitmq"
			
			hecate = container "Hecate" "Holds the keys to every realm — authenticates and issues tokens for souls entering the Underworld." "Keycloak" "#keycloak" {
				-> keycloakdocs "is configured following"
			}
			
			anamnesis = container "Anamnesis" "Lets one recall and inspect what Mnemosyne remembers." "pgweb" "#web, #postgresql" {
				-> mnemosyne "inspects"
			}
			
			charon = container "Charon" "Ferries an authenticated soul across the Styx and serves the Underworld's circle data." ".NET / ASP.NET Core" "#dotnet" {
				-> hecate "validates tokens via"
				-> styx "publishes soul arrival onto"
				-> mnemosyne "reads and seeds circles in"
				-> obol "collects the fare from"
				
				guard = component "Token Guard" "Rejects any request without a valid bearer token." "JwtBearer" "#guard" {
					-> tartarus.hecate "validates tokens via"
				}
				ferry = component "Soul Ferry" "Publishes a soul arrival message for each visit." "RabbitMQ.Client" "#ferry" {
					-> tartarus.styx "publishes onto"
				}
				circles = component "Circle Repository" "Reads and seeds the circles." "Npgsql" "#repo" {
					-> tartarus.mnemosyne "reads and seeds"
				}
				endpoint = component "Underworld Endpoint" "GET /underworld — returns the nine circles of hell." "ASP.NET Core Minimal API" "#endpoint" {
					-> guard "is protected by"
					-> circles "loads circles through"
					-> ferry "announces arrival through"
				}
			}
			
			minos = container "Minos" "Judges each arriving soul into a circle of hell." ".NET Worker Service" "#dotnet" {
				-> styx "consumes soul arrival from"
				-> mnemosyne "reads circles from"
				
				judge = component "Judge" "Decides which circle a soul belongs to." "C#" "#judge" {
					-> tartarus.mnemosyne "reads circles from"
				}
				listener = component "Arrival Listener" "Consumes soul arrival messages." "RabbitMQ.Client" "#ferry" {
					-> judge "hands each soul to"
					-> tartarus.styx "consumes from"
				}
			}
			
			cerberus = container "Cerberus" "Guards the gate — the souls must log in through before seeing the Underworld." ".NET / Blazor" "#web, #blazor" {
				-> hecate "authenticates via"
				-> charon "calls the Underworld API via"
				
				oidc = component "OIDC Middleware" "Runs the authorization-code flow against Hecate." "OpenIdConnect" "#guard" {
					-> tartarus.hecate "authenticates via"
				}
				client = component "Underworld Client" "Calls Charon with the signed-in user's access token." "HttpClient" "#repo" {
					-> tartarus.charon "GET /underworld"
				}
				gate = component "Gate Page" "Landing page with the sign-in button." "Blazor" "#page" {
					-> oidc "signs in through"
				}
				underworld = component "Underworld Page" "Lists the circles of hell for an authenticated soul." "Blazor" "#page" {
					-> client "fetches circles through"
				}
			}
			
			clio = container "Clio" "Renders the C4 model, ADRs, and narrative doc for this spike." "Structurizr Lite" "#web, #structurizr"
			themis = container "Themis" "Tracks the adoption stage of every technology introduced in this spike." "JavaScript" "#web, #radar"
			
			styx -> minos "Delivers soul arrival"
		}
		
		soul = person "Soul" "A soul authenticating and roaming the Underworld." "#soul" {
			-> tartarus "enters and browses the Underworld via"
			-> tartarus.cerberus "enters and browses the Underworld via"
		}
		orpheus = person "Orpheus" "An operator who inspects the Underworld's memory and documentation." "#soul" {
			-> tartarus "never watches behind"
			-> tartarus.anamnesis "inspects the circles through"
			-> tartarus.clio "reads the architecture in"
			-> tartarus.themis "checks technology adoption in"
		}
		
		local_ = deploymentEnvironment "Local" {
			laptop = deploymentNode "Developer laptop" "" "Windows 11" "#windows" {
				browser_ = infrastructureNode "Web browser" "" "Firefox" "#firefox, #web"
				
				orchestration_ = deploymentNode "Orchestration" "" "Docker Desktop" "#docker" {
					dashboard_ = infrastructureNode "Aspire Dashboard" "Telemetry and resource overview" "Aspire" "#web, #aspire"
					
					cerberus_ = containerInstance tartarus.cerberus
					charon_ = containerInstance tartarus.charon
					minos_ = containerInstance tartarus.minos
					themis_ = containerInstance tartarus.themis
					
					hecate_d_ = deploymentNode "keycloak" "" "Docker" "#docker" {
						hecate_ = containerInstance tartarus.hecate
					}
					mnemosyne_d_ = deploymentNode "postgresql" "" "Docker" "#docker" {
						mnemosyne_ = containerInstance tartarus.mnemosyne
					}
					styx_d_ = deploymentNode "rabbitmq" "" "Docker" "#docker" {
						styx_ = containerInstance tartarus.styx
					}
					anamnesis_d_ = deploymentNode "pgweb" "" "Docker" "#docker" {
						anamnesis_ = containerInstance tartarus.anamnesis
					}
					clio_d_ = deploymentNode "structurizr" "" "Docker" "#docker" {
						clio_ = containerInstance tartarus.clio
					}
				}
				
				browser_ -> orchestration_.dashboard_ "reads telemetry and credentials" "HTTPS"
				browser_ -> orchestration_.clio_d_.clio_ "explores architecture" ""
				browser_ -> orchestration_.themis_ "explores technology stack" ""
				browser_ -> orchestration_.cerberus_ "exercises" ""
			}
		}
		
		k8s_ = deploymentEnvironment "Kubernetes" {
			laptop = deploymentNode "Developer laptop" "" "Windows 11" "#windows" {
				browser_ = infrastructureNode "Web browser" "" "Firefox" "#firefox, #web"
			}
			
			orchestration_ = deploymentNode "Orchestration" "" "Kubernetes cluster" "#k8s" {
				k8s_ingress = infrastructureNode "Traefik IngressRoutes" "" "Traefik" "#traefik"
				k8s_ns = deploymentNode "tartarus" "Kubernetes ns" "#k8s" {
					cerberus_d_ = deploymentNode "cerberus" "" "Docker" "#docker" {
						cerberus_ = containerInstance tartarus.cerberus
					}
					charon_d_ = deploymentNode "charon" "" "Docker" "#docker" {
						charon_ = containerInstance tartarus.charon
					}
					minos_d_ = deploymentNode "minos" "" "Docker" "#docker" {
						minos_ = containerInstance tartarus.minos
					}
					hecate_d_ = deploymentNode "hecate" "" "Docker" "#docker" {
						hecate_ = containerInstance tartarus.hecate
					}
					mnemosyne_d_ = deploymentNode "postgresql" "" "Docker" "#docker" {
						mnemosyne_ = containerInstance tartarus.mnemosyne
					}
					styx_d_ = deploymentNode "rabbitmq" "" "Docker" "#docker" {
						styx_ = containerInstance tartarus.styx
					}
				}
			}
			
			laptop.browser_ -> orchestration_.k8s_ingress "exercises" ""
			orchestration_.k8s_ingress -> orchestration_.k8s_ns.cerberus_d_.cerberus_ "forwards requests to" ""
		}
	}
	
	views {
		theme https://raw.githubusercontent.com/rvr06/cornifer-contrib/main/themes/topology/theme.json
		theme https://raw.githubusercontent.com/rvr06/cornifer-contrib/main/themes/heraldry2/theme.json
		
		properties {
			"structurizr.sort" "created"
		}
		
		styles {
			element "#soul" {
				stroke #4F6FA0
			}
			element "External" {
				background #999999
			}
			element "#blazor" {
				stroke #5a2d8e
				icon icons/blazor.svg
			}
			element "#tartarus" {
				stroke #800080
				icon icons/tartarus.svg
			}
			element "#structurizr" {
				stroke #08427B
				icon icons/c4.svg
			}
			element "#radar" {
				stroke #ff6a16
				icon icons/radar.svg
			}
		}
		
		systemContext tartarus "Tartarus_Context" {
			include *
		}
		
		container tartarus "C4_2" {
			include *
		}
		
		component tartarus.charon "Charon_Components" {
			include *
		}
		
		component tartarus.cerberus "Cerberus_Components" {
			include *
		}
		
		deployment * local_ "Local" {
			include *
		}
		
		deployment * k8s_ "Kubernetes" {
			include *
		}
		
		dynamic tartarus "SoulArrival" "A soul signs in and is judged into a circle of hell." {
			soul -> tartarus.cerberus "Opens the gate"
			tartarus.cerberus -> tartarus.hecate "Redirects to sign in (OIDC)"
			tartarus.hecate -> tartarus.cerberus "Issues tokens"
			
			tartarus.cerberus -> tartarus.charon "GET /underworld with bearer token"
			tartarus.charon -> tartarus.hecate "Validates the token"
			tartarus.charon -> tartarus.styx "Publishes soul arrival"
			
			{
				{
					tartarus.charon -> tartarus.mnemosyne "Reads the circles"
				}
				{
					tartarus.styx -> tartarus.minos "Delivers soul arrival"
					tartarus.minos -> tartarus.mnemosyne "Looks up the circle to judge into"
				}
			}
			tartarus.charon -> tartarus.cerberus "Returns the circles"
			tartarus.cerberus -> soul "Shows the Underworld"
		}
	}
}