workspace "Erebos" "The darkness between the worlds: logs, traces and alerts for the whole pantheon." {
	!identifiers hierarchical
	!impliedRelationships false
	
	model {
		erebos = softwareSystem "Erebos" "The darkness between the worlds: logs, traces and alerts for the whole pantheon." "#erebos" {
			shadows = container "Shadows" "Stores logs." "Loki" "#db, #loki"
			tracestore = container "Twilight" "Stores traces." "Grafana Tempo" "#db, #tempo"
			pager = container "Pager Bot" "Wakes the on-call Titan." "Slack Bot" "#bot, #slack"
			
			torch = container "Torch" "OpenTelemetry collector receiving telemetry from every realm." "OpenTelemetry Collector" "#otel" {
				-> shadows "exports logs to" "OTLP"
				-> tracestore "exports traces to" "OTLP"
			}
			
			watchtower = container "Watchtower" "Dashboards and alerts." "Grafana" "#web, #grafana" {
				-> shadows "queries" "HTTPS"
				-> tracestore "queries" "HTTPS"
				-> pager "raises alerts to" "Webhook"
			}
		}
		
		titan = person "Titan" "A platform engineer who runs the pantheon and reads its telemetry." "" {
			-> erebos "reads telemetry in"
			-> erebos.watchtower "reads telemetry in"
		}
		
		erebos -> titan "wakes"
		erebos.pager -> titan "wakes"
	}
	
	views {
		theme https://raw.githubusercontent.com/rvr06/cornifer-contrib/main/themes/topology/theme.json
		theme https://raw.githubusercontent.com/rvr06/cornifer-contrib/main/themes/heraldry2/theme.json
		
		properties {
			"structurizr.sort" "created"
		}
		
		styles {
			element "#bot" {
				shape Robot
			}
			element "#erebos" {
				stroke #5E35B1
				icon icons/erebos.svg
			}
		}
		
		systemContext erebos "Erebos_Context" {
			include *
		}
		
		container erebos "Erebos_Containers" {
			include *
		}
	}
}
