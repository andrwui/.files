import { NotificationPopups } from "./widgets/notifications/popup.ts"
import { hyprland } from "./util/services.ts"
import Bar from "./widgets/bar/bar.ts"




const sassSource = App.configDir + '/style/index.sass'
const cssOutdir = '/tmp/ags/css.css'

Utils.exec(`sass ${sassSource} ${cssOutdir}`)


const GetWidgetsForAllMonitors = () => {
	const bars = hyprland.monitors.map((_, i) => {
		return Bar(i)
	})

	return {
		bars: bars,
	}
}

const { bars } = GetWidgetsForAllMonitors()


App.config({
	style: cssOutdir,
	windows: [
		...bars,
		NotificationPopups(),
	],
})
