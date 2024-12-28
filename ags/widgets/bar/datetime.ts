const time = Variable('', {
	poll: [1000, () => {
		const [hours, minutes] = new Date().toLocaleString('es-UY', { hour12: false }).split(', ')[1].split(':')
		return [hours.trim(), minutes.trim()].join(':')

	}]
})

const date = Variable('', {
	poll: [1000, () => {
		const [day, month] = new Date().toLocaleString('es-UY', { hour12: false }).split(', ')[0].split('/')
		return [day.trim(), month.trim()].join('/')

	}]
})
export const DateItem = () => {
	return Widget.Box({
		spacing: 0,
		children: [

			Widget.Label({
				className: 'time',
				label: date.bind()
			}),
		]
	})
}

export const Time = () => {
	return Widget.Label({
		className: 'time',
		label: time.bind()
	})
}

