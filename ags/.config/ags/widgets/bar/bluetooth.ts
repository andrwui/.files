import bluetooth from "../../services/bluetoothctl"


const Bluetooth = () => {
	return Widget.Label({
		label: bluetooth.bind('is_connected').as(c => `${c ? '󰂯' : ''}`),
		className: 'indicator-icon'
	})
}

export default Bluetooth
