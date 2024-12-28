import { watch } from "types/utils/binding"

export const ColorPicker = () => {
	return Widget.Box({
		child: Widget.Button({
			className: 'color-picker',
			label: "",
			onClicked: () => {
				Utils.execAsync('hyprpicker -a -f hex -r').then((res: string) => {
					Utils.execAsync(`wl-copy ${res}`).then(() => {
					})
				})
			}
		})
	})
}
