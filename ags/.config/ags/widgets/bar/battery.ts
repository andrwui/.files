import { watch } from 'types/utils/binding'
import { battery } from 'util/services'

const classNames = Utils.merge(
	[
		battery.bind("percent"),
		battery.bind("charging"),
	],
	(percentage, charging) => {

		const classes = ['battery']


		if (charging) {

			Utils.exec("brightnessctl set 15360")

			if (percentage >= 90) {
				classes.push('overcharging')

			} else {
				classes.push('charging')

			}

		} else {

			if (percentage <= 20) {

				if (percentage == 20) {
					Utils.exec("brightnessctl set 4000")
					Utils.notify({
						timeout: 10000,
						summary: 'Low battery',
						body: `${percentage}% Remaining.`,
						urgency: 'critical'
					})

				}


				classes.push('low')
				if (percentage <= 10) {

					if (percentage == 10) {
						Utils.exec("brightnessctl set 1000")
						Utils.notify({
							timeout: 10000,
							summary: 'Low battery',
							body: `${percentage}% Remaining.`,
							urgency: 'critical'
						})

					}
					classes.push('danger')
				}
			} else if (percentage <= 40) {
				classes.push('med')
			}
		}
		return classes.join(" ")

	})


const Battery = () => {
	return Widget.LevelBar({
		className: classNames,
		vpack: 'center',
		widthRequest: 32,
		heightRequest: 16,
		value: battery.bind("percent").as(p => p > 0 ? p / 100 : 0),
		tooltip_markup: battery.bind("percent").as(p => `${p}%`),
	})
}
export default Battery

