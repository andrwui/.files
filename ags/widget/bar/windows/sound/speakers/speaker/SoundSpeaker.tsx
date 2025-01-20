import AstalWp from 'gi://AstalWp'
import { Gtk } from 'astal/gtk3'
import { bind } from 'astal'
import GenericTextButton from '../../../_generic/GenericTextButton'

const SoundSpeaker = ({ speaker }: { speaker: AstalWp.Endpoint }) => {
  const speakerName = speaker.name || speaker.description
  return (
    <box
      hexpand
      halign={Gtk.Align.FILL}
    >
      {bind(speaker, 'isDefault').as((isDefault) => {
        return (
          <label
            hexpand
            label={`${speakerName.includes('EVO') ? 'EVO4' : speakerName} ${isDefault ? '<-' : ''}`}
            halign={Gtk.Align.START}
          />
        )
      })}
      <GenericTextButton
        hexpand
        halign={Gtk.Align.END}
        onClick={() => speaker.set_is_default(true)}
      >
        <label
          hexpand
          label={bind(speaker, 'isDefault').as((isDefault) =>
            isDefault ? '[default]' : '[set default]',
          )}
        />
      </GenericTextButton>
    </box>
  )
}

export default SoundSpeaker
