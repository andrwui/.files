import { bind, Variable } from 'astal'
import { Gtk } from 'astal/gtk3'
import AstalMpris from 'gi://AstalMpris?version=0.1'
import AudioVisualizer from './AudioVisualizer'

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
      halign={Gtk.Align.CENTER}
      hexpand
      spacing={-5000}
    >
      <AudioVisualizer />
    </box>
  )
}
