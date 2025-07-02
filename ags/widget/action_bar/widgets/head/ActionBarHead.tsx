import { Gtk } from 'astal/gtk3'
import { bind, Variable } from 'astal'
import { Durations } from '@/constants/constants'
import AstalMpris from 'gi://AstalMpris?version=0.1'
import MusicLayout from './music/MusicLayout'
import ActionBarHeadNormalLayout from './normal/ActionBarHeadNormalLayout'

export enum HeadLayout {
  NORMAL = 'clock',
  MUSIC = 'music',
}

export default function ActionBarHead() {
  const currentLayout = Variable<HeadLayout>(HeadLayout.NORMAL)

  const spotify = AstalMpris.Player.new('spotify')
  const spotiPlaybackStatusBind = bind(spotify, 'playbackStatus')

  spotiPlaybackStatusBind.subscribe((playbackStatus) => {
    if (playbackStatus === AstalMpris.PlaybackStatus.PLAYING) {
      currentLayout.set(HeadLayout.MUSIC)
    } else {
      currentLayout.set(HeadLayout.NORMAL)
    }
  })

  if (spotify.playbackStatus === AstalMpris.PlaybackStatus.PLAYING) {
    currentLayout.set(HeadLayout.MUSIC)
  }

  return (
    <box
      className={'actionbar_head'}
      hexpand
      heightRequest={30}
      halign={Gtk.Align.FILL}
      vexpand={false}
      width_request={250}
    >
      <stack
        transition_type={Gtk.StackTransitionType.CROSSFADE}
        transition_duration={Durations.TRANSITION}
        visibleChildName={currentLayout()}
      >
        <ActionBarHeadNormalLayout />
        <MusicLayout />
      </stack>
    </box>
  )
}
