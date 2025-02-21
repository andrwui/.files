import { bind } from 'astal'
import AstalWp from 'gi://AstalWp'

const SoundVolumeSlider = () => {
  const speaker = AstalWp.get_default()!.audio.defaultSpeaker!

  return (
    <slider
      hexpand
      heightRequest={10}
      cursor={'pointer'}
      className={bind(speaker, 'mute').as((isMuted) => (isMuted ? 'muted' : ''))}
      css={`
        border-radius: 2px;
      `}
      onDragged={(self) => {
        speaker.volume = self.value * 1.5
      }}
      value={bind(speaker, 'volume').as((vol) => vol / 1.5)}
    />
  )
}

export default SoundVolumeSlider
