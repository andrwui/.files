import ToggleTray from "./tray"
import Battery from "./battery"
import { DateItem as Date, Time } from "./datetime.ts"
import Audio from "./audio"
import Workspaces from "./workspaces"
import Network from "./network"
import Bluetooth from "./bluetooth"
import { ColorPicker } from "./utilities/color_picker"
import Screenshot from "./utilities/screenshot.ts"


const Start = () => {
	return Widget.Box({
		hpack: 'start',
		vpack: 'center',
		spacing: 15,
		marginLeft: 15,
		children: [
			ColorPicker(),
			Screenshot()
		],
	})
}

const Center = () => {
	return Widget.Box({
		hpack: 'end',
		vpack: 'center',
		spacing: 0,
		children: [
			Workspaces(),
		],
	})
}

const End = () => {
	return Widget.Box({
		hpack: 'end',
		spacing: 15,
		marginRight: 15,
		children: [
			Bluetooth(),
			Network(),
			Audio(),
			Battery(),
			Time(),
			Date(),
			ToggleTray(),
		],
	})
}


const Bar = (monitor: number) => Widget.Window({
	monitor,
	name: `bar${monitor}`,
	anchor: ['top', 'left', 'right'],
	exclusivity: 'exclusive',
	className: "bar",
	child: Widget.CenterBox({
		start_widget: Start(),
		center_widget: Center(),
		end_widget: End(),
	}),
})

export default Bar
