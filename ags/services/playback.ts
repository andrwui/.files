interface Sink {
	sinkName: string
	sinkNick: string
	sinkActive: boolean
}

class AudioService extends Service {
	static {
		Service.register(
			this,
			{
				'sink-changed': ['boolean']
			},
			{
				'sinks': ['jsobject', 'r']
			}
		)
	}

	#sinks: Sink[] = this.#getSinks()

	get sinks() {
		return this.#sinks
	}

	constructor() {
		super()

		Utils.interval(1000, () => {
			const newSinks = this.#getSinks()

			if (JSON.stringify(newSinks) !== JSON.stringify(this.#sinks)) {
				this.#sinks = newSinks
				this.changed('sinks')

				//@ts-ignore
				this.emit('sink-changed', true)
			}
		})
	}

	updateSinks() {
		const newSinks = this.#getSinks()
		if (JSON.stringify(newSinks) !== JSON.stringify(this.#sinks)) {
			this.#sinks = newSinks
			this.changed('sinks')

			//@ts-ignore
			this.emit('sink-changed', true)
		}
	}

	#getSinks(): Sink[] {
		const pwNodesRaw = Utils.exec('pw-cli list-objects Node')
		const pactlActiveSink = Utils.exec("pactl get-default-sink")


		const sinks: Sink[] = []
		const nodes = pwNodesRaw.split(/type PipeWire:Interface/)

		nodes.forEach(block => {
			const lines = block.split("\n")
			let sinkName = ""
			let sinkNick = ""
			let sinkDescription = ""
			let isSink = false

			lines.forEach(line => {
				const trimmedLine = line.trim()
				if (trimmedLine.startsWith("node.name =")) {
					sinkName = trimmedLine.split('=')[1].trim().replace(/"/g, '')
				}
				if (trimmedLine.startsWith("node.nick =")) {
					sinkNick = trimmedLine.split('=')[1].trim().replace(/"/g, '')
				}
				if (trimmedLine.startsWith("node.description =")) {
					sinkDescription = trimmedLine.split('=')[1].trim().replace(/"/g, '')
				}
				if (trimmedLine.includes("media.class") && trimmedLine.includes("Sink")) {
					isSink = true
				}
			})

			if (isSink && !sinkName.includes("pci")) {
				sinks.push({
					sinkName: sinkName,
					sinkNick: sinkNick || sinkDescription,
					sinkActive: sinkName === pactlActiveSink
				})
			}
		})

		return sinks
	}
}

const playback = new AudioService()

export default playback

