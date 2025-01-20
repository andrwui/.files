import { bind } from 'astal'
import { SoundWindowNamePrefix } from '../windows/sound/SoundWindow'
import { closeAllOtherWindows } from './helper'
import AstalWp from 'gi://AstalWp'

const Sound = ({ monitorIndex }: { monitorIndex: number }) => {
  const windowName = `${SoundWindowNamePrefix}-${monitorIndex}`
  const defaultSpeaker = AstalWp.get_default()!.audio.defaultSpeaker

  return (
    <eventbox onClick={() => closeAllOtherWindows(windowName)}>
      {
        <label
          css="font-weight: 500; font-size: 15px;"
          label={bind(defaultSpeaker, 'volume').as((volume) => `[audio]`)}
        ></label>
      }
    </eventbox>
  )
}

export default Sound
