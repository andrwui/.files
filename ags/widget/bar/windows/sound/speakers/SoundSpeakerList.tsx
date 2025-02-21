import { bind } from 'astal'
import { Gtk } from 'astal/gtk3'
import AstalWp from 'gi://AstalWp?version=0.1'
import SoundSpeaker from './speaker/SoundSpeaker'

const SoundSpeakerList = () => {
  const audio = AstalWp.get_default()!.audio

  return (
    <box
      hexpand
      vertical
      halign={Gtk.Align.FILL}
    >
      <>
        <label
          hexpand
          halign={Gtk.Align.START}
          marginBottom={10}
          label="Available speakers"
        />

        {bind(audio, 'speakers').as((speakers) => {
          const filteredSpeakers = speakers.filter(
            (speaker) => !speaker.description.includes('Tiger Lake-LP'),
          )
          if (filteredSpeakers.length < 1) {
            return (
              <label
                hexpand
                halign={Gtk.Align.START}
                label="no speakers found"
              />
            )
          }
          return filteredSpeakers.map((speaker) => {
            return <SoundSpeaker speaker={speaker} />
          })
        })}
      </>
    </box>
  )
}

export default SoundSpeakerList
