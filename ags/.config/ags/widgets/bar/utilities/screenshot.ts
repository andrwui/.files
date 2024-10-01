const Screenshot = () => {
	return Widget.Button({
		label: '󰹑',
		className: 'button-icon',
		onClicked: () => {
			Utils.execAsync("hyprshot -z -m region")
		}
	})
}

export default Screenshot
