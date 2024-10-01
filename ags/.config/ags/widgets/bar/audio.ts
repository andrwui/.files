import { watch } from "types/utils/binding"
import { writeFile } from "types/utils/file"
import { audio } from "util/services"
import playback from "../../services/playback"


const AudioTray = () => {

	const AudioButtons = playback.bind('sinks').as(sinks => {
		const sinkList = sinks.map(sink => {
			return Widget.Button({
				hpack: 'start',
				vpack: 'start',
				label: `${sink.sinkNick}  ${sink.sinkActive ? '   ' : ''}`,
				onClicked: async () => {
					Utils.execAsync(`pactl set-default-sink ${sink.sinkName}`)
					Utils.timeout(100, () => playback.updateSinks())
				}
			})
		})
		return sinkList.length === 0 ? [Widget.Label('No audio devices connected.')] : sinkList
	})

	const AudioButtonBox = Widget.Box({
		children: AudioButtons,
		vertical: true,
	})



	const Slider = Widget.Slider({
		className: audio.speaker.bind("is_muted").as(m => `volume-slider ${m ? 'muted' : ''}`),
		hexpand: true,
		drawValue: false,
		tooltipText: audio.speaker.bind("volume").as(v => typeof v === 'number' ? `${Math.round(v * 100)}%` : ''),
		onChange: async ({ value }) => {
			audio.speaker.volume = value
		},
		setup: self => self.hook(audio.speaker, () => {
			self.value = audio.speaker.volume || 0
		})
	})

	const MainBox = Widget.Box({
		vertical: true,
		spacing: 15,
		hpack: 'center',
		css: 'padding: 15px;',
		children: [
			Slider,
			AudioButtonBox,
		]
	})

	return MainBox

}

const AudioTrayWindow = Widget.Window({
	css: 'background: #080808',
	child: AudioTray(),
	visible: false,
	margins: [10, 150],
	anchor: ['right', 'top']
})


const ToggleAudioTray = () => {
	return Widget.Button({
		className: 'tray-button',
		child: Widget.Label({
			label: audio.speaker.bind('volume').as(v => v * 100 < 50 ? '' : ''),
			className: 'indicator-icon',
			css: 'font-size: 1em; padding-top: 1px;',

		}),

		onClicked: () => {
			AudioTrayWindow.visible = !AudioTrayWindow.visible
		},
	})

}
export default ToggleAudioTray
