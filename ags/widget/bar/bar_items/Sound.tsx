import { bind, Variable } from 'astal'
import { SoundWindowNamePrefix } from '../windows/sound/SoundWindow'
import { closeAllOtherWindows } from './helper'
import AstalWp from 'gi://AstalWp'
import { Gtk } from 'astal/gtk3'

const Sound = ({ monitorIndex }: { monitorIndex: number }) => {
  const windowName = `${SoundWindowNamePrefix}-${monitorIndex}`
  const defaultSpeaker = AstalWp.get_default()!.audio.defaultSpeaker

  const soundStateBinding = Variable<[boolean, number]>([false, 0])

  Variable.derive(
    [bind(defaultSpeaker, 'mute'), bind(defaultSpeaker, 'volume')],
    (mute, volume) => {
      soundStateBinding.set([mute, volume])
    },
  )

  return (
    <eventbox
      cursor={'pointer'}
      onClick={() => closeAllOtherWindows(windowName)}
    >
      {bind(soundStateBinding).as(([isMuted, volume]) => {
        return (
          <icon
            widthRequest={13}
            valign={Gtk.Align.FILL}
            css={`
              font-size: 16px;
              ${isMuted ? 'color: #404040' : ''}
            `}
            icon={
              isMuted
                ? 'volume-x'
                : volume < 0.15
                  ? `volume-none`
                  : volume > 0.75
                    ? `volume-high`
                    : 'volume-low'
            }
          />
        )
      })}
    </eventbox>
  )
}

export default Sound
