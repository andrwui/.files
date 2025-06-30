import { bind, exec, timeout, Variable } from 'astal'
import { Gtk } from 'astal/gtk3'
import AstalMpris from 'gi://AstalMpris'
import Separator from '../../_generic/Separator'
import { truncate } from '../../../../../helper/helper'

const SpotifyPlayer = () => {
  const formatSongLength = (length: number) => {
    const min = Math.floor(length / 60)
    const sec = Math.floor(length % 60)
    const sec0 = sec < 10 ? '0' : ''
    return `${min}:${sec0}${sec}`
  }

  const spotify = AstalMpris.Player.new('spotify')

  console.log()

  const spotifyBinding = Variable<
    [
      boolean,
      string,
      string,
      string,
      string,
      AstalMpris.PlaybackStatus,
      number,
      number,
      AstalMpris.Loop,
      AstalMpris.Shuffle,
    ]
  >([
    false,
    '',
    '',
    '',
    '',
    AstalMpris.PlaybackStatus.STOPPED,
    0,
    0,
    AstalMpris.Loop.NONE,
    AstalMpris.Shuffle.OFF,
  ])

  const isDebouncing = Variable<boolean>(false)

  Variable.derive(
    [
      bind(spotify, 'available'),
      bind(spotify, 'title'),
      bind(spotify, 'artist'),
      bind(spotify, 'album'),
      bind(spotify, 'coverArt'),
      bind(spotify, 'playbackStatus'),
      bind(spotify, 'position'),
      bind(spotify, 'length'),
      bind(spotify, 'loopStatus'),
      bind(spotify, 'shuffleStatus'),
    ],
    (
      isAvailable,
      songTitle,
      songArtist,
      songAlbum,
      songCover,
      playbackStatus,
      position,
      length,
      loopStatus,
      shuffleStatus,
    ) => {
      spotifyBinding.set([
        isAvailable,
        songTitle,
        songArtist,
        songAlbum,
        songCover,
        playbackStatus,
        position,
        length,
        loopStatus,
        shuffleStatus,
      ])
    },
  )

  return (
    <>
      {bind(spotifyBinding).as(
        ([
          isAvailable,
          songTitle,
          songArtist,
          songAlbum,
          songCover,
          playbackStatus,
          songPosition,
          songLength,
          loopStatus,
          shuffleStatus,
        ]) => {
          return isAvailable ? (
            <box
              spacing={10}
              vertical
              widthRequest={340}
            >
              <Separator />
              <label
                label={'Spotify'}
                halign={Gtk.Align.START}
                css="font-size: 18"
              />
              <box
                vertical
                spacing={15}
              >
                <box spacing={10}>
                  <eventbox
                    halign={Gtk.Align.START}
                    heightRequest={100}
                    widthRequest={100}
                    cursor={'pointer'}
                    css={`
                      background-image: url('${songCover}');
                      background-size: contain;
                      border-radius: 5px;
                    `}
                    onClick={() => exec(['bash', '-e', 'spotify'])}
                  />
                  <box
                    vertical
                    valign={Gtk.Align.CENTER}
                  >
                    <label
                      label={truncate(songTitle, 15)}
                      halign={Gtk.Align.START}
                      css={`
                        font-size: 24px;
                        font-weight: 500;
                      `}
                    />
                    <label
                      label={songArtist}
                      halign={Gtk.Align.START}
                      css={`
                        font-size: 18px;
                        font-weight: 500;
                      `}
                    />
                    <label
                      label={truncate(songAlbum, 30)}
                      halign={Gtk.Align.START}
                      css={`
                        font-size: 15px;
                        font-weight: 300;
                      `}
                    />
                  </box>
                </box>
                <box
                  vertical
                  spacing={10}
                >
                  <centerbox>
                    <label
                      halign={Gtk.Align.START}
                      label={formatSongLength(songPosition)}
                    />
                    <box></box>
                    <label
                      halign={Gtk.Align.END}
                      label={formatSongLength(songLength)}
                    />
                  </centerbox>
                  <slider
                    hexpand
                    heightRequest={10}
                    cursor={'pointer'}
                    css={`
                      border-radius: 2px;
                    `}
                    onDragged={({ value }) => {
                      if (isDebouncing.get()) return
                      timeout(500, () => {
                        spotify.position = value * songLength
                      })
                    }}
                    value={songPosition / songLength}
                  />
                </box>
                <box halign={Gtk.Align.FILL}>
                  <centerbox spacing={10}>
                    <box hexpand>
                      <eventbox
                        halign={Gtk.Align.START}
                        onClick={() => spotify.shuffle()}
                        cursor={'pointer'}
                      >
                        <icon
                          icon={
                            shuffleStatus === AstalMpris.Shuffle.OFF ? 'shuffle-dark' : 'shuffle-c'
                          }
                          css={`
                            font-size: 18px;
                          `}
                        />
                      </eventbox>
                      <eventbox
                        hexpand
                        halign={Gtk.Align.END}
                        onClick={() => spotify.previous()}
                        cursor={'pointer'}
                      >
                        <icon
                          css={`
                            font-size: 18px;
                          `}
                          icon="chevron-first"
                        />
                      </eventbox>
                    </box>
                    <eventbox
                      halign={Gtk.Align.CENTER}
                      onClick={() => spotify.play_pause()}
                      cursor={'pointer'}
                    >
                      <icon
                        css={`
                          font-size: 18px;
                        `}
                        icon={
                          playbackStatus === AstalMpris.PlaybackStatus.PLAYING ? 'pause' : 'play'
                        }
                      />
                    </eventbox>
                    <box hexpand>
                      <eventbox
                        cursor={'pointer'}
                        hexpand
                        halign={Gtk.Align.START}
                        onClick={() => spotify.next()}
                      >
                        <icon
                          css={`
                            font-size: 18px;
                          `}
                          icon="chevron-last"
                        />
                      </eventbox>
                      <eventbox
                        halign={Gtk.Align.END}
                        onClick={() => spotify.loop()}
                        cursor={'pointer'}
                      >
                        <icon
                          icon={`${loopStatus === AstalMpris.Loop.NONE ? 'repeat-dark' : loopStatus === AstalMpris.Loop.TRACK ? 'infinity' : 'repeat-c'}`}
                          css={`
                            font-size: 18px;
                          `}
                        />
                      </eventbox>
                    </box>
                  </centerbox>
                </box>
              </box>
            </box>
          ) : (
            ''
          )
        },
      )}
    </>
  )
}

export default SpotifyPlayer
