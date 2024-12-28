import { systemtray } from "../../util/services"

const Tray = Widget.Window({
	visible: false,
	name: 'tray-window',
	anchor: ['top', 'right'],
	exclusivity: 'normal',
	layer: 'top',
	margins: [15, 15, 15, 15,],
	child: Widget.Box({
		children: systemtray.bind('items').as(items => items.map(
			item => {
				return Widget.Button({
					className: 'tray-item-button',
					child: Widget.Box({
						children: [
							// @ts-ignore
							Widget.Icon().bind('icon', item, 'icon'),
						],
					}),
					onPrimaryClick: (_, event) => item.activate(event),
					onSecondaryClick: (_, event) => item.openMenu(event),
				})
			}
		))
	}),
})

const ToggleTray = () => {
	return Widget.Button({
		className: 'tray-button',
		child: Widget.Label({ label: '󰅀' }),
		onClicked: () => {
			Tray.visible = !Tray.visible
		},
	})

}


export default ToggleTray
