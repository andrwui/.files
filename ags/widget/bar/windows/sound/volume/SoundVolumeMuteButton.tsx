import { Gtk } from 'astal/gtk3'
import GenericTextButton from '../../_generic/GenericTextButton'
import AstalWp from 'gi://AstalWp'
import { bind } from 'astal'

const SoundVolumeMuteButton = () => {
  const { END } = Gtk.Align
  const audio = AstalWp.get_default()!.audio

  return (
    <GenericTextButton
      hexpand
      halign={END}
      onClick={() => {
        audio.defaultSpeaker.set_mute(!audio.defaultSpeaker.mute)
      }}
    >
      <icon
        icon={bind(audio.defaultSpeaker, 'mute').as(
          (isMuted) => `${isMuted ? 'volume-x' : 'volume-high'}`,
        )}
        css="font-size: 18px;"
      />
    </GenericTextButton>
  )
}

export default SoundVolumeMuteButton
