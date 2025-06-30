import { bind, Variable } from 'astal'
import { Gtk } from 'astal/gtk3'
import AstalMpris from 'gi://AstalMpris?version=0.1'
import AudioVisualizer from './AudioVisualizer'
import { truncateText } from '@/helper/strings'
import SimpleClock from '../normal/SimpleClock'

export default function MusicLayout() {
  const spotify = AstalMpris.Player.new('spotify')

  const spotiSongNameBind = bind(spotify, 'title')
  const spotiArtistNameBind = bind(spotify, 'artist')
  const spotiPlaybackStatusBind = bind(spotify, 'playbackStatus')

  const fullTrackName = Variable.derive(
    [spotiSongNameBind, spotiArtistNameBind, spotiPlaybackStatusBind],
    (songName, artistName, playbackStatus) => {
      if (playbackStatus === AstalMpris.PlaybackStatus.PLAYING) {
        return `${artistName} - ${songName}`
      } else {
        return ''
      }
    },
  )

  return (
    <box
      name="music"
      halign={Gtk.Align.FILL}
      hexpand
      spacing={-5000}
    >
      <SimpleClock />
      <box
        hexpand
        halign={Gtk.Align.FILL}
      >
        <box
          hexpand
          halign={Gtk.Align.CENTER}
          spacing={5}
        >
          <icon icon="i-song" />
          <label
            label={fullTrackName()}
            maxWidthChars={25}
            truncate
          />
        </box>
      </box>
      <box>
        <AudioVisualizer />
      </box>
    </box>
  )
}
