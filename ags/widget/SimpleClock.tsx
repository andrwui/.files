import { createPoll } from 'ags/time'

export default function SimpleClock() {
  const clock = createPoll('', 1000, 'date +%H:%M')

  return (
    <box>
      <label
        label={clock((clock) => {
          return clock
        })}
      />
    </box>
  )
}
