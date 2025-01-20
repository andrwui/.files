import { Gdk, Gtk } from 'astal/gtk3'
import Separator from '../_generic/Separator'
import GenericWindow from '../_generic/GenericWindow'
import SoundVolumeSlider from './volume/SoundVolumeSlider'
import SoundVolumeMuteButton from './volume/SoundVolumeMuteButton'
import SoundSpeakerList from './speakers/SoundSpeakerList'

export const SoundWindowNamePrefix = 'soundWindow'

const SoundWindow = (monitor: Gdk.Monitor, monitorIndex: number) => {
  const windowName = `${SoundWindowNamePrefix}-${monitorIndex}`

  const { START } = Gtk.Align

  return (
    <GenericWindow
      gdkmonitor={monitor}
      name={windowName}
      widthRequest={300}
    >
      <label
        hexpand
        halign={START}
        label="speakers"
        css={'font-size: 18px;'}
      />
      <Separator />
      <box
        vertical
        spacing={10}
      >
        <box>
          <label
            label={'volume'}
            halign={START}
          />
          <SoundVolumeMuteButton />
        </box>

        <SoundVolumeSlider />
      </box>
      <Separator />

      <SoundSpeakerList />
    </GenericWindow>
  )
}

export default SoundWindow
